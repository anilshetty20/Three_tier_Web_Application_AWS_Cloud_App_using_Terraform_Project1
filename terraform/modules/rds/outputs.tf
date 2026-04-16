output "db_host" {
  value = split(":", aws_db_instance.postgres.endpoint)[0]
}

output "db_port" {
  value = split(":", aws_db_instance.postgres.endpoint)[1]
}