resource "aws_key_pair" "terraform_executor_key" {
  key_name   = "terraform_executor"
  public_key = file(var.public_key)
  tags       = var.additional_tags
}

resource "aws_instance" "webserver" {
  ami           = var.amis[var.region]
  instance_type = var.ec2_size
  key_name      = aws_key_pair.terraform_executor_key.key_name

  vpc_security_group_ids = [
    aws_security_group.web.id,
    aws_security_group.ssh.id,
    aws_security_group.egress-tls.id,
    aws_security_group.ping-ICMP.id
  ]

  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 20
    delete_on_termination = true
  }

  connection {
    host        = self.public_ip
    private_key = file(var.private_key)
    user        = var.ansible_user
  }

  # Just saying hello to our new machine -this workaround makes the local-exec waits until the machine is available for ssh
  provisioner "remote-exec" {
    inline = [
      "echo 'hello, world'"]

    connection {
      type        = "ssh"
      user        = var.ansible_user
      private_key = file(var.private_key)
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.ansible_user} -i '${self.public_ip},' --private-key ${var.private_key} ../ansible/webserver.yml"
  }

  tags = var.additional_tags
}

resource "aws_instance" "dbserver" {
  ami           = var.amis[var.region]
  instance_type = var.ec2_size
  key_name      = aws_key_pair.terraform_executor_key.key_name

  vpc_security_group_ids = [
    aws_security_group.web.id,
    aws_security_group.ssh.id,
    aws_security_group.egress-tls.id,
    aws_security_group.ping-ICMP.id
  ]

  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 20
    delete_on_termination = true
  }

  connection {
    host        = self.public_ip
    private_key = file(var.private_key)
    user        = var.ansible_user
  }

  # Just saying hello to our new machine -this workaround makes the local-exec waits until the machine is available for ssh
  provisioner "remote-exec" {
    inline = [
      "echo 'hello, world'"]

    connection {
      type        = "ssh"
      user        = var.ansible_user
      private_key = file(var.private_key)
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.ansible_user} -i '${self.public_ip},' --private-key ${var.private_key} ../ansible/database_server.yml"
  }

  tags = var.additional_tags
}

resource "aws_security_group" "web" {
  name        = "default-web"
  description = "Security group for web that allows web traffic from internet"

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
  #vpc_id      = "${aws_vpc.my-vpc.id}"

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

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.webserver.id

  tags = var.additional_tags
}