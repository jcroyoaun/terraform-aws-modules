resource "helm_release" "karpenter" {
  count = var.enable_karpenter ? 1 : 0

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version
  namespace  = var.karpenter_namespace

  create_namespace = false # We use kube-system

  set = [
    {
      name  = "settings.clusterName"
      value = var.cluster_name
    },
    {
      name  = "settings.interruptionQueue"
      value = "${var.cluster_name}-karpenter"
    },
    {
      name  = "controller.resources.requests.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.requests.memory"
      value = "1Gi"
    },
    {
      name  = "controller.resources.limits.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.limits.memory"
      value = "1Gi"
    }
  ]

  depends_on = [
    aws_eks_pod_identity_association.karpenter,
    helm_release.aws_lbc,
    aws_sqs_queue.karpenter_interruption,
    aws_cloudwatch_event_rule.karpenter_scheduled_change,
    aws_cloudwatch_event_rule.karpenter_spot_interruption,
    aws_cloudwatch_event_rule.karpenter_rebalance,
    aws_cloudwatch_event_rule.karpenter_instance_state_change
  ]
}