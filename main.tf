variable "region" {
  type        = string
  description = "The AWS region to deploy into"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.65.0.0./16"
}

variable "eks_node_group" {
  type = object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
  })
  default = {
    instance_types = ["t3a.large"]
    desired_size   = 3
    min_size       = 3
    max_size       = 4
  }
}

provider "aws" {
  region = var.region
}

locals {
  eks_cluster = {
    cluster_version = "1.22"
    region          = var.region
  }
  vpc = {
    cidr_block = var.vpc_cidr_block
  }

  eks_node_group = var.eks_node_group
}

module "vpc" {
  source = "cloudposse/vpc/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version                 = "2.0.0"
  ipv4_primary_cidr_block = local.vpc.cidr_block
  name                    = "captain"
}


module "subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "2.0.4"

  vpc_id                  = module.vpc.vpc_id
  igw_id                  = [module.vpc.igw_id]
  nat_gateway_enabled     = false
  nat_instance_enabled    = false
  name                    = "captain"
  private_subnets_enabled = false
  public_subnets_enabled  = true
  availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
}




module "node_pool" {
  source = "cloudposse/eks-node-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "2.6.0"

  instance_types = local.eks_node_group.instance_types
  subnet_ids     = module.subnets.public_subnet_ids
  #health_check_type                  = var.health_check_type
  desired_size = local.eks_node_group.desired_size
  min_size     = local.eks_node_group.min_size
  max_size     = local.eks_node_group.max_size
  cluster_name = module.kubernetes.eks_cluster_id

  # Enable the Kubernetes cluster auto-scaler to find the auto-scaling group
  cluster_autoscaler_enabled = true
  name                       = "captain"
  # Ensure the cluster is fully created before trying to add the node group
  module_depends_on = module.kubernetes.kubernetes_config_map_id
}


module "kubernetes" {
  source  = "cloudposse/eks-cluster/aws"
  version = "2.5.0"

  region     = local.eks_cluster.region
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_ids

  oidc_provider_enabled = true
  name                  = "captain"
  kubernetes_version    = local.eks_cluster.cluster_version
}




