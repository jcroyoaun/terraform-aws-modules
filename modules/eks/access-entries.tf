resource "aws_eks_access_entry" "cluster_admin" {
  count = length(var.cluster_admin_arns)

  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = var.cluster_admin_arns[count.index]
  kubernetes_groups = []
  type             = "STANDARD"

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
  }
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  count = length(var.cluster_admin_arns)

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.cluster_admin_arns[count.index]
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.cluster_admin]
}