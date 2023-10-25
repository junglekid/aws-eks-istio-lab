### Bookinfo
# Create SSL Certificate using AWS ACM for Bookinfo
resource "aws_acm_certificate" "bookinfo" {
  domain_name       = "bookinfo.${local.public_base_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Validate SSL Certificate using DNS for Bookinfo
resource "aws_route53_record" "bookinfo_validation" {
  for_each = {
    for dvo in aws_acm_certificate.bookinfo.domain_validation_options : dvo.domain_name => {
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
  zone_id         = local.route53_zone_id
}

# Retrieve SSL Certificate ARN from AWS ACM for Bookinfo
resource "aws_acm_certificate_validation" "bookinfo" {
  certificate_arn         = aws_acm_certificate.bookinfo.arn
  validation_record_fqdns = [for record in aws_route53_record.bookinfo_validation : record.fqdn]
}

### Podinfo
# Create SSL Certificate using AWS ACM for Podinfo
resource "aws_acm_certificate" "podinfo" {
  domain_name       = "podinfo.${local.public_base_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Validate SSL Certificate using DNS for Podinfo
resource "aws_route53_record" "podinfo_validation" {
  for_each = {
    for dvo in aws_acm_certificate.podinfo.domain_validation_options : dvo.domain_name => {
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
  zone_id         = local.route53_zone_id
}

# Retrieve SSL Certificate ARN from AWS ACM for Podinfo
resource "aws_acm_certificate_validation" "podinfo" {
  certificate_arn         = aws_acm_certificate.podinfo.arn
  validation_record_fqdns = [for record in aws_route53_record.podinfo_validation : record.fqdn]
}

### Grafana
# Create SSL Certificate using AWS ACM for Grafana
resource "aws_acm_certificate" "grafana" {
  domain_name       = "grafana.${local.public_base_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Validate SSL Certificate using DNS for Grafana
resource "aws_route53_record" "grafana_validation" {
  for_each = {
    for dvo in aws_acm_certificate.grafana.domain_validation_options : dvo.domain_name => {
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
  zone_id         = local.route53_zone_id
}

# Retrieve SSL Certificate ARN from AWS ACM for Grafana
resource "aws_acm_certificate_validation" "grafana" {
  certificate_arn         = aws_acm_certificate.grafana.arn
  validation_record_fqdns = [for record in aws_route53_record.grafana_validation : record.fqdn]
}

### Kiali
# Create SSL Certificate using AWS ACM for Grafana
resource "aws_acm_certificate" "kiali" {
  domain_name       = "kiali.${local.public_base_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Validate SSL Certificate using DNS for Kiali
resource "aws_route53_record" "kiali_validation" {
  for_each = {
    for dvo in aws_acm_certificate.kiali.domain_validation_options : dvo.domain_name => {
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
  zone_id         = local.route53_zone_id
}

# Retrieve SSL Certificate ARN from AWS ACM for Kiali
resource "aws_acm_certificate_validation" "kiali" {
  certificate_arn         = aws_acm_certificate.kiali.arn
  validation_record_fqdns = [for record in aws_route53_record.kiali_validation : record.fqdn]
}
