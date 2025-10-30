resource "aws_sqs_queue" "karpenter_interruption" {
  count = var.enable_karpenter ? 1 : 0

  name                      = "${var.cluster_name}-karpenter"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Component   = "karpenter"
  }
}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  count = var.enable_karpenter ? 1 : 0

  queue_url = aws_sqs_queue.karpenter_interruption[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "events.amazonaws.com",
            "sqs.amazonaws.com"
          ]
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter_interruption[0].arn
      },
      {
        Sid       = "DenyHTTP"
        Effect    = "Deny"
        Principal = "*"
        Action    = "sqs:*"
        Resource  = aws_sqs_queue.karpenter_interruption[0].arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}