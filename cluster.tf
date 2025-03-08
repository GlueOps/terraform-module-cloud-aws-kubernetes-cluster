module "kubernetes" {
  source  = "cloudposse/eks-cluster/aws"
  version = "3.0.0"

  region     = var.region
  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(
    module.subnets.public_subnet_ids,
    tolist(module.subnets.private_subnet_ids != null ? module.subnets.private_subnet_ids : [])
  )

  oidc_provider_enabled      = true
  name                       = "captain"
  kubernetes_version         = var.eks_version
  apply_config_map_aws_auth  = false
  allowed_security_group_ids = [aws_security_group.captain.id]
}
