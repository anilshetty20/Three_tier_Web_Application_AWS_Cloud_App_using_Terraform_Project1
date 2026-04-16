#IAM ROLE (SSM ACCESS)
resource "aws_iam_role" "ec2_role" {
  name = "cloud-ec2-ssm-role-tf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

#Attach SSM Policy
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "cloud-ec2-profile-tf"
  role = aws_iam_role.ec2_role.name
}

#LATEST UBUNTU AMI (NO HARDCODING)
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

#LAUNCH TEMPLATE
resource "aws_launch_template" "lt" {
  name_prefix   = "cloudapp-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  vpc_security_group_ids = [var.ec2_sg_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
set -e

apt-get update -y
apt-get install -y postgresql-client
apt-get install -y docker.io

systemctl start docker
systemctl enable docker


docker pull ${var.docker_image}

docker stop backend || true
docker rm backend || true

docker run -d \
  --name backend \
  --restart always \
  -p 5000:5000 \
  -e DB_HOST=${var.db_endpoint} \
  -e DB_USER=postgres \
  -e DB_PASSWORD=${var.db_password} \
  -e DB_NAME=${var.db_name} \
  -e DB_PORT=5432 \
  ${var.docker_image}
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "cloud-app-instance-tf"
    }
  }
}

#AUTO SCALING GROUP
resource "aws_autoscaling_group" "asg" {
  name = "cloud-app-asg-tf"

  desired_capacity = 2
  min_size         = 1
  max_size         = 4

  vpc_zone_identifier = var.private_subnets

  target_group_arns = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "cloud-app-instance-tf"
    propagate_at_launch = true
  }
}

#SCALING POLICY (CPU)
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "cpu-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}

