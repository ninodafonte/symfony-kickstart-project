resource "aws_key_pair" "terraform_executor_key" {
  key_name   = "terraform_executor"
  public_key = file(var.public_key)
  tags       = var.additional_tags
}

resource "aws_instance" "webserver" {
  ami                  = var.amis[var.region]
  instance_type        = var.ec2_size
  key_name             = aws_key_pair.terraform_executor_key.key_name
  iam_instance_profile = aws_iam_instance_profile.access_to_s3_for_ec2_profile.name
  tags                 = merge(var.additional_tags, {
    "Role" = "SPK_WebServer"
  })

  vpc_security_group_ids = [
    aws_security_group.web.id,
    aws_security_group.ssh.id,
    aws_security_group.egress-tls.id,
    aws_security_group.ping-ICMP.id
  ]

  root_block_device {
    volume_size = 20
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
    command = "ansible-playbook -u ${var.ansible_user} -i '${self.public_ip},' --private-key ${var.private_key} ../ansible/web_server.yml"
  }
}

resource "aws_instance" "dbserver" {
  ami                  = var.amis[var.region]
  instance_type        = var.ec2_size
  key_name             = aws_key_pair.terraform_executor_key.key_name
  iam_instance_profile = aws_iam_instance_profile.access_to_s3_for_ec2_profile.name
  tags                 = merge(var.additional_tags, {
    "Role" = "SPK_DBServer"
  })

  vpc_security_group_ids = [
    aws_security_group.web.id,
    aws_security_group.ssh.id,
    aws_security_group.egress-tls.id,
    aws_security_group.ping-ICMP.id
  ]

  root_block_device {
    volume_size = 20
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

resource "aws_iam_role" "code_deploy_executor_role" {
  name = "code_deploy_executor_role"
  tags = var.additional_tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.code_deploy_executor_role.name
}

resource "aws_codedeploy_app" "symfony_project_kickstart" {
  compute_platform = "Server"
  name             = "symfony_project_kickstart"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = aws_codedeploy_app.symfony_project_kickstart.name
  deployment_group_name = "SPK_Deployment_Group_Webservers"
  service_role_arn      = aws_iam_role.code_deploy_executor_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Role"
      type  = "KEY_AND_VALUE"
      value = "SPK_WebServer"
    }
  }
}

resource "aws_s3_bucket" "github_codedeploy_bucket" {
  bucket = var.deployment_s3_bucket
  acl    = "private"
  tags   = var.additional_tags
}

resource "aws_iam_role" "access_to_s3_for_ec2_role" {
  name = "access_to_s3_for_ec2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.additional_tags
}

resource "aws_iam_instance_profile" "access_to_s3_for_ec2_profile" {
  name = "access_to_s3_for_ec2_profile"
  role = aws_iam_role.access_to_s3_for_ec2_role.name
}

resource "aws_iam_role_policy" "access_to_s3_for_ec2_policy" {
  name = "access_to_s3_for_ec2_policy"
  role = aws_iam_role.access_to_s3_for_ec2_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

