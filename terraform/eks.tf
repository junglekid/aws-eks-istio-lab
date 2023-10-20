# Create AWS EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name                    = local.eks_cluster_name
  cluster_version                 = local.eks_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    kube-proxy = {
      most_recent                 = true
      resolve_conflicts           = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    vpc-cni = {
      most_recent                 = true
      resolve_conflicts           = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.vpc_cni_ipv4_irsa_role.iam_role_arn
    }
    aws-ebs-csi-driver = {
      most_recent                 = true
      resolve_conflicts           = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.ebs_csi_irsa_role.iam_role_arn
    }
    coredns = {
      most_recent                 = true
      resolve_conflicts           = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  depends_on = [module.vpc]
}

# Create AWS EKS Node Group
resource "aws_eks_node_group" "eks" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "node_workers"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = module.vpc.private_subnets
  instance_types  = ["m5a.xlarge", "m5.xlarge"]
  capacity_type   = "SPOT"

  scaling_config {
    desired_size = 3
    max_size     = 20
    min_size     = 3
  }

  update_config {
    max_unavailable = 1
  }
}

# Create AWS IAM Role for EKS Nodes
resource "aws_iam_role" "eks_node" {
  name = "${local.eks_iam_role_prefix}-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach AWS IAM Policy to IAM Role for EKS Nodes
resource "aws_iam_role_policy_attachment" "eks_node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

# Attach AWS IAM Policy to IAM Role for EKS Nodes
resource "aws_iam_role_policy_attachment" "eks_node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

# Attach AWS IAM Policy to IAM Role for EKS Nodes
resource "aws_iam_role_policy_attachment" "eks_node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

# # Install EKS Addon CoreDNS
# resource "aws_eks_addon" "coredns" {
#   cluster_name                = module.eks.cluster_name
#   addon_name                  = "coredns"
#   resolve_conflicts_on_update = "OVERWRITE"

#   depends_on = [
#     module.eks,
#     aws_eks_node_group.eks
#   ]
# }

# # Install EKS Addon EFS CSI Driver
# resource "aws_eks_addon" "aws_efs_csi_driver" {
#   cluster_name                = module.eks.cluster_name
#   addon_name                  = "aws-efs-csi-driver"
#   resolve_conflicts_on_update = "OVERWRITE"
#   service_account_role_arn    = module.efs_csi_irsa_role.iam_role_arn

#   depends_on = [
#     module.eks,
#     aws_eks_node_group.eks
#   ]
# }

# Create ISRA Role for AWS EBS CSI Driver
module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${local.eks_iam_role_prefix}-ebs-csi-driver"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# Create IAM Role for AWS VPC CNI Service Account
module "vpc_cni_ipv4_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${local.eks_iam_role_prefix}-vpc-cni-ipv4"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}
