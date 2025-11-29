# IAM Role for External Secrets Operator to access AWS Secrets Manager
data "aws_iam_policy_document" "external_secrets" {
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

resource "aws_iam_role" "external_secrets" {
  for_each           = local.charts_external_secrets
  name               = "${var.cluster_name}-external-secrets-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.external_secrets.json

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_policy" "external_secrets" {
  for_each = local.charts_external_secrets
  name     = "${var.cluster_name}-ExternalSecrets-${each.key}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : [
          "arn:aws:secretsmanager:${var.region}:*:secret:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:ListSecrets"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        "Resource" : [
          "arn:aws:ssm:${var.region}:*:parameter/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeParameters"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  for_each   = local.charts_external_secrets
  policy_arn = aws_iam_policy.external_secrets[each.key].arn
  role       = aws_iam_role.external_secrets[each.key].name
}

