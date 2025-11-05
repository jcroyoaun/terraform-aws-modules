locals {
  region = "us-east-1"
  env    = "dev"

  # DNS configuration
  dns = {
    subdomain             = "liftnotebook"
    parent_domain         = "jcroyoaun.com"
    parent_hosted_zone_id = "Z0018433153XTHTE2Z3K1"
  }

  # ECR repositories
  ecr = {
    repositories = {
      exerciselib = {
        image_tag_mutability = "MUTABLE"
        scan_on_push         = true
      }
      frontend = {
        image_tag_mutability = "MUTABLE"
        scan_on_push         = true
      }
      cevichedbsync = {
        image_tag_mutability = "MUTABLE"
        scan_on_push         = true
      }
    }
  }

  # VPC configuration
  vpc = {
    cidr           = "10.24.0.0/16"
    public_subnets = ["10.24.0.0/24", "10.24.1.0/24"]
    azs            = ["a", "b"]

    private_subnets = {
      private_1 = { cidr = "10.24.16.0/20", az = "a" }
      private_2 = { cidr = "10.24.32.0/20", az = "b" }
    }

    # Isolated subnets for databases
    create_isolated_subnets = true
    isolated_subnet_cidrs   = ["10.24.48.0/24", "10.24.49.0/24"]
  }

  eks = {
    cluster_name       = "${local.env}-eks-cluster"
    kubernetes_version = "1.34"

    node_group = {
      name           = "initial"
      instance_types = ["t3a.medium", "t3a.large"]
      capacity_type  = "SPOT"
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 1
      }
      disk_size = 50
    }

    cluster_admin_arns = [
      "arn:aws:iam::443311183770:user/iamadmin",
      "arn:aws:iam::443311183770:role/Github-Actions-Runner-OIDC"
    ]

    addon_versions = {
      "coredns"                = "v1.11.4-eksbuild.2"
      "vpc-cni"                = "v1.19.2-eksbuild.1"
      "kube-proxy"             = "v1.32.0-eksbuild.2"
      "eks-pod-identity-agent" = "v1.3.4-eksbuild.1"
    }

    charts = {
      "aws-lbc" = {
        repository           = "https://aws.github.io/eks-charts"
        chart                = "aws-load-balancer-controller"
        version              = "1.10.1"
        namespace            = "kube-system"
        create_namespace     = false
        iam_type             = "aws-lbc"
        service_account_name = "aws-load-balancer-controller"
        values_content = yamlencode({
          clusterName = "${local.env}-eks-cluster"
          vpcId       = module.vpc.vpc_id
          region      = local.region
          serviceAccount = {
            create = false
            name   = "aws-load-balancer-controller"
          }
        })
      },

      "ebs-csi-driver" = {
        repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
        chart            = "aws-ebs-csi-driver"
        version          = "2.36.0"
        namespace        = "kube-system"
        create_namespace = false
        # This new type triggers the IAM role you just fixed
        iam_type             = "ebs-csi"
        service_account_name = "ebs-csi-controller-sa"
        values_content = yamlencode({
          controller = {
            serviceAccount = {
              # Let Helm create the ServiceAccount
              create = true
              name   = "ebs-csi-controller-sa"
            }
          }
          # This is the correct block for your StorageClass
          storageClasses = [
            {
              name = "gp3"
              annotations = {
                "storageclass.kubernetes.io/is-default-class" = "true"
              }
              volumeBindingMode = "WaitForFirstConsumer"
              reclaimPolicy     = "Delete"
              parameters = {
                type = "gp3"
              }
            }
          ]
        })
      },

      "external-dns" = {
        repository           = "https://kubernetes-sigs.github.io/external-dns/"
        chart                = "external-dns"
        version              = "1.15.0"
        namespace            = "kube-system"
        create_namespace     = false
        iam_type             = "external-dns"
        service_account_name = "external-dns"
        values_content = yamlencode({
          provider = "aws"
          aws      = { region = local.region }
          serviceAccount = {
            create = false
            name   = "external-dns"
          }
          policy = "sync"
          # 5. Reference local.cluster_name (NOT local.eks.cluster_name)
          txtOwnerId    = "${local.env}-eks-cluster"
          sources       = ["service", "ingress"]
          domainFilters = [module.dns.external_dns_domain_filter]
        })
      },

      "metrics-server" = {
        repository       = "https://kubernetes-sigs.github.io/metrics-server"
        chart            = "metrics-server"
        version          = "3.12.2"
        namespace        = "kube-system"
        create_namespace = false
        iam_type         = "none"
        values_content = yamlencode({
          defaultArgs = [
            "--cert-dir=/tmp",
            "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
            "--kubelet-use-node-status-port",
            "--metric-resolution=15s",
            "--secure-port=10250"
          ]
        })
      }
    }
  }
}