locals {
  charts_aws_lbc          = { for k, c in var.charts : k => c if c.iam_type == "aws-lbc" }
  charts_external_dns     = { for k, c in var.charts : k => c if c.iam_type == "external-dns" }
  charts_karpenter        = { for k, c in var.charts : k => c if c.iam_type == "karpenter" }
  charts_generic_pod_id   = { for k, c in var.charts : k => c if c.iam_type == "generic_pod_identity" }
  charts_ebs_csi          = { for k, c in var.charts : k => c if c.iam_type == "ebs-csi" }
  charts_external_secrets = { for k, c in var.charts : k => c if c.iam_type == "external-secrets" }

  charts_with_pod_id = {
    for k, c in var.charts : k => c
    if contains(["aws-lbc", "external-dns", "karpenter", "generic_pod_identity", "ebs-csi", "external-secrets"], c.iam_type)
  }

  all_role_arns = merge(
    { for k, v in local.charts_aws_lbc : k => aws_iam_role.aws_lbc[k].arn },
    { for k, v in local.charts_external_dns : k => aws_iam_role.external_dns[k].arn },
    { for k, v in local.charts_karpenter : k => aws_iam_role.karpenter_controller[0].arn },
    { for k, v in local.charts_generic_pod_id : k => aws_iam_role.pod_identity_roles[k].arn },
    { for k, v in local.charts_ebs_csi : k => aws_iam_role.ebs_csi_driver[k].arn },
    { for k, v in local.charts_external_secrets : k => aws_iam_role.external_secrets[k].arn }
  )

  enable_karpenter = length(local.charts_karpenter) > 0
}