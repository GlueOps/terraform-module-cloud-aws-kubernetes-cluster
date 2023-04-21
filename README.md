<!-- BEGIN_TF_DOCS -->
# terraform-module-cloud-aws-kubernetes-cluster

This terraform module is to help you quickly deploy a EKS cluster on Amazon Web Services (AWS). This is part of the opionated GlueOps Platform. If you came here directly then you should probably visit https://github.com/glueops/admiral as that is the start point.

## Prerequisites to use this Terraform module

- A Dedicated AWS Sub account
- Service account with environment variable set
- Service Quotas (Depending on Cluster Size)

For more details see: https://github.com/GlueOps/terraform-module-cloud-aws-kubernetes-cluster/wiki/

### Example usage of module

```hcl
module "captain" {
  iam_role_to_assume = "arn:aws:iam::1234567890:role/glueops-captain"
  source             = "git::https://github.com/GlueOps/terraform-module-cloud-aws-kubernetes-cluster.git?ref=feat/multiple-node-pools"
  eks_version        = "1.26"
  csi_driver_version = "v1.17.0-eksbuild.1"
  vpc_cidr_block     = "10.65.0.0/16"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b"]
  node_pools = [
    {
      "ami_image_id" : "amazon-eks-node-1.26-v20230406",
      "instance_type" : "t3a.large",
      "name" : "clusterwide-node-pool-1",
      "node_count" : 3,
      "spot" : false,
      "disk_size_gb" : 20
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.55.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | cloudposse/eks-cluster/aws | 2.6.0 |
| <a name="module_node_pool"></a> [node\_pool](#module\_node\_pool) | cloudposse/eks-node-group/aws | 2.9.0 |
| <a name="module_subnets"></a> [subnets](#module\_subnets) | cloudposse/dynamic-subnets/aws | 2.0.4 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/vpc/aws | 2.0.0 |
| <a name="module_vpc_peering_accepter_with_routes"></a> [vpc\_peering\_accepter\_with\_routes](#module\_vpc\_peering\_accepter\_with\_routes) | ./modules/vpc_peering_accepter_with_routes | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/eks_addon) | resource |
| [aws_iam_role.eks_addon_ebs_csi_role](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.captain](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all_within_group](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.captain_egress_all_ipv4](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.captain_ingress_all_private](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/security_group_rule) | resource |
| [aws_iam_openid_connect_provider.provider](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.eks_assume_addon_role](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The availability zones to deploy into | `list(string)` | <pre>[<br>  "us-west-2a",<br>  "us-west-2b",<br>  "us-west-2c"<br>]</pre> | no |
| <a name="input_csi_driver_version"></a> [csi\_driver\_version](#input\_csi\_driver\_version) | You should grab the appropriate version number from: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/CHANGELOG.md | `string` | `"v1.17.0-eksbuild.1"` | no |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | The version of EKS to deploy | `string` | `"1.26"` | no |
| <a name="input_iam_role_to_assume"></a> [iam\_role\_to\_assume](#input\_iam\_role\_to\_assume) | The full ARN of the IAM role to assume | `string` | n/a | yes |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | node pool configurations:<br>  - name (string): Name of the node pool. MUST BE UNIQUE! Recommended to use YYYYMMDD in the name<br>  - node\_count (number): number of nodes to create in the node pool.<br>  - instance\_type (string): Instance type to use for the nodes. ref: https://instances.vantage.sh/<br>  - ami\_image\_id (string): AMI to use for EKS worker nodes. ref: https://github.com/awslabs/amazon-eks-ami/releases<br>  - spot (bool): Enable spot instances for the nodes. DO NOT ENABLE IN PROD!<br>  - disk\_size\_gb (number): Disk size in GB for the nodes. | <pre>list(object({<br>    name          = string<br>    node_count    = number<br>    instance_type = string<br>    ami_image_id  = string<br>    spot          = bool<br>    disk_size_gb  = number<br>  }))</pre> | <pre>[<br>  {<br>    "ami_image_id": "amazon-eks-node-1.24-v20230406",<br>    "disk_size_gb": 20,<br>    "instance_type": "t3a.large",<br>    "name": "default-pool",<br>    "node_count": 1,<br>    "spot": false<br>  }<br>]</pre> | no |
| <a name="input_peering_configs"></a> [peering\_configs](#input\_peering\_configs) | A list of maps containing VPC peering configuration details | <pre>list(object({<br>    vpc_peering_connection_id = string<br>    destination_cidr_block    = string<br>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC | `string` | `"10.65.0.0/16"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
