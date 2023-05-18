#terraform {
#    backend "s3" {
#      bucket         = "glueops-terraform-eks-backend"
#      key            = "terraform.tfstate"
#      region         = "us-west-2"
#      dynamodb_table = "glueops-terraform-eks-backend"
#  }
#}

module "captain" {
  #iam_role_to_assume = "arn:aws:iam::184515722743:role/OrganizationAccountAccessRole"
  iam_role_to_assume = "arn:aws:iam::184515722743:role/captain-role"
  source             = "../"
  eks_version        = "1.26"
  eks_cluster_name   = "captain"
  csi_driver_version = "v1.18.0-eksbuild.1"
  vpc_cidr_block     = "10.65.0.0/16"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b"]
  node_pools = [
     {
       "ami_image_id" : "amazon-eks-node-1.26-v20230411",
       "instance_type" : "t3a.large",
       "name" : "clusterwide-node-pool-1",
       "node_count" : 2,
       "spot" : false,
       "disk_size_gb" : 20,
       "max_pods" : 1000,
       "kubernetes_taints": [{
         "key": "node.cilium.io/agent-not-ready"
         "value": "true"
         "effect": "NO_EXECUTE"
       }]
     }
  ]
}
