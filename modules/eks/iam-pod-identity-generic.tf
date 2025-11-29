resource "aws_iam_role" "pod_identity_roles" {
  # --- FIX: USE NEW LOCAL ---
  for_each = local.charts_generic_pod_id

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
  }
}

# Create custom IAM policies for each pod identity
resource "aws_iam_policy" "pod_identity_policies" {
  # --- FIX: USE NEW LOCAL ---
  for_each = local.charts_generic_pod_id

  name = "${var.cluster_name}-${each.key}-policy"
  # --- FIX: USE NEW VAR STRUCTURE ---
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
  # --- FIX: USE NEW LOCAL ---
  for_each = local.charts_generic_pod_id

  policy_arn = aws_iam_policy.pod_identity_policies[each.key].arn
  role       = aws_iam_role.pod_identity_roles[each.key].name
}

# --- THE aws_eks_pod_identity_association BLOCK IS DELETED ---