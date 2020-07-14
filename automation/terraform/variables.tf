variable "aws_profile" {
  default = "someAWSProfileNameInYourComputer"
}

variable "region" {
  default = "eu-west-1"
}

variable "public_key" {
  default = "~/.ssh/key_name_stored_in_your_computer.pub"
}

variable "amis" {
  default = {
    "eu-west-1" = "ami-049f322a544cfcf88"
    # Ubuntu in eu-west-1
  }
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

variable "additional_tags" {
  default     = {
    "Department" = "Automation",
    "Project"    = "Symfony-project-kickstart"
  }
  description = "Additional resource tags"
  type        = map(string)
}

variable "deployment_s3_bucket" {
  default = "someBucketName"
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.1.0.0/24"
}

variable "webserver_private_ip" {
  description = "Private IP for webserver"
  default     = "10.1.0.1"
}

variable "dbserver_private_ip" {
  description = "Private IP for dbserver"
  default     = "10.1.0.2"
}

variable "application_name" {
  description = "Application name to identify ec2 machines for this terraform execution"
  default     = "someApplication"
}
