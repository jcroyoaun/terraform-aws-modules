resource "aws_eks_pod_identity_association" "all" {
  # This loops over ALL charts that need any IAM
  for_each = local.charts_with_pod_id

  cluster_name    = aws_eks_cluster.main.name
  namespace       = each.value.namespace
  service_account = each.value.service_account_name

  # This looks up the correct ARN from the "phone book" in locals.tf
  role_arn = local.all_role_arns[each.key]

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Chart       = each.key
  }
}
