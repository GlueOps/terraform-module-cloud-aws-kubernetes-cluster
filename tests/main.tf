module "captain" {
  iam_role_to_assume = "arn:aws:iam::761182885829:role/glueops-captain-role" 
  source             = "../"
  eks_version        = "1.28"
  csi_driver_version = "v1.31.0-eksbuild.1"
  coredns_version    = "v1.10.1-eksbuild.11"
  kube_proxy_version = "v1.28.8-eksbuild.5"
  vpc_cidr_block     = "10.65.0.0/26"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b"]
  node_pools = [
#    {
#      "ami_image_id" : "ami-084763992995b8d9e",
#      "instance_type" : "t3a.large",
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
#      "ami_image_id" : "ami-084763992995b8d9e",
#      "instance_type" : "t3a.small",
#      "name" : "glueops-platform-node-pool-argocd-app-controller-1",
#      "node_count" : 2,
#      "spot" : false,
#      "disk_size_gb" : 20,
#      "max_pods" : 110,
#      "ssh_key_pair_names" : [],
#      "kubernetes_labels" : {
#        "glueops.dev/role" : "glueops-platform-argocd-app-controller"
#      },
#      "kubernetes_taints" : [
#        {
#          key    = "glueops.dev/role"
#          value  = "glueops-platform-argocd-app-controller"
#          effect = "NO_SCHEDULE"
#        }
#      ]
#    },
#    {
#      "ami_image_id" : "ami-084763992995b8d9e",
#      "instance_type" : "t3a.medium",
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
