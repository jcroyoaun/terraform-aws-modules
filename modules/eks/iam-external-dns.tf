data "aws_iam_policy_document" "external_dns" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "external_dns" {
  # --- FIX: ADD THIS FOR_EACH ---
  for_each           = local.charts_external_dns
  name               = "${var.cluster_name}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns.json

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_policy" "external_dns" {
  # --- FIX: ADD THIS FOR_EACH ---
  for_each = local.charts_external_dns
  name     = "${var.cluster_name}-ExternalDNS"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : length(var.external_dns_hosted_zone_arns) > 0 ? var.external_dns_hosted_zone_arns : ["arn:aws:route53:::hostedzone/*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  # --- FIX: ADD THIS FOR_EACH ---
  for_each   = local.charts_external_dns
  policy_arn = aws_iam_policy.external_dns[each.key].arn
  role       = aws_iam_role.external_dns[each.key].name
}

# --- THE aws_eks_pod_identity_association BLOCK IS DELETED ---