module "captain" {
  iam_role_to_assume = "arn:aws:iam::761182885829:role/glueops-captain-role" 
  source             = "../"
  eks_version        = "1.28"
  csi_driver_version = "v1.30.0-eksbuild.1"
  coredns_version    = "v1.10.1-eksbuild.7"
  kube_proxy_version = "v1.28.6-eksbuild.2"
  vpc_cidr_block     = "10.65.0.0/26"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b"]
  node_pools = [
#    {
#      "ami_image_id" : "ami-04fd8e3a70c3778b2",
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
#      "ami_image_id" : "ami-04fd8e3a70c3778b2",
#      "instance_type" : "t3a.xlarge",
#      "name" : "glueops-platform-node-pool-argocd-app-controller-1",
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
#          value  = "glueops-platform-argocd-app-controller"
#          effect = "NO_SCHEDULE"
#        }
#      ]
#    },
#    {
#      "ami_image_id" : "ami-04fd8e3a70c3778b2",
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
