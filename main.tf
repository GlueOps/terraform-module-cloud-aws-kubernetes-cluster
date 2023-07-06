

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.iam_role_to_assume
  }
}




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

module "node_pool" {
  for_each = { for np in var.node_pools : np.name => np }
  source   = "cloudposse/eks-node-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version             = "2.10.0"
  ec2_ssh_key_name    = each.value.ssh_key_pair_names
  instance_types      = [each.value.instance_type]
  subnet_ids          = module.subnets.public_subnet_ids
  desired_size        = each.value.node_count
  min_size            = each.value.node_count
  max_size            = each.value.node_count + 1
  cluster_name        = module.kubernetes.eks_cluster_id
  capacity_type       = each.value.spot ? "SPOT" : "ON_DEMAND"
  ami_release_version = [each.value.ami_release_version]

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
  kubelet_additional_options = [
    "--max-pods=${each.value.max_pods}"
  ]
  associated_security_group_ids = [aws_security_group.captain.id]
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
  cluster_name                = module.kubernetes.eks_cluster_id
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.csi_driver_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = aws_iam_role.eks_addon_ebs_csi_role.arn
  depends_on               = [aws_iam_role_policy_attachment.ebs_csi, module.node_pool]
  count                    = length(var.node_pools) > 0 ? 1 : 0
}
