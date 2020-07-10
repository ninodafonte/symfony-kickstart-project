output "selected_ami_webserver" {
  value = aws_instance.webserver.ami
}

output "ip" {
  value = aws_eip.ip.public_ip
}