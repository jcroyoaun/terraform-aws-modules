output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubectl_config_command" {
  value = module.eks.kubectl_config_command
}

output "domain_name" {
  value = module.dns.domain_name
}

output "certificate_arn" {
  value = module.dns.certificate_arn
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "ecr_docker_login_command" {
  value = module.ecr.docker_login_command
}
