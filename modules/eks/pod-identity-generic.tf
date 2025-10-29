resource "aws_iam_role" "pod_identity_roles" {
  for_each = var.pod_identity_associations

  name = "${var.cluster_name}-${each.key}"

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
    PodIdentity = each.key
    Description = each.value.description
  }
}

# Create custom IAM policies for each pod identity
resource "aws_iam_policy" "pod_identity_policies" {
  for_each = var.pod_identity_associations

  name   = "${var.cluster_name}-${each.key}-policy"
  policy = each.value.iam_policy_json

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    PodIdentity = each.key
  }
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "pod_identity_attachments" {
  for_each = var.pod_identity_associations

  policy_arn = aws_iam_policy.pod_identity_policies[each.key].arn
  role       = aws_iam_role.pod_identity_roles[each.key].name
}

# Create pod identity associations
resource "aws_eks_pod_identity_association" "generic_associations" {
  for_each = var.pod_identity_associations

  cluster_name    = aws_eks_cluster.main.name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = aws_iam_role.pod_identity_roles[each.key].arn

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    PodIdentity = each.key
  }
}
