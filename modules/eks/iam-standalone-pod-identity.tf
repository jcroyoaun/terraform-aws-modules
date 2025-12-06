# Standalone Pod Identity Associations (not tied to Helm charts)
# These allow you to create namespace/service-account -> IAM role mappings
# for apps deployed outside of Terraform (kubectl, kustomize, CI/CD, etc.)

resource "aws_iam_role" "standalone_pod_identity" {
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

  tags = merge(
    {
      Environment = var.env
      Cluster     = var.cluster_name
      ManagedBy   = "terraform"
      Type        = "standalone-pod-identity"
    },
    each.value.description != "" ? { Description = each.value.description } : {}
  )
}

# Create custom IAM policies for each standalone pod identity
resource "aws_iam_policy" "standalone_pod_identity" {
  for_each = var.pod_identity_associations

  name   = "${var.cluster_name}-${each.key}-policy"
  policy = each.value.iam_policy_json

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Type        = "standalone-pod-identity"
  }
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "standalone_pod_identity" {
  for_each = var.pod_identity_associations

  policy_arn = aws_iam_policy.standalone_pod_identity[each.key].arn
  role       = aws_iam_role.standalone_pod_identity[each.key].name
}

# Create EKS Pod Identity Associations
resource "aws_eks_pod_identity_association" "standalone" {
  for_each = var.pod_identity_associations

  cluster_name    = aws_eks_cluster.main.name
  namespace       = each.value.namespace
  service_account = each.value.service_account

  role_arn = aws_iam_role.standalone_pod_identity[each.key].arn

  tags = merge(
    {
      Environment = var.env
      Cluster     = var.cluster_name
      ManagedBy   = "terraform"
      Type        = "standalone-pod-identity"
    },
    each.value.description != "" ? { Description = each.value.description } : {}
  )
}

