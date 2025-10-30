locals {
  rendered_manifests = {
    for k, v in var.manifests : k => templatefile(v.file_path, v.vars)
  }
}

resource "kubectl_manifest" "manifests" {
  for_each = local.rendered_manifests

  yaml_body = each.value

  depends_on = [var.cluster_ready_dependency]
}
