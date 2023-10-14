module "captain" {
  iam_role_to_assume = "arn:aws:iam::761182885829:role/glueops-captain"
  source             = "../"
  eks_version        = "1.27"
  csi_driver_version = "v1.23.1-eksbuild.1"
  vpc_cidr_block     = "10.65.0.0/26"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b"]
  node_pools = [
#    {
#      "ami_image_id" : "ami-084cf519d356bb718",
#      "instance_type" : "t3a.small",
#      "name" : "glueops-platform-node-pool-1",
#      "node_count" : 2,
#      "spot" : false,
#      "disk_size_gb" : 20,
#      "max_pods" : 110,
#      "ssh_key_pair_names" : [],
#      "kubernetes_labels" : {
#        "glueops.dev/role" : "glueops-platform"
#      },
#      "kubernetes_taints" : [
#        {
#          key    = "glueops.dev/role"
#          value  = "glueops-platform"
#          effect = "NO_SCHEDULE"
#        }
#      ]
#    },
#    {
#      "ami_image_id" : "ami-084cf519d356bb718",
#      "instance_type" : "t3a.small",
#      "name" : "clusterwide-node-pool-1",
#      "node_count" : 2,
#      "spot" : false,
#      "disk_size_gb" : 20,
#      "max_pods" : 110,
#      "ssh_key_pair_names" : [],
#      "kubernetes_labels" : {},
#      "kubernetes_taints" : []
#    }
  ]
}
