variable "private_subnets" {
  type = list(string)
}

variable "ec2_sg_id" {}
variable "target_group_arn" {}

variable "docker_image" {}
variable "db_endpoint" {}
variable "db_name" {}
variable "db_password" {
  sensitive = true
}
variable "docker_password" {
  sensitive = true
}