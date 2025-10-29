resource "aws_eks_addon" "cluster_addons" {
  for_each = var.addon_versions

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = each.value
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
  }

  depends_on = [aws_eks_node_group.initial]
}