<!-- BEGIN_TF_DOCS -->
# terraform-module-cloud-aws-kubernetes-cluster

This Terraform module deploys everything you need in AWS to get a kubernetes cluster up and running. This repo should be used in the context of deploying with an [admiral](https://github.com/glueops/admiral)

## Prerequisites

### AWS Account Setup

1. Create a **new** AWS account underneath your existing AWS Organization
2. Request via AWS Support or your account representative from AWS that they "activate" your account. This can take up to 3 days to finish activating.
3. Once activated, within your sub account create an IAM user/key with "Administrator Access". **No Console access is required for this user.**

4. Pick a region and then set your environment variables in the terminal you will be using for execution. The example below uses `us-west-2`

```bash
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXX
export AWS_DEFAULT_REGION=us-west-2
```

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