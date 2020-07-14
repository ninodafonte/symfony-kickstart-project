output "s3_bucket_for_github_deployment" {
  value = aws_s3_bucket.github_codedeploy_bucket.bucket
}

output "aws_iam_instance_profile_name" {
  value = aws_iam_instance_profile.access_to_s3_for_ec2_profile.name
}