resource "aws_eks_pod_identity_association" "karpenter" {
  count = var.enable_karpenter ? 1 : 0

  cluster_name    = aws_eks_cluster.main.name
  namespace       = var.karpenter_namespace
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter_controller[0].arn

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Component   = "karpenter"
  }

  depends_on = [
    aws_eks_addon.cluster_addons["eks-pod-identity-agent"]
  ]
}