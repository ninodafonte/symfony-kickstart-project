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

variable "additional_tags" {
  default     = {
    "Department" = "Automation",
    "Project"    = "Symfony-project-kickstart"
  }
  description = "Additional resource tags"
  type        = map(string)
}

variable "webserver_instance_id" {
  description = "Instance ID to link to elastic ip (webserver)"
  default     = ""
}