variable "additional_tags" {
  default     = {
    "Department" = "Automation",
    "Project"    = "Symfony-project-kickstart"
  }
  description = "Additional resource tags"
  type        = map(string)
}

variable "region" {
  default = "eu-west-1"
}

variable "public_key" {
  default = "~/.ssh/key_name_stored_in_your_computer.pub"
}

variable "ami" {
  default = ""
}

variable "ec2_size" {
  default = "t2.micro"
}

variable "private_key" {
  default = "~/.ssh/key_name_stored_in_your_computer.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}

variable "subnet_id" {
  description = "Subnet ID for aws instance"
  default     = ""
}

variable "webserver_private_ip" {
  description = "Private IP for webserver"
  default     = ""
}

variable "dbserver_private_ip" {
  description = "Private IP for dbserver"
  default     = ""
}

variable "key_name" {
  description = "Key name for ssh connection"
  default     = ""
}

variable "iam_instance_profile" {
  description = "Enabling Ec2 instances to use S3"
  default     = ""
}

variable "security_groups_webserver" {
  description = "Security groups for ec2 instances as a webserver"
  default     = []
}

variable "security_groups_dbserver" {
  description = "Security groups for ec2 instances as a dbserver"
  default     = []
}

variable "application_name" {
  description = "Application name to identify ec2 machines for this terraform execution"
  default     = ""
}