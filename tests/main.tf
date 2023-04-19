module "captain" {
  iam_role_to_assume = "arn:aws:iam::761182885829:role/glueops-captain"
  source             = "../"
  eks_version        = "1.26"
  csi_driver_version = "v1.17.0-eksbuild.1"
  vpc_cidr_block     = "10.65.0.0/16"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b"]
  node_pools = [
    {
      "ami_image_id" : "amazon-eks-node-1.26-v20230406",
      "instance_type" : "t3a.medium",
      "name" : "clusterwide-node-pool-1",
      "node_count" : 1,
      "spot" : false,
      "disk_size_gb" : 20
    }
  ]
}