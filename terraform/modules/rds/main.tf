#DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "cloud-db-subnet-group-tf"
  subnet_ids = var.private_subnets

  tags = {
    Name = "cloud-db-subnet-group-tf"
  }
}

#RDS Instance
resource "aws_db_instance" "postgres" {
  identifier = "cloud-app-db-tf"

  engine         = "postgres"
  #engine_version = "15.4"       causing error so commented out such that aws will choose the latest version automatically
  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]

  publicly_accessible = false

  skip_final_snapshot = true

  backup_retention_period = 1

  multi_az = false

  tags = {
    Name = "cloud-app-db-tf"
  }
}
