variable "subdomain" {
  description = "The subdomain to create (e.g., 'demo' for demo.jcroyoaun.com)"
  type        = string
}

variable "parent_domain" {
  description = "The parent domain name (e.g., 'jcroyoaun.com')"
  type        = string
}

variable "parent_hosted_zone_id" {
  description = "The hosted zone ID of the parent domain"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "create_delegation_set" {
  description = "Whether to create a delegation set for consistent name servers across environments"
  type        = bool
  default     = false
}