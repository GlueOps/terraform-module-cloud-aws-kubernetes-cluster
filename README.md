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
  iam_role_to_assume = "arn:aws:iam::1234567890:role/glueops-captain-role"
  source             = "git::https://github.com/GlueOps/terraform-module-cloud-aws-kubernetes-cluster.git"
  eks_version        = "1.31"
  # kubernetesVersion and addonName provided
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.31","addonName":"aws-ebs-csi-driver"}
  csi_driver_version = "v1.46.0-eksbuild.1"

  # kubernetesVersion and addonName provided
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.31","addonName":"coredns"}
  coredns_version    = "v1.11.4-eksbuild.14"

  # kubernetesVersion and addonName provided
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.31","addonName":"kube-proxy"}
  kube_proxy_version = "v1.31.9-eksbuild.2"
  vpc_cidr_block     = "10.65.0.0/26"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b"]
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
  peering_configs = [
#    {
#    vpc_peering_connection_id = "pcx-0df92b5241651ba92"
#    destination_cidr_block = "10.69.0.0/26"
#    }
  ]
}
```

## VPC Peering

This terraform module expects only to be an accepter VPC. This means a VPC peering request must come from the requesting account. As an accepter VPC you must provide the requester your VPC ID, your AWS Account ID (The subaccount being used for the cluster deployment), and the VPC CIDR you configured for the cluster deployment.

When providing them with the above, please ask them to [enable DNS resolution of hosts within the requester VPC](https://docs.aws.amazon.com/vpc/latest/peering/modify-peering-connections.html#vpc-peering-dns).

### EFS/NFS Example Manifest

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv-test
spec:
  storageClassName: efs-fun-test
  capacity:
    storage: 1000Gi # Adjust based on your needs
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  mountOptions:
      - timeo=600
      - retrans=2
      - nfsvers=4.1
      - rsize=1048576
      - wsize=1048576
      - noresvport
      - hard
  nfs:
    path: /
    server: nfs.nonprod.antoniostacos.onglueops.com
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-fun-test
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: nginx
      volumeMounts:
        - name: my-volume
          mountPath: /mnt/data  # Mount path within the container
          subPath: pod1-fun
  volumes:
    - name: my-volume
      persistentVolumeClaim:
        claimName: my-pvc  # Name of the PVC to be mounted
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | cloudposse/eks-cluster/aws | 3.0.0 |
| <a name="module_node_pool"></a> [node\_pool](#module\_node\_pool) | cloudposse/eks-node-group/aws | 3.1.1 |
| <a name="module_subnets"></a> [subnets](#module\_subnets) | cloudposse/dynamic-subnets/aws | 2.4.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/vpc/aws | 2.2.0 |
| <a name="module_vpc_peering_accepter_with_routes"></a> [vpc\_peering\_accepter\_with\_routes](#module\_vpc\_peering\_accepter\_with\_routes) | ./modules/vpc_peering_accepter_with_routes | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.kube_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_role.eks_addon_ebs_csi_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.captain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all_within_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.captain_egress_all_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_openid_connect_provider.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.eks_assume_addon_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The availability zones to deploy into | `list(string)` | <pre>[<br/>  "us-west-2a",<br/>  "us-west-2b",<br/>  "us-west-2c"<br/>]</pre> | no |
| <a name="input_coredns_version"></a> [coredns\_version](#input\_coredns\_version) | You should grab the appropriate version number from: https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html | `string` | `"v1.11.4-eksbuild.14"` | no |
| <a name="input_csi_driver_version"></a> [csi\_driver\_version](#input\_csi\_driver\_version) | You should grab the appropriate version number from: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/CHANGELOG.md | `string` | `"v1.46.0-eksbuild.1"` | no |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | The version of EKS to deploy | `string` | `"1.31"` | no |
| <a name="input_iam_role_to_assume"></a> [iam\_role\_to\_assume](#input\_iam\_role\_to\_assume) | The full ARN of the IAM role to assume | `string` | n/a | yes |
| <a name="input_kube_proxy_version"></a> [kube\_proxy\_version](#input\_kube\_proxy\_version) | You should grab the appropriate version number from: https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html | `string` | `"v1.31.9-eksbuild.2"` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | node pool configurations:<br/>  - name (string): Name of the node pool. MUST BE UNIQUE! Recommended to use YYYYMMDD in the name<br/>  - node\_count (number): number of nodes to create in the node pool.<br/>  - instance\_type (string): Instance type to use for the nodes. ref: https://instances.vantage.sh/<br/>  - kubernetes\_version (string): Generally this is the same version as the EKS cluster. But if doing a node pool upgrade this may be a different version.<br/>  - ami\_release\_version (string): AMI Release version to use for EKS worker nodes. ref: https://github.com/awslabs/amazon-eks-ami/releases<br/>  - ami\_type (string): e.g. AMD64 or ARM<br/>  - spot (bool): Enable spot instances for the nodes. DO NOT ENABLE IN PROD!<br/>  - disk\_size\_gb (number): Disk size in GB for the nodes.<br/>  - max\_pods (number): max pods that can be scheduled per node.<br/>  - ssh\_key\_pair\_names (list(string)): List of SSH key pair names to associate with the nodes. ref: https://us-west-2.console.aws.amazon.com/ec2/home?region=us-west-2#KeyPairs:<br/>  - kubernetes\_labels (map(string)): Map of labels to apply to the nodes. ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/<br/>  - kubernetes\_taints (list(object)): List of taints to apply to the nodes. ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ | <pre>list(object({<br/>    name                = string<br/>    node_count          = number<br/>    instance_type       = string<br/>    kubernetes_version  = string<br/>    ami_release_version = string<br/>    ami_type            = string<br/>    spot                = bool<br/>    disk_size_gb        = number<br/>    max_pods            = number<br/>    ssh_key_pair_names  = list(string)<br/>    kubernetes_labels   = map(string)<br/>    kubernetes_taints = list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    }))<br/><br/>  }))</pre> | <pre>[<br/>  {<br/>    "ami_release_version": "1.31.7-20250620",<br/>    "ami_type": "AL2023_x86_64_STANDARD",<br/>    "disk_size_gb": 20,<br/>    "instance_type": "t3a.large",<br/>    "kubernetes_labels": {},<br/>    "kubernetes_taints": [],<br/>    "kubernetes_version": "1.31",<br/>    "max_pods": 110,<br/>    "name": "default-pool",<br/>    "node_count": 1,<br/>    "spot": false,<br/>    "ssh_key_pair_names": []<br/>  }<br/>]</pre> | no |
| <a name="input_peering_configs"></a> [peering\_configs](#input\_peering\_configs) | A list of maps containing VPC peering configuration details | <pre>list(object({<br/>    vpc_peering_connection_id = string<br/>    destination_cidr_block    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_private_subnets_enabled"></a> [private\_subnets\_enabled](#input\_private\_subnets\_enabled) | enable private subnets | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC | `string` | `"10.65.0.0/26"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
