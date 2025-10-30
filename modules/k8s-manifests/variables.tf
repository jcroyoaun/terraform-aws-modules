variable "manifests" {
  description = "Map of Kubernetes manifests with template variables"
  type = map(object({
    file_path = string
    vars      = map(string)
  }))
  default = {}
}

variable "cluster_ready_dependency" {
  description = "Dependency to ensure cluster and required components are ready"
  type        = any
  default     = null
}

variable "cluster_name" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}
