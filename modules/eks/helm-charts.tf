resource "helm_release" "charts" {
  for_each = var.charts

  name             = each.value.chart
  repository       = each.value.repository
  chart            = each.value.chart
  version          = each.value.version
  namespace        = each.value.namespace
  create_namespace = each.value.create_namespace
  values           = each.value.values_content != "" ? [each.value.values_content] : []

  depends_on = [
    aws_eks_node_group.initial,
    aws_eks_addon.cluster_addons["eks-pod-identity-agent"],

    aws_eks_pod_identity_association.all
  ]
}