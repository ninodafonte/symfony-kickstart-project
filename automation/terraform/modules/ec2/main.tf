resource "aws_instance" "webserver" {
  ami                    = var.ami
  instance_type          = var.ec2_size
  subnet_id              = var.subnet_id
  private_ip             = var.webserver_private_ip
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
  tags                   = merge(var.additional_tags, {
    "Application" = "${var.application_name}_webserver"
  })
  vpc_security_group_ids = var.security_groups_webserver

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
  ami                  = var.ami
  instance_type        = var.ec2_size
  subnet_id            = var.subnet_id
  private_ip           = var.dbserver_private_ip
  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile
  tags                 = merge(var.additional_tags, {
    "Application" = "${var.application_name}_dbserver"
  })

  vpc_security_group_ids = var.security_groups_dbserver

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