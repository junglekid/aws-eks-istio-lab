# Retrieve AWS Account Information
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_route53_zone" "public_domain" {
  name         = local.public_base_domain_name
  private_zone = false
}
