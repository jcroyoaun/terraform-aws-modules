# Helper to check if the EBS addon is enabled
locals {
  ebs_csi_enabled = lookup(var.addon_versions, "aws-ebs-csi-driver", null) != null
}

# 1. IAM Role for the EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  count = local.ebs_csi_enabled ? 1 : 0
  name  = "${var.cluster_name}-ebs-csi-driver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Component   = "ebs-csi-driver"
  }
}

# 2. Attach the AWS Managed Policy
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  count = local.ebs_csi_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver[0].name
}

# 3. Associate the Role with the Addon's Service Account
resource "aws_eks_pod_identity_association" "ebs_csi_driver" {
  count = local.ebs_csi_enabled ? 1 : 0

  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa" # This is the default SA name for the addon
  role_arn        = aws_iam_role.ebs_csi_driver[0].arn

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Component   = "ebs-csi-driver"
  }

  # Make sure this runs AFTER the addon is installed
  depends_on = [
    aws_eks_addon.cluster_addons["aws-ebs-csi-driver"]
  ]
}
