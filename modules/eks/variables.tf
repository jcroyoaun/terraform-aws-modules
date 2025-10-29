variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for load balancers"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "cluster_admin_arns" {
  description = "List of IAM ARNs to grant cluster admin access"
  type        = list(string)
  default     = []
}

# Node group configuration
variable "node_group_name" {
  description = "Name for the initial node group"
  type        = string
}

variable "node_instance_types" {
  description = "Instance types for the node group"
  type        = list(string)
}

variable "node_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type        = string
}

variable "node_scaling_config" {
  description = "Scaling configuration for the node group"
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
}

variable "node_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  type        = string
  default     = "AL2_x86_64"
}

# Addon versions
variable "addon_versions" {
  description = "Map of AWS addon names to versions"
  type        = map(string)
  default     = {}
}

# Cluster configuration
variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_cluster_logging" {
  description = "Whether to enable cluster logging"
  type        = bool
  default     = false
}

variable "cluster_log_types" {
  description = "List of cluster log types to enable"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Number of days to retain cluster logs"
  type        = number
  default     = 30
}


variable "helm_chart_versions" {
  description = "Versions for Helm charts"
  type = object({
    aws_load_balancer_controller = string
    external_dns                 = string
  })
}


variable "pod_identity_associations" {
  description = "Map of pod identity associations to create"
  type = map(object({
    namespace       = string
    service_account = string
    iam_policy_json = string # Custom IAM policy as JSON string
    description     = optional(string, "")
  }))
  default = {}
}

# Generic helm charts with values files
variable "helm_charts" {
  description = "Map of helm charts to deploy"
  type = map(object({
    repository     = string
    chart          = string
    version        = string
    namespace      = string
    values_content = optional(string, "") # YAML values as string
    pod_identity   = optional(string, "") # Reference to pod_identity_associations key
  }))
  default = {}
}

# External DNS configuration
variable "external_dns_domain_filters" {
  description = "List of domains that external-dns will manage (empty list means all domains)"
  type        = list(string)
  default     = []
}

variable "external_dns_hosted_zone_arns" {
  description = "List of Route53 hosted zone ARNs that external-dns can modify (empty list means all zones)"
  type        = list(string)
  default     = []
}
