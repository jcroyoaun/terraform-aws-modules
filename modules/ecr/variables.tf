variable "env" {
  description = "Environment name"
  type        = string
}

variable "repositories" {
  description = "Map of ECR repositories to create"
  type = map(object({
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push         = optional(bool, true)
    encryption_type      = optional(string, "AES256")
    kms_key              = optional(string, null)
    lifecycle_policy     = optional(string, null)
    tags                 = optional(map(string), {})
  }))
  default = {}
}

variable "enable_cross_region_replication" {
  description = "Enable cross-region replication for ECR repositories"
  type        = bool
  default     = false
}

variable "replication_destination_region" {
  description = "Destination region for ECR replication"
  type        = string
  default     = "us-west-2"
}

variable "replication_repository_filter" {
  description = "Repository filter for replication (prefix match)"
  type        = string
  default     = ""
}

variable "enable_registry_scanning" {
  description = "Enable enhanced registry scanning"
  type        = bool
  default     = false
}

variable "registry_scan_type" {
  description = "Registry scan type (BASIC or ENHANCED)"
  type        = string
  default     = "ENHANCED"

  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.registry_scan_type)
    error_message = "Registry scan type must be either BASIC or ENHANCED."
  }
}

variable "registry_scan_rules" {
  description = "Registry scanning rules"
  type = list(object({
    repository_filter = string
    scan_frequency    = string
  }))
  default = [
    {
      repository_filter = "*"
      scan_frequency    = "SCAN_ON_PUSH"
    }
  ]
}