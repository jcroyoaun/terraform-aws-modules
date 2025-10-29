# Repository outputs
output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    for k, v in aws_ecr_repository.repositories : k => v.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for k, v in aws_ecr_repository.repositories : k => v.arn
  }
}

output "repository_registry_ids" {
  description = "Map of repository names to their registry IDs"
  value = {
    for k, v in aws_ecr_repository.repositories : k => v.registry_id
  }
}

# Docker login command
output "docker_login_command" {
  description = "Command to authenticate Docker with ECR"
  value       = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

# Individual repository details
output "repositories" {
  description = "Detailed information about each repository"
  value = {
    for k, v in aws_ecr_repository.repositories : k => {
      name           = v.name
      arn            = v.arn
      registry_id    = v.registry_id
      repository_url = v.repository_url
      tags           = v.tags
    }
  }
}

# Registry information
output "registry_id" {
  description = "ECR registry ID (AWS account ID)"
  value       = data.aws_caller_identity.current.account_id
}

output "registry_url" {
  description = "ECR registry URL"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

# Useful for CI/CD pipelines
output "push_commands" {
  description = "Docker commands to build, tag, and push images to each repository"
  value = {
    for k, v in aws_ecr_repository.repositories : k => {
      login        = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${v.repository_url}"
      build        = "docker build -t ${k} ."
      tag          = "docker tag ${k}:latest ${v.repository_url}:latest"
      push         = "docker push ${v.repository_url}:latest"
      full_command = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${v.repository_url} && docker build -t ${k} . && docker tag ${k}:latest ${v.repository_url}:latest && docker push ${v.repository_url}:latest"
    }
  }
}

# For Kubernetes deployments
output "image_uris" {
  description = "Full image URIs for Kubernetes deployments (with :latest tag)"
  value = {
    for k, v in aws_ecr_repository.repositories : k => "${v.repository_url}:latest"
  }
}