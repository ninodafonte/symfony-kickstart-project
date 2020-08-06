resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.additional_tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.additional_tags
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_subnet
  map_public_ip_on_launch = "true"
  tags                    = var.additional_tags
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.additional_tags
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = var.webserver_instance_id

  tags = var.additional_tags
}

resource "aws_security_group" "web" {
  name        = "default-web"
  description = "Security group for web that allows web traffic from internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = var.additional_tags
}

resource "aws_security_group" "ssh" {
  name        = "default-ssh"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress-tls" {
  name        = "default-egress-tls"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = var.additional_tags
}

resource "aws_security_group" "ping-ICMP" {
  name        = "default-ping"
  description = "Default security group that allows to ping the instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = [
      "0.0.0.0/0"]
    ipv6_cidr_blocks = [
      "::/0"]
  }

  tags = var.additional_tags
}

resource "aws_security_group" "mysql" {
  name        = "default-mysql"
  description = "Default security group that allows to access mysql instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [
      aws_security_group.web.id]
  }

  tags = var.additional_tags
}