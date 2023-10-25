locals {
  # AWS Provider
  aws_region  = "us-west-2"  # Update with aws region
  aws_profile = "bsisandbox" # Update with aws profile

  # Account ID
  account_id = data.aws_caller_identity.current.account_id

  # Tags
  owner       = "Dallin Rasmuson" # Update with owner name
  environment = "Sandbox"
  project     = "AWS EKS and Istio Lab"

  # VPC Configuration
  vpc_name = "eks-istio-lab-vpc"
  vpc_cidr = "10.200.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  # EKS Configuration
  eks_cluster_name                            = "eks-istio-lab"
  eks_cluster_version                         = "1.28" # To always use the latest set to "" instead of "1.xx"
  eks_iam_role_prefix                         = "eks-istio-lab"

  # ACM and Route53 Configuration
  public_base_domain_name = "dallin.brewsentry.com" # Update with your root domain
  route53_zone_id         = data.aws_route53_zone.public_domain.zone_id
  route53_zone_arn        = data.aws_route53_zone.public_domain.arn
}
