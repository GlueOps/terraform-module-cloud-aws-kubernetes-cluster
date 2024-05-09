

resource "aws_eks_addon" "coredns" {
  cluster_name                = module.kubernetes.eks_cluster_id
  addon_name                  = "coredns"
  addon_version               = var.coredns_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = null
  depends_on               = [module.node_pool]
  count                    = length(var.node_pools) > 0 ? 1 : 0

  configuration_values = local.coredns_addon_node_tolerations
}
