
module "node_pool" {
  for_each = { for np in var.node_pools : np.name => np }
  source   = "cloudposse/eks-node-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version               = "3.1.1"
  ec2_ssh_key_name      = each.value.ssh_key_pair_names
  instance_types        = [each.value.instance_type]
  subnet_ids            = module.subnets.public_subnet_ids
  desired_size          = each.value.node_count
  min_size              = each.value.node_count
  max_size              = each.value.node_count + 1
  cluster_name          = module.kubernetes.eks_cluster_id
  capacity_type         = each.value.spot ? "SPOT" : "ON_DEMAND"
  ami_release_version   = [each.value.ami_release_version]
  ami_type              = each.value.ami_type
  kubernetes_labels     = each.value.kubernetes_labels
  kubernetes_taints     = each.value.kubernetes_taints
  create_before_destroy = false

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
