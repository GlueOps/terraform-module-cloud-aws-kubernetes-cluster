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

5. Save the `export` statements above in a `.env` file and then source it.

## Terraform Deployment

### Configuration

Create a `captain_configuration.tfvars` configuration file to deploy Kubernetes.
A reasonable starting configuration block:

```hcl
kubernetes_cluster_configurations = {
eks_node_group = {
  "desired_size": 3,
  "instance_types": [
    "t3a.large"
  ],
  "max_size": 4,
  "min_size": 3
}

vpc_cidr_block = "10.65.0.0/16"

region = "us-west-2"
}
```

You may update `region` if desired.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.55.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | cloudposse/eks-cluster/aws | 2.5.0 |
| <a name="module_node_pool"></a> [node\_pool](#module\_node\_pool) | cloudposse/eks-node-group/aws | 2.6.0 |
| <a name="module_subnets"></a> [subnets](#module\_subnets) | cloudposse/dynamic-subnets/aws | 2.0.4 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/vpc/aws | 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/eks_addon) | resource |
| [aws_iam_role.eks_addon_ebs_csi_role](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_openid_connect_provider.provider](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.eks_assume_addon_role](https://registry.terraform.io/providers/hashicorp/aws/4.55.0/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.cluster_addons](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_node_group"></a> [eks\_node\_group](#input\_eks\_node\_group) | n/a | <pre>object({<br>    instance_types = list(string)<br>    desired_size   = number<br>    min_size       = number<br>    max_size       = number<br>  })</pre> | <pre>{<br>  "desired_size": 3,<br>  "instance_types": [<br>    "t3a.large"<br>  ],<br>  "max_size": 4,<br>  "min_size": 3<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC | `string` | `"10.65.0.0/16"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
