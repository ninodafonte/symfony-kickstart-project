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
  name             = "symfony_project_kickstart_${var.application_name}"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = aws_codedeploy_app.symfony_project_kickstart.name
  deployment_group_name = "SPK_Deployment_Group_Webservers"
  service_role_arn      = aws_iam_role.code_deploy_executor_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Application"
      type  = "KEY_AND_VALUE"
      value = "${var.application_name}_webserver"
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

