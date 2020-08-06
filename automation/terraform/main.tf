provider "aws" {
  profile = var.aws_profile
  region  = var.region
}

resource "aws_key_pair" "terraform_executor_key" {
  key_name   = "terraform_executor"
  public_key = file(var.public_key)
  tags       = var.additional_tags
}

module "network" {
  source                = "./modules/network"
  additional_tags       = var.additional_tags
  cidr_vpc              = var.cidr_vpc
  cidr_subnet           = var.cidr_subnet
  webserver_private_ip  = var.webserver_private_ip
  dbserver_private_ip   = var.dbserver_private_ip
  webserver_instance_id = module.ec2.webserver_instance_id
}

module "ec2" {
  source                    = "./modules/ec2"
  additional_tags           = var.additional_tags
  application_name          = var.application_name
  ami                       = var.amis[var.region]
  subnet_id                 = module.network.subnet_id
  key_name                  = aws_key_pair.terraform_executor_key.key_name
  private_key               = var.private_key
  iam_instance_profile      = module.ci-cd.aws_iam_instance_profile_name
  webserver_private_ip      = var.webserver_private_ip
  dbserver_private_ip       = var.dbserver_private_ip
  security_groups_webserver = [
    module.network.security_group_web_id,
    module.network.security_group_ssh_id,
    module.network.security_group_tls_id,
    module.network.security_group_icmp_id
  ]
  security_groups_dbserver  = [
    module.network.security_group_ssh_id,
    module.network.security_group_tls_id,
    module.network.security_group_icmp_id,
    module.network.security_group_mysql_id
  ]
}

module "ci-cd" {
  source               = "./modules/ci-cd"
  additional_tags      = var.additional_tags
  application_name     = var.application_name
  deployment_s3_bucket = var.deployment_s3_bucket
}
