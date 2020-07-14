output "webserver_instance_id" {
  value = aws_instance.webserver.id
}

output "webserver_private_ip" {
  value = aws_instance.webserver.private_ip
}

output "dbserver_private_ip" {
  value = aws_instance.dbserver.private_ip
}