# #!/usr/bin/env bash

set -e

./destroy-aws.sh

#export AWS_ACCESS_KEY_ID=****************
#export AWS_SECRET_ACCESS_KEY=****************
#export AWS_DEFAULT_REGION=****************
export AWS_ROLE_ARN=arn:aws:iam::761182885829:role/glueops-captain
export CILIUM_VERSION=1.12.9
#export TF_LOG=DEBUG

echo "Terraform Init"
terraform init
echo "Terraform Plan"
terraform plan
echo "Terraform Apply"
terraform apply -auto-approve
echo "Authenticate with Kubernetes"
aws eks update-kubeconfig --region us-west-2 --name captain-cluster --role-arn $AWS_ROLE_ARN
echo "Delete AWS CNI"
kubectl delete daemonset -n kube-system aws-node
echo "Install Cilium CNI"
helm repo add cilium https://helm.cilium.io/
helm repo update
helm upgrade --install cilium cilium/cilium --version $CILIUM_VERSION --namespace=kube-system -f cilium-values.yaml
kubectl create ns cilium-test
kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/v$CILIUM_VERSION/examples/kubernetes/connectivity-check/connectivity-check.yaml
kubectl get pods -n cilium-test
#echo "Deploy node pool"
#sed -i 's/#//g' main.tf
#terraform apply -auto-approve
echo "Get nodes and pods from kubernetes"
kubectl get nodes
kubectl get pods -A -o=wide
echo "Start Test Suite"
./k8s-test.sh
echo "Test Suite Complete"
echo "Terraform Destroy"
terraform destroy -auto-approve

./destroy-aws.sh
