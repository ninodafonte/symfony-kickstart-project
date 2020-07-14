output "elastic_ip" {
  value = aws_eip.ip.public_ip
}

output "subnet_id" {
  value = aws_subnet.subnet_public.id
}

output "security_group_web_id" {
  value = aws_security_group.web.id
}

output "security_group_ssh_id" {
  value = aws_security_group.ssh.id
}

output "security_group_tls_id" {
  value = aws_security_group.egress-tls.id
}

output "security_group_icmp_id" {
  value = aws_security_group.ping-ICMP.id
}