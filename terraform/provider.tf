terraform {

  backend "s3" {
    bucket         = "dallin-tf-backend" # Update the bucket name
    key            = "eks-istio-lab"    # Update key name
    region         = "us-west-2"         # Update with aws region
    profile        = "bsisandbox"        # Update profile name
    encrypt        = true
    dynamodb_table = "dallin-tf-backend" # Update dynamodb_table
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region  = local.aws_region
  profile = local.aws_profile

  default_tags {
    tags = {
      Owner       = local.owner
      Environment = local.environment
      Project     = local.project
      Provisoner  = "Terraform"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
