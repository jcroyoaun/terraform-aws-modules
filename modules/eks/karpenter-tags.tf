# Get private subnets
data "aws_subnets" "private" {
  count = var.enable_karpenter ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

# Tag private subnets for Karpenter
resource "aws_ec2_tag" "private_subnet_karpenter" {
  for_each = var.enable_karpenter ? toset(data.aws_subnets.private[0].ids) : []

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Tag cluster security group for Karpenter
resource "aws_ec2_tag" "cluster_sg_karpenter" {
  count = var.enable_karpenter ? 1 : 0

  resource_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}
