resource "helm_release" "generic_charts" {
  for_each = var.helm_charts

  name       = each.value.chart
  repository = each.value.repository
  chart      = each.value.chart
  version    = each.value.version
  namespace  = each.value.namespace

  # Use values content if provided
  values = each.value.values_content != "" ? [each.value.values_content] : []

  # If pod_identity is specified, ensure the pod identity association exists first
  depends_on = [
    aws_eks_pod_identity_association.generic_associations,
    aws_eks_node_group.initial
  ]
}