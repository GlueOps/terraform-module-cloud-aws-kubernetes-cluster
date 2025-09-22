variable "region" {
  type        = string
  description = "The AWS region to deploy into"
}

variable "csi_driver_version" {
  type = string
  # kubernetesVersion and addonName provided
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.31","addonName":"aws-ebs-csi-driver"}
  default     = "v1.44.0-eksbuild.1"
  description = "You should grab the appropriate version number from: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/CHANGELOG.md"
}

variable "coredns_version" {
  type = string
  # kubernetesVersion and addonName provided
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.31","addonName":"coredns"}
  default     = "v1.11.4-eksbuild.22"
  description = "You should grab the appropriate version number from: https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html"
}

variable "kube_proxy_version" {
  type = string
  # kubernetesVersion and addonName provided
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.31","addonName":"kube-proxy"}
  default     = "v1.31.10-eksbuild.8"
  description = "You should grab the appropriate version number from: https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html"
}


locals {

  map_csi_addon_node_tolerations = {
    controller = local.nodeselector_and_pod_tolerations
  }

  map_csi_default_storage = {
    defaultStorageClass = {
      enabled = true
    }
  }

  csi_addon_node_tolerations = jsonencode(merge(local.map_csi_addon_node_tolerations, local.map_csi_default_storage))

  nodeselector_and_pod_tolerations = {
    nodeSelector = {
      "glueops.dev/role" = "glueops-platform"
    }
    tolerations = [{
      key    = "glueops.dev/role"
      value  = "glueops-platform"
      effect = "NoSchedule"
      }
    ]

  }

  coredns_addon_node_tolerations = jsonencode(
    local.nodeselector_and_pod_tolerations
  )

}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.65.0.0/26"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to deploy into"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]

}
variable "private_subnets_enabled" {
  type        = bool
  description = "enable private subnets"
  default     = false

}

variable "eks_version" {
  type        = string
  description = "The version of EKS to deploy"
  default     = "1.31"
}

variable "node_pools" {
  type = list(object({
    name                = string
    node_count          = number
    instance_type       = string
    kubernetes_version  = string
    ami_release_version = string
    ami_type            = string
    spot                = bool
    disk_size_gb        = number
    max_pods            = number
    ssh_key_pair_names  = list(string)
    kubernetes_labels   = map(string)
    kubernetes_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))

  }))
  default = [{
    name                = "default-pool"
    node_count          = 1
    instance_type       = "t3a.large"
    ami_release_version = "1.31.7-20250620"
    kubernetes_version  = "1.31"
    ami_type            = "AL2023_x86_64_STANDARD"
    spot                = false
    disk_size_gb        = 20
    max_pods            = 110
    ssh_key_pair_names  = []
    kubernetes_labels   = {}
    kubernetes_taints   = []
  }]
  description = <<-DESC
  node pool configurations:
    - name (string): Name of the node pool. MUST BE UNIQUE! Recommended to use YYYYMMDD in the name
    - node_count (number): number of nodes to create in the node pool.
    - instance_type (string): Instance type to use for the nodes. ref: https://instances.vantage.sh/
    - kubernetes_version (string): Generally this is the same version as the EKS cluster. But if doing a node pool upgrade this may be a different version.
    - ami_release_version (string): AMI Release version to use for EKS worker nodes. ref: https://github.com/awslabs/amazon-eks-ami/releases
    - ami_type (string): e.g. AMD64 or ARM
    - spot (bool): Enable spot instances for the nodes. DO NOT ENABLE IN PROD!
    - disk_size_gb (number): Disk size in GB for the nodes.
    - max_pods (number): max pods that can be scheduled per node.
    - ssh_key_pair_names (list(string)): List of SSH key pair names to associate with the nodes. ref: https://us-west-2.console.aws.amazon.com/ec2/home?region=us-west-2#KeyPairs:
    - kubernetes_labels (map(string)): Map of labels to apply to the nodes. ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
    - kubernetes_taints (list(object)): List of taints to apply to the nodes. ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
  DESC
}

variable "iam_role_to_assume" {
  type        = string
  description = "The full ARN of the IAM role to assume"
}

variable "peering_configs" {
  description = "A list of maps containing VPC peering configuration details"
  type = list(object({
    vpc_peering_connection_id = string
    destination_cidr_block    = string
  }))
  default = []
}

locals {
  vpc = {
    cidr_block = var.vpc_cidr_block
  }

}
