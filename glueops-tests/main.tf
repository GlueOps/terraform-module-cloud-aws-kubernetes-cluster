module "captain" {
  iam_role_to_assume = "arn:aws:iam::761182885829:role/glueops-captain-role"
  source             = "../"
  eks_version        = "1.31"
  # kubernetesVersion and addonName provided
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.31","addonName":"aws-ebs-csi-driver"}
  csi_driver_version = "v1.45.0-eksbuild.2"

  # kubernetesVersion and addonName provided
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.31","addonName":"coredns"}
  coredns_version = "v1.11.4-eksbuild.14"

  # kubernetesVersion and addonName provided
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.31","addonName":"kube-proxy"}
  kube_proxy_version = "v1.31.9-eksbuild.2"

  vpc_cidr_block          = "10.65.0.0/26"
  region                  = "us-west-2"
  availability_zones      = ["us-west-2a", "us-west-2b"]
  private_subnets_enabled = false
  node_pools = [
    #    {
    #      "kubernetes_version" : "1.31",
    #      "ami_release_version" : "1.31.7-20250620",
    #      "ami_type" : "AL2023_x86_64_STANDARD",
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
    #      "kubernetes_version" : "1.31",
    #      "ami_release_version" : "1.31.7-20250620",
    #      "ami_type" : "AL2023_x86_64_STANDARD",
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
    #      "kubernetes_version" : "1.31",
    #      "ami_release_version" : "1.31.7-20250620",
    #      "ami_type" : "AL2023_x86_64_STANDARD",
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
