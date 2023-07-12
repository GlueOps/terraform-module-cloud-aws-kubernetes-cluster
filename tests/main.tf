module "captain" {
  iam_role_to_assume = "arn:aws:iam::761182885829:role/glueops-captain"
  source             = "../"
  eks_version        = "1.27"
  csi_driver_version = "v1.20.0-eksbuild.1"
  vpc_cidr_block     = "10.65.0.0/26"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b"]
  node_pools = [
    # {
    #   "ami_image_id" : "ami-0c3bf2dfecd4a139e",
    #   "instance_type" : "t3a.small",
    #   "name" : "clusterwide-node-pool-1",
    #   "node_count" : 2,
    #   "spot" : false,
    #   "disk_size_gb" : 20,
    #   "max_pods" : 1000,
    #   "ssh_key_pair_names" : [],
    #   "kubernetes_labels": {},
    #   "kubernetes_taints": []
    # }
  ]
}
