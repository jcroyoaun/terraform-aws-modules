variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet configuration"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "create_isolated_subnets" {
  description = "Whether to create isolated subnets"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "EKS cluster name for tagging"
  type        = string
  default     = ""
}

variable "isolated_subnet_cidrs" {
  description = "CIDR blocks for isolated subnets"
  type        = list(string)
  default     = ["10.0.128.0/19", "10.0.160.0/19"]
}

variable "private_subnet_tags" {
  description = "Map of additional tags to apply to private subnets"
  type        = map(string)
  default     = {}
}
