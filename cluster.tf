module "kubernetes" {
  source  = "cloudposse/eks-cluster/aws"
  version = "2.8.1"

  region     = var.region
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_ids

  oidc_provider_enabled      = true
  name                       = "captain"
  kubernetes_version         = var.eks_version
  apply_config_map_aws_auth  = false
  allowed_security_group_ids = [aws_security_group.captain.id]
}
