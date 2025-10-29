locals {
  region = "us-east-1"
  env    = "demo"

  # DNS - UPDATE THESE
  dns = {
    subdomain             = "demo"
    parent_domain         = "jcroyoaun.com"
    parent_hosted_zone_id = "Z0018433153XTHTE2Z3K1"
  }

  # ECR
  ecr = {
    repositories = {
      frontend = {
        image_tag_mutability = "MUTABLE"
        scan_on_push         = true
      }
      backend = {
        image_tag_mutability = "MUTABLE"
        scan_on_push         = true
      }
    }
  }

  # VPC
  vpc = {
    cidr           = "10.24.0.0/16"
    public_subnets = ["10.24.0.0/24", "10.24.1.0/24"]
    azs            = ["a", "b"]

    private_subnets = {
      private_1 = { cidr = "10.24.16.0/20", az = "a" }
      private_2 = { cidr = "10.24.32.0/20", az = "b" }
    }
  }

  # EKS
  eks = {
    cluster_name       = "${local.env}-eks-cluster"
    kubernetes_version = "1.33"

    node_group = {
      name           = "initial"
      instance_types = ["m6a.large"]
      capacity_type  = "SPOT"
      scaling_config = {
        desired_size = 2
        max_size     = 3
        min_size     = 1
      }
      disk_size = 50
    }

    cluster_admin_arns = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/iamadmin"
    ]

    addon_versions = {
      "coredns"                = "v1.11.4-eksbuild.2"
      "vpc-cni"                = "v1.19.2-eksbuild.1"
      "kube-proxy"             = "v1.32.0-eksbuild.2"
      "eks-pod-identity-agent" = "v1.3.4-eksbuild.1"
    }

    helm_chart_versions = {
      aws_load_balancer_controller = "1.10.1"
      external_dns                 = "1.15.0"
    }
  }
}
