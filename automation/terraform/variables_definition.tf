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
  default = "t3a.micro"
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