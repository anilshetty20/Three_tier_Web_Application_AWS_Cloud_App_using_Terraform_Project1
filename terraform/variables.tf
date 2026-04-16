variable "region" {
  default = "us-east-1"
}

# VPC
variable "vpc_name" {}
variable "vpc_cidr" {}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

#RDS
variable "db_name" {
  default = "cloud_app_db_tf"
}

variable "db_username" {
  default = "postgres"
}

variable "db_password" {
  sensitive = true
}

variable "docker_image" {}

variable "db_endpoint" {}

variable "docker_password" {
  sensitive = true
}


