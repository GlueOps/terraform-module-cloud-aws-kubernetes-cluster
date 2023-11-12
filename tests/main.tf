module "captain" {
  iam_role_to_assume = "arn:aws:iam::761182885829:role/glueops-captain-role" 
  source             = "../"
  eks_version        = "1.27"
  csi_driver_version = "v1.24.1-eksbuild.1"
  vpc_cidr_block     = "10.65.0.0/26"
  region             = "us-east-1"
  availability_zones = ["us-east-2a", "us-east-2b"]
  node_pools = [
#    {
#      "ami_image_id" : "ami-02a1c9c2cf0dd5307",
#      "instance_type" : "t3a.xlarge",
#      "name" : "glueops-platform-node-pool-1",
#      "node_count" : 4,
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
#      "ami_image_id" : "ami-02a1c9c2cf0dd5307",
#      "instance_type" : "t3a.large",
#      "name" : "clusterwide-node-pool-1",
#      "node_count" : 4,
#      "spot" : false,
#      "disk_size_gb" : 20,
#      "max_pods" : 110,
#      "ssh_key_pair_names" : [],
#      "kubernetes_labels" : {},
#      "kubernetes_taints" : []
#    }
  ]
}
