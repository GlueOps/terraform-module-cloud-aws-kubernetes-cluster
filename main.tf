variable "region" {
  type        = string
  description = "The AWS region to deploy into"
}

variable "csi_driver_version" {
  type    = string
  default = "v1.15.0-eksbuild.1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.65.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to deploy into"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]

}

variable "eks_version" {
  type        = string
  description = "The version of EKS to deploy"
  default     = "1.24"
}

variable "node_pools" {
  type = list(object({
    name          = string
    node_count    = number
    instance_type = string
    ami_image_id  = string
    spot          = bool
    name          = string
    disk_size_gb  = number
  }))
  default = [{
    ami_image_id  = "amazon-eks-node-1.24-v20230406"
    node_count    = 1
    instance_type = "t3a.large"
    name          = "default-pool"
    spot          = false
    disk_size_gb  = 20
  }]
  # description = <<-DESC
  # node pool configurations:
  #   - name (string): Name of the node pool. MUST BE UNIQUE! Recommended to use YYYYMMDD in the name
  #   - node_count (number): number of nodes to create in the node pool.
  #   - machine_type (string): Machine type to use for the nodes. ref: https://gcpinstances.doit-intl.com/
  #   - disk_type (string): Disk type to use for the nodes. ref: https://cloud.google.com/compute/docs/disks
  #   - disk_size_gb (number): Disk size in GB for the nodes.
  #   - gke_version (string): GKE version to use for the nodes. ref: https://cloud.google.com/kubernetes-engine/docs/release-notes
  #   - spot (bool): Enable spot instances for the nodes. DO NOT ENABLE IN PROD!
  # DESC
}

variable "iam_role_to_assume" {
  type        = string
  description = "The name of the IAM role to assume"
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.iam_role_to_assume
  }
}

locals {
  vpc = {
    cidr_block = var.vpc_cidr_block
  }

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
  availability_zones      = var.availability_zones
}


module "node_pool" {
  for_each = { for np in var.node_pools : np.name => np }
  source   = "cloudposse/eks-node-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "2.9.0"

  instance_types = [each.value.instance_type]
  subnet_ids     = module.subnets.public_subnet_ids
  desired_size   = each.value.node_count
  min_size       = each.value.node_count
  max_size       = each.value.node_count + 1
  cluster_name   = module.kubernetes.eks_cluster_id
  capacity_type  = each.value.spot ? "SPOT" : "ON_DEMAND"

  cluster_autoscaler_enabled = false
  name                       = each.value.name
  # Ensure the cluster is fully created before trying to add the node group
  module_depends_on = module.kubernetes.kubernetes_config_map_id
  block_device_mappings = [
    {
      "delete_on_termination" : true,
      "device_name" : "/dev/xvda",
      "encrypted" : true,
      "volume_size" : each.value.disk_size_gb,
      "volume_type" : "gp2"
    }
  ]
}


module "kubernetes" {
  source  = "cloudposse/eks-cluster/aws"
  version = "2.6.0"

  region     = var.region
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_ids

  oidc_provider_enabled     = true
  name                      = "captain"
  kubernetes_version        = var.eks_version
  apply_config_map_aws_auth = false
}

data "aws_iam_openid_connect_provider" "provider" {
  arn = module.kubernetes.eks_cluster_identity_oidc_issuer_arn
}

data "aws_iam_policy_document" "eks_assume_addon_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      identifiers = [data.aws_iam_openid_connect_provider.provider.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }


  }
}

resource "aws_iam_role" "eks_addon_ebs_csi_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_assume_addon_role.json
  name               = "AmazonEKS_EBS_CSI_DriverRole"
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_addon_ebs_csi_role.name
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.kubernetes.eks_cluster_id
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.csi_driver_version
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.eks_addon_ebs_csi_role.arn
  depends_on               = [aws_iam_role_policy_attachment.ebs_csi, module.node_pool]
}

