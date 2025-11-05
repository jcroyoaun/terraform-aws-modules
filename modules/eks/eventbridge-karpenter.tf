resource "aws_cloudwatch_event_rule" "karpenter_scheduled_change" {
  count = local.enable_karpenter ? 1 : 0

  name        = "${var.cluster_name}-karpenter-scheduled-change"
  description = "Karpenter interrupt - AWS health event"

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
  })

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Component   = "karpenter"
  }
}

resource "aws_cloudwatch_event_target" "karpenter_scheduled_change" {
  count = local.enable_karpenter ? 1 : 0

  rule = aws_cloudwatch_event_rule.karpenter_scheduled_change[0].name
  arn  = aws_sqs_queue.karpenter_interruption[0].arn
}

resource "aws_cloudwatch_event_rule" "karpenter_spot_interruption" {
  count = local.enable_karpenter ? 1 : 0

  name        = "${var.cluster_name}-karpenter-spot-interruption"
  description = "Karpenter interrupt - EC2 spot interruption warning"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Spot Instance Interruption Warning"]
  })

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Component   = "karpenter"
  }
}

resource "aws_cloudwatch_event_target" "karpenter_spot_interruption" {
  count = local.enable_karpenter ? 1 : 0

  rule = aws_cloudwatch_event_rule.karpenter_spot_interruption[0].name
  arn  = aws_sqs_queue.karpenter_interruption[0].arn
}

resource "aws_cloudwatch_event_rule" "karpenter_rebalance" {
  count = local.enable_karpenter ? 1 : 0

  name        = "${var.cluster_name}-karpenter-rebalance"
  description = "Karpenter interrupt - EC2 rebalance recommendation"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance Rebalance Recommendation"]
  })

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Component   = "karpenter"
  }
}

resource "aws_cloudwatch_event_target" "karpenter_rebalance" {
  count = local.enable_karpenter ? 1 : 0

  rule = aws_cloudwatch_event_rule.karpenter_rebalance[0].name
  arn  = aws_sqs_queue.karpenter_interruption[0].arn
}

resource "aws_cloudwatch_event_rule" "karpenter_instance_state_change" {
  count = local.enable_karpenter ? 1 : 0

  name        = "${var.cluster_name}-karpenter-instance-state-change"
  description = "Karpenter interrupt - EC2 instance state change"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
  })

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Component   = "karpenter"
  }
}

resource "aws_cloudwatch_event_target" "karpenter_instance_state_change" {
  count = local.enable_karpenter ? 1 : 0

  rule = aws_cloudwatch_event_rule.karpenter_instance_state_change[0].name
  arn  = aws_sqs_queue.karpenter_interruption[0].arn
}