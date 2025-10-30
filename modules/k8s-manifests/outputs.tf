output "applied_manifests" {
  description = "List of manifest names that were applied"
  value       = keys(kubectl_manifest.manifests)
}
