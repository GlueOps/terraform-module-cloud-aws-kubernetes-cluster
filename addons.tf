



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
  configuration_values     = local.csi_addon_node_tolerations

}

resource "aws_eks_addon" "coredns" {
  cluster_name                = module.kubernetes.eks_cluster_id
  addon_name                  = "coredns"
  addon_version               = var.coredns_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = aws_iam_role.eks_addon_ebs_csi_role.arn
  depends_on               = [module.node_pool]
  count                    = length(var.node_pools) > 0 ? 1 : 0
  configuration_values = local.coredns_addon_node_tolerations
}


resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = module.kubernetes.eks_cluster_id
  addon_name                  = "kube-proxy"
  addon_version               = var.kube_proxy_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on               = [module.node_pool]
  count                    = length(var.node_pools) > 0 ? 1 : 0
}
