locals {
  # Group charts by phase (excluding Karpenter - it has special deployment)
  charts_by_phase = {
    for phase in distinct([for k, v in var.charts : v.phase if v.iam_type != "karpenter"]) :
    phase => {
      for k, v in var.charts : k => v if v.phase == phase && v.iam_type != "karpenter"
    }
  }
}

# Phase 1: Foundation charts (EBS CSI, LB Controller) - deploy in parallel
resource "helm_release" "charts_phase_1" {
  for_each = try(local.charts_by_phase[1], {})

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

# Phase 2: Everything else (DNS, metrics, monitoring, etc) - wait for phase 1
resource "helm_release" "charts_phase_2" {
  for_each = try(local.charts_by_phase[2], {})

  name             = each.value.chart
  repository       = each.value.repository
  chart            = each.value.chart
  version          = each.value.version
  namespace        = each.value.namespace
  create_namespace = each.value.create_namespace
  values           = each.value.values_content != "" ? [each.value.values_content] : []

  depends_on = [
    helm_release.charts_phase_1
  ]
}

# Phase 3: Optional for future use
resource "helm_release" "charts_phase_3" {
  for_each = try(local.charts_by_phase[3], {})

  name             = each.value.chart
  repository       = each.value.repository
  chart            = each.value.chart
  version          = each.value.version
  namespace        = each.value.namespace
  create_namespace = each.value.create_namespace
  values           = each.value.values_content != "" ? [each.value.values_content] : []

  depends_on = [
    helm_release.charts_phase_2
  ]
}

# Special: Karpenter Helm Release (requires infrastructure to be ready first)
# Karpenter must be deployed LAST, after all other charts and its infrastructure
resource "helm_release" "karpenter" {
  for_each = local.charts_karpenter

  name             = each.value.chart
  repository       = each.value.repository
  chart            = each.value.chart
  version          = each.value.version
  namespace        = each.value.namespace
  create_namespace = each.value.create_namespace

  # Merge user values with required Karpenter settings
  values = [
    each.value.values_content != "" ? each.value.values_content : "{}",
    yamlencode({
      settings = {
        clusterName       = var.cluster_name
        clusterEndpoint   = aws_eks_cluster.main.endpoint
        interruptionQueue = try(aws_sqs_queue.karpenter_interruption[0].name, "")
      }
    })
  ]

  # Karpenter needs:
  # 1. Phase 2 to be complete (AWS LB Controller especially)
  # 2. All Karpenter infrastructure (SQS, EventBridge, IAM)
  depends_on = [
    helm_release.charts_phase_2,
    aws_sqs_queue.karpenter_interruption,
    aws_cloudwatch_event_rule.karpenter_scheduled_change,
    aws_cloudwatch_event_rule.karpenter_spot_interruption,
    aws_cloudwatch_event_rule.karpenter_rebalance,
    aws_cloudwatch_event_rule.karpenter_instance_state_change
  ]
}