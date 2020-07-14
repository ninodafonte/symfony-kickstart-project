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

variable "application_name" {
  default = "someApplication"
}
