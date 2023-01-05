<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.48.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | cloudposse/eks-cluster/aws | 2.5.0 |
| <a name="module_node_pool"></a> [node\_pool](#module\_node\_pool) | cloudposse/eks-node-group/aws | 2.6.0 |
| <a name="module_subnets"></a> [subnets](#module\_subnets) | cloudposse/dynamic-subnets/aws | 2.0.4 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/vpc/aws | 2.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_node_group"></a> [eks\_node\_group](#input\_eks\_node\_group) | n/a | <pre>object({<br>    instance_types = list(string)<br>    desired_size   = number<br>    min_size       = number<br>    max_size       = number<br>  })</pre> | <pre>{<br>  "desired_size": 3,<br>  "instance_types": [<br>    "t3a.large"<br>  ],<br>  "max_size": 4,<br>  "min_size": 3<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC | `string` | `"10.65.0.0./16"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->