variable "region" {
  type        = string
  description = "The AWS region to deploy into"
}

variable "csi_driver_version" {
  type        = string
  default     = "v1.20.0-eksbuild.1"
  description = "You should grab the appropriate version number from: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/CHANGELOG.md"
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

variable "eks_version" {
  type        = string
  description = "The version of EKS to deploy"
  default     = "1.27"
}

variable "node_pools" {
  type = list(object({
    name               = string
    node_count         = number
    instance_type      = string
    ami_image_id       = string
    spot               = bool
    disk_size_gb       = number
    max_pods           = number
    ssh_key_pair_names = list(string)
  }))
  default = [{
    name               = "default-pool"
    node_count         = 1
    instance_type      = "t3a.large"
    ami_image_id       = "amazon-eks-node-1.27-v20230607"
    spot               = false
    disk_size_gb       = 20
    max_pods           = 110
    ssh_key_pair_names = []
  }]
  description = <<-DESC
  node pool configurations:
    - name (string): Name of the node pool. MUST BE UNIQUE! Recommended to use YYYYMMDD in the name
    - node_count (number): number of nodes to create in the node pool.
    - instance_type (string): Instance type to use for the nodes. ref: https://instances.vantage.sh/
    - ami_image_id (string): AMI to use for EKS worker nodes. ref: https://github.com/awslabs/amazon-eks-ami/releases
    - spot (bool): Enable spot instances for the nodes. DO NOT ENABLE IN PROD!
    - disk_size_gb (number): Disk size in GB for the nodes.
    - max_pods (number): max pods that can be scheduled per node.
    - ssh_key_pair_names (list(string)): List of SSH key pair names to associate with the nodes. ref: https://us-west-2.console.aws.amazon.com/ec2/home?region=us-west-2#KeyPairs:
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
