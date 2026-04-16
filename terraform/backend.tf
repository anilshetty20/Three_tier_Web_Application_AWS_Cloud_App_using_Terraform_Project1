terraform {
  backend "s3" {
    bucket = "cloudapp-remote-state-tf"
    key = "prod/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}