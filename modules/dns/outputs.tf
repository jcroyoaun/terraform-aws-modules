# Hosted Zone outputs
output "hosted_zone_id" {
  description = "The hosted zone ID"
  value       = aws_route53_zone.subdomain.zone_id
}

output "hosted_zone_arn" {
  description = "The hosted zone ARN (for IAM policies)"
  value       = "arn:aws:route53:::hostedzone/${aws_route53_zone.subdomain.zone_id}"
}

output "domain_name" {
  description = "The domain name of the hosted zone"
  value       = aws_route53_zone.subdomain.name
}

output "name_servers" {
  description = "List of name servers for the hosted zone"
  value       = aws_route53_zone.subdomain.name_servers
}

# Outputs specifically for external-dns
output "external_dns_domain_filter" {
  description = "Domain filter for external-dns (removes trailing dot)"
  value       = trimsuffix(aws_route53_zone.subdomain.name, ".")
}

output "external_dns_hosted_zone_arn" {
  description = "Hosted zone ARN for external-dns IAM policy (scoped to subdomain only)"
  value       = "arn:aws:route53:::hostedzone/${aws_route53_zone.subdomain.zone_id}"
}

# Subdomain-specific outputs
output "full_domain" {
  description = "The full subdomain (e.g., demo.jcroyoaun.com)"
  value       = trimsuffix(aws_route53_zone.subdomain.name, ".")
}

output "subdomain" {
  description = "The subdomain part (e.g., demo)"
  value       = var.subdomain
}

output "parent_domain" {
  description = "The parent domain (e.g., jcroyoaun.com)"
  value       = var.parent_domain
}

# TLS Certificate outputs
output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate_validation.subdomain.certificate_arn
}

output "certificate_domain_name" {
  description = "The domain name of the certificate"
  value       = aws_acm_certificate.subdomain.domain_name
}

output "certificate_subject_alternative_names" {
  description = "The subject alternative names of the certificate"
  value       = aws_acm_certificate.subdomain.subject_alternative_names
}

output "certificate_status" {
  description = "The status of the certificate"
  value       = aws_acm_certificate.subdomain.status
}

# Debug outputs to help troubleshoot
output "debug_subdomain" {
  description = "Debug: subdomain variable value"
  value       = var.subdomain
}

output "debug_parent_domain" {
  description = "Debug: parent domain variable value"  
  value       = var.parent_domain
}

output "debug_constructed_domain" {
  description = "Debug: what the module thinks the full domain should be"
  value       = "${var.subdomain}.${var.parent_domain}"
}