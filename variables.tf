variable "region" {
  type        = string
  description = "The AWS region to deploy into"
}

variable "csi_driver_version" {
  type    = string
  default = "v1.15.0-eksbuild.1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.65.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to deploy into"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]

}

variable "eks_version" {
  type        = string
  description = "The version of EKS to deploy"
  default     = "1.24"
}

variable "node_pools" {
  type = list(object({
    name          = string
    node_count    = number
    instance_type = string
    ami_image_id  = string
    spot          = bool
    name          = string
    disk_size_gb  = number
  }))
  default = [{
    ami_image_id  = "amazon-eks-node-1.24-v20230406"
    node_count    = 1
    instance_type = "t3a.large"
    name          = "default-pool"
    spot          = false
    disk_size_gb  = 20
  }]
  # description = <<-DESC
  # node pool configurations:
  #   - name (string): Name of the node pool. MUST BE UNIQUE! Recommended to use YYYYMMDD in the name
  #   - node_count (number): number of nodes to create in the node pool.
  #   - machine_type (string): Machine type to use for the nodes. ref: https://gcpinstances.doit-intl.com/
  #   - disk_type (string): Disk type to use for the nodes. ref: https://cloud.google.com/compute/docs/disks
  #   - disk_size_gb (number): Disk size in GB for the nodes.
  #   - gke_version (string): GKE version to use for the nodes. ref: https://cloud.google.com/kubernetes-engine/docs/release-notes
  #   - spot (bool): Enable spot instances for the nodes. DO NOT ENABLE IN PROD!
  # DESC
}

locals {
  vpc = {
    cidr_block = var.vpc_cidr_block
  }

}