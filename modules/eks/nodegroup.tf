resource "aws_eks_node_group" "initial" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_types
  
  scaling_config {
    desired_size = var.node_scaling_config.desired_size
    max_size     = var.node_scaling_config.max_size
    min_size     = var.node_scaling_config.min_size
  }

  disk_size = var.node_disk_size
  ami_type  = var.node_ami_type

  # Enable node auto-repair
  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "initial"
    type = lower(var.node_capacity_type)
  }

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
    ManagedBy   = "terraform"
    Name        = "${var.cluster_name}-${var.node_group_name}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.nodes_amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.nodes_amazon_ec2_container_registry_read_only,
    aws_iam_role_policy_attachment.nodes_amazon_ssm_managed_instance_core,
  ]
}
