region = "us-east-1"

vpc_name = "my-cloudapp-vpc-tf"
vpc_cidr = "10.0.0.0/16"

availability_zones = ["us-east-1a", "us-east-1b"]

public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

db_name     = "cloud_app_db_tf"
db_username = "postgres"
db_password = "terraform123"
docker_image = "anil1576/cloud-backend-terraform:latest"
