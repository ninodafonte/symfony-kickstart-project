output "public_ip_webserver" {
  value = module.network.elastic_ip
}

output "webserver_private_ip" {
  value = module.ec2.webserver_private_ip
}

output "dbserver_private_ip" {
  value = module.ec2.dbserver_private_ip
}

output "s3_bucket_for_github_configuration" {
  value = module.ci-cd.s3_bucket_for_github_deployment
}