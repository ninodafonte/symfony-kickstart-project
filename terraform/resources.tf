resource "aws_key_pair" "terraform_executor_key" {
  key_name   = "terraform_executor"
  public_key = file(var.public_key)
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

  # Ansible requires Python to be installed on the remote machine as well as the local machine.
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -qq install python -y"]
  }

  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = <<EOT
      echo "${aws_instance.webserver.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}";
      export ANSIBLE_HOST_KEY_CHECKING=False;
      ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i jenkins-ci.ini ../playbooks/install_webserver.yaml
    EOT
  }
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

  # Ansible requires Python to be installed on the remote machine as well as the local machine.
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -qq install python -y"]
  }

  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = <<EOT
      echo "${aws_instance.dbserver.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}";
      export ANSIBLE_HOST_KEY_CHECKING=False;
      ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i jenkins-ci.ini ../playbooks/install_dbserver.yaml
    EOT
  }
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
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.webserver.id
}