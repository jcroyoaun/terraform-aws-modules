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
      name           = "system"
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
      "ebs-csi-driver" = {
        repository           = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
        chart                = "aws-ebs-csi-driver"
        version              = "2.36.0"
        namespace            = "kube-system"
        create_namespace     = false
        iam_type             = "ebs-csi"
        service_account_name = "ebs-csi-controller-sa"
        phase                = 1 # Phase 1: Foundation
        values_content = yamlencode({
          controller = {
            serviceAccount = {
              create = true
              name   = "ebs-csi-controller-sa"
            }
          }
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

      "aws-lbc" = {
        repository           = "https://aws.github.io/eks-charts"
        chart                = "aws-load-balancer-controller"
        version              = "1.10.1"
        namespace            = "kube-system"
        create_namespace     = false
        iam_type             = "aws-lbc"
        service_account_name = "aws-load-balancer-controller"
        phase                = 1
        values_content = yamlencode({
          clusterName = "${local.env}-eks-cluster"
          vpcId       = module.vpc.vpc_id
          region      = local.region
          serviceAccount = {
            create = true
            name   = "aws-load-balancer-controller"
          }
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
        phase                = 2
        values_content = yamlencode({
          provider = "aws"
          aws      = { region = local.region }
          serviceAccount = {
            create = true
            name   = "external-dns"
          }
          policy        = "sync"
          txtOwnerId    = "${local.env}-eks-cluster"
          sources       = ["service", "ingress"]
          domainFilters = [module.dns.external_dns_domain_filter]
        })
      },

      "external-secrets" = {
        repository           = "https://charts.external-secrets.io"
        chart                = "external-secrets"
        version              = "0.12.1"
        namespace            = "external-secrets-system"
        create_namespace     = true
        iam_type             = "external-secrets"
        service_account_name = "external-secrets"
        phase                = 2
        values_content = yamlencode({
          installCRDs = true
          serviceAccount = {
            create = true
            name   = "external-secrets"
          }
          webhook = {
            port = 9443
          }
        })
      },

      "metrics-server" = {
        repository       = "https://kubernetes-sigs.github.io/metrics-server"
        chart            = "metrics-server"
        version          = "3.12.2"
        namespace        = "kube-system"
        create_namespace = false
        iam_type         = "none"
        phase            = 2 # Phase 2: Can deploy with other monitoring tools
        values_content = yamlencode({
          defaultArgs = [
            "--cert-dir=/tmp",
            "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
            "--kubelet-use-node-status-port",
            "--metric-resolution=15s",
            "--secure-port=10250"
          ]
        })
      },

      "kube-prometheus-stack" = {
        repository       = "https://prometheus-community.github.io/helm-charts"
        chart            = "kube-prometheus-stack"
        version          = "67.4.0"
        namespace        = "monitoring"
        create_namespace = true
        iam_type         = "none"
        phase            = 2 # Phase 2: Needs storage, LB controller, and external-dns
        values_content = yamlencode({
          prometheus = {
            prometheusSpec = {
              retention = "15d"
              storageSpec = {
                volumeClaimTemplate = {
                  spec = {
                    storageClassName = "gp3"
                    accessModes      = ["ReadWriteOnce"]
                    resources = {
                      requests = {
                        storage = "50Gi"
                      }
                    }
                  }
                }
              }
              resources = {
                requests = {
                  cpu    = "500m"
                  memory = "2Gi"
                }
                limits = {
                  cpu    = "1000m"
                  memory = "4Gi"
                }
              }
            }
          }

          grafana = {
            enabled       = true
            adminPassword = "CHANGEME"

            ingress = {
              enabled          = true
              ingressClassName = "alb"
              annotations = {
                "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
                "alb.ingress.kubernetes.io/target-type"     = "ip"
                "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ HTTPS = 443 }])
                "external-dns.alpha.kubernetes.io/hostname" = "grafana.liftnotebook.jcroyoaun.com"
              }
              hosts = ["grafana.liftnotebook.jcroyoaun.com"]
            }

            persistence = {
              enabled          = true
              storageClassName = "gp3"
              size             = "10Gi"
            }

            resources = {
              requests = {
                cpu    = "100m"
                memory = "256Mi"
              }
              limits = {
                cpu    = "200m"
                memory = "512Mi"
              }
            }
          }
        })
      },

      # Karpenter: Auto-scaler (deploys LAST - has special dependencies)
      "karpenter" = {
        repository           = "oci://public.ecr.aws/karpenter"
        chart                = "karpenter"
        version              = "1.8.1"
        namespace            = "kube-system"
        create_namespace     = false
        iam_type             = "karpenter"
        service_account_name = "karpenter"
        phase                = 2 # Not used for Karpenter, it has custom deployment logic
        values_content = yamlencode({
          serviceAccount = {
            create = true
            name   = "karpenter"
          }
        })
      }
    }
  }
}
