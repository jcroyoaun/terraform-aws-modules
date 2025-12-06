resource "aws_eks_addon" "cluster_addons" {
  for_each = var.addon_versions

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = each.value
  resolve_conflicts_on_update = "OVERWRITE"

  # Custom configuration for CoreDNS to add tolerations and node selectors
  configuration_values = each.key == "coredns" && (length(var.coredns_tolerations) > 0 || length(var.coredns_node_selector) > 0) ? jsonencode({
    tolerations  = var.coredns_tolerations
    nodeSelector = var.coredns_node_selector
  }) : null

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
  }

  depends_on = [aws_eks_node_group.initial]
}