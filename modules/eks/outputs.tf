output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = aws_eks_cluster.main.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = aws_eks_node_group.initial.arn
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.main.name}"
}

output "karpenter_node_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = local.enable_karpenter ? aws_iam_role.karpenter_node[0].arn : null
}

output "karpenter_node_role_name" {
  description = "Name of the Karpenter node IAM role (without path)"
  value       = local.enable_karpenter ? aws_iam_role.karpenter_node[0].name : null
}

output "karpenter_helm_release" {
  description = "Karpenter Helm release for dependency management"
  value       = local.enable_karpenter ? helm_release.karpenter : null
}

output "karpenter_queue_name" {
  description = "Name of the Karpenter SQS interruption queue"
  value       = local.enable_karpenter ? aws_sqs_queue.karpenter_interruption[0].name : null
}

output "standalone_pod_identity_role_arns" {
  description = "Map of standalone pod identity association names to IAM role ARNs"
  value       = { for k, v in aws_iam_role.standalone_pod_identity : k => v.arn }
}

output "standalone_pod_identity_associations" {
  description = "Map of standalone pod identity association details"
  value = {
    for k, v in aws_eks_pod_identity_association.standalone : k => {
      namespace       = v.namespace
      service_account = v.service_account
      role_arn        = v.role_arn
    }
  }
}