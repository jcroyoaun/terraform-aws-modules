# Fixed DNS module - explicit subdomain creation

# Local values for debugging
locals {
  subdomain_name = "${var.subdomain}.${var.parent_domain}"
  
  # Debug outputs
  debug_subdomain = var.subdomain          # Should be "demo"  
  debug_parent    = var.parent_domain      # Should be "jcroyoaun.com"
  debug_full      = local.subdomain_name   # Should be "demo.jcroyoaun.com"
}

# Route53 Hosted Zone for SUBDOMAIN (not parent!)
resource "aws_route53_zone" "subdomain" {
  name = local.subdomain_name  # This should be "demo.jcroyoaun.com"

  tags = {
    Environment   = var.env
    ManagedBy     = "terraform"
    Domain        = local.subdomain_name
    ParentDomain  = var.parent_domain
    Subdomain     = var.subdomain
    DebugFull     = local.debug_full
  }

  lifecycle {
    create_before_destroy = true
  }
}

# NS record in PARENT zone for subdomain delegation
resource "aws_route53_record" "delegation" {
  zone_id = var.parent_hosted_zone_id  # This is your existing jcroyoaun.com zone
  name    = var.subdomain              # This creates "demo" record
  type    = "NS"
  ttl     = 300

  records = aws_route53_zone.subdomain.name_servers

  lifecycle {
    create_before_destroy = true
  }
}

# ACM Certificate for SUBDOMAIN
resource "aws_acm_certificate" "subdomain" {
  domain_name               = local.subdomain_name      # demo.jcroyoaun.com
  subject_alternative_names = ["*.${local.subdomain_name}"] # *.demo.jcroyoaun.com
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment   = var.env
    ManagedBy     = "terraform"
    Domain        = local.subdomain_name
    ParentDomain  = var.parent_domain
    Subdomain     = var.subdomain
  }
}

# DNS validation records in SUBDOMAIN zone
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.subdomain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.subdomain.zone_id  # Validation in SUBDOMAIN zone
}

# Certificate validation
resource "aws_acm_certificate_validation" "subdomain" {
  certificate_arn         = aws_acm_certificate.subdomain.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}