# Output AWS Region
output "aws_region" {
  value = local.aws_region
}

# Output EKS Cluster Name
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_sa_alb_iam_role_arn" {
  value = module.load_balancer_controller_irsa_role.iam_role_arn
}

output "eks_sa_external_dns_iam_role_arn" {
  value = module.external_dns_irsa_role.iam_role_arn
}

output "eks_sa_cluster_autoscaler_iam_role_arn" {
  value = module.cluster_autoscaler_irsa_role.iam_role_arn
}

output "eks_sa_cert_manager_iam_role_arn" {
  value = module.cert_manager_irsa_role.iam_role_arn
}

# Output Domain Filter for External DNS
output "domain_filter" {
  value = local.public_base_domain_name
}

# Output Base Domain Name
output "base_domain_name" {
  value = local.public_base_domain_name
}

# # Podinfo Outputs
# output "podinfo_domain_name" {
#   value = local.podinfo_domain_name
# }

# output "podinfo_acm_certificate_arn" {
#   value = aws_acm_certificate_validation.podinfo.certificate_arn
# }

# output "grafana_acm_certificate_arn" {
#   value = aws_acm_certificate_validation.grafana.certificate_arn
# }

# output "kiali_domain_name" {
#   value = local.kiali_domain_name
# }

# output "kiali_acm_certificate_arn" {
#   value = aws_acm_certificate_validation.kiali.certificate_arn
# }

# output "bookinfo_domain_name" {
#   value = local.bookinfo_domain_name
# }

# output "bookinfo_acm_certificate_arn" {
#   value = aws_acm_certificate_validation.bookinfo.certificate_arn
# }

# output "route53_zone_arn" {
#   value = local.route53_zone_arn
# }

# output "eks_sqs_keda_irsa_role" {
#   value = module.sqs_keda_irsa_role.iam_role_arn
# }