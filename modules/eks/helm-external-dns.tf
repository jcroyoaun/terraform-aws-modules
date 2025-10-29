resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = var.helm_chart_versions.external_dns

  set = concat([
    {
      name  = "provider"
      value = "aws"
    },
    {
      name  = "aws.region"
      value = var.region
    },
    {
      name  = "serviceAccount.name"
      value = "external-dns"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "policy"
      value = "sync"
    },
    {
      name  = "registry"
      value = "txt"
    },
    {
      name  = "txtOwnerId"
      value = aws_eks_cluster.main.name
    },
    {
      name  = "logLevel"
      value = "info"
    },
    {
      name  = "sources[0]"
      value = "service"
    },
    {
      name  = "sources[1]"
      value = "ingress"
    }
  ], [
    # Add domain filters if specified
    for i, domain in var.external_dns_domain_filters : {
      name  = "domainFilters[${i}]"
      value = domain
    }
  ])

  depends_on = [
    aws_eks_pod_identity_association.external_dns,
    aws_eks_node_group.initial
  ]
}