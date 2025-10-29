# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ECR repositories
resource "aws_ecr_repository" "repositories" {
  for_each = var.repositories

  name                 = each.key
  image_tag_mutability = each.value.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key        = each.value.kms_key
  }

  tags = merge(
    {
      Environment = var.env
      ManagedBy   = "terraform"
      Repository  = each.key
    },
    each.value.tags
  )
}

# Lifecycle policies for repositories
resource "aws_ecr_lifecycle_policy" "policies" {
  for_each = {
    for k, v in var.repositories : k => v
    if v.lifecycle_policy != null
  }

  repository = aws_ecr_repository.repositories[each.key].name

  policy = each.value.lifecycle_policy
}

# Repository policies - Allow root account access (everyone in account can pull)
resource "aws_ecr_repository_policy" "policies" {
  for_each = var.repositories

  repository = aws_ecr_repository.repositories[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchDeleteImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings"
        ]
      },
      {
        Sid    = "AllowRootAccountPush"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
      }
    ]
  })
}

# ECR replication configuration (optional)
resource "aws_ecr_replication_configuration" "replication" {
  count = var.enable_cross_region_replication ? 1 : 0

  replication_configuration {
    rule {
      destination {
        region      = var.replication_destination_region
        registry_id = data.aws_caller_identity.current.account_id
      }

      repository_filter {
        filter      = var.replication_repository_filter
        filter_type = "PREFIX_MATCH"
      }
    }
  }
}

# ECR registry scanning configuration
resource "aws_ecr_registry_scanning_configuration" "scanning" {
  count = var.enable_registry_scanning ? 1 : 0

  scan_type = var.registry_scan_type

  dynamic "rule" {
    for_each = var.registry_scan_rules
    content {
      scan_frequency = rule.value.scan_frequency
      repository_filter {
        filter      = rule.value.repository_filter
        filter_type = "WILDCARD"
      }
    }
  }
}