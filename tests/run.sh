# #!/usr/bin/env bash

set -e

./destroy-aws.sh

echo "::group::Deploying Kubernetes"
echo "Terraform Init"
terraform init
echo "Terraform Plan"
terraform plan
echo "Terraform Apply"
terraform apply -auto-approve
echo "::endgroup::"
echo "::group::Configuring Kubernetes"
echo "Authenticate with Kubernetes"
aws eks update-kubeconfig --region us-west-2 --name captain-cluster --role-arn arn:aws:iam::761182885829:role/glueops-captain
echo "Delete AWS CNI"
kubectl delete daemonset -n kube-system aws-node
echo "Install Calico CNI"
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm repo update
helm install calico projectcalico/tigera-operator --version v3.26.1 --namespace tigera-operator -f calico.yaml --create-namespace
echo "::endgroup::"
echo "::group::Deploying new Node Pool"
echo "Deploy node pool"
sed -i 's/#//g' main.tf
terraform apply -auto-approve
echo "Get nodes and pods from kubernetes"
kubectl get nodes
kubectl get pods -A -o=wide
echo "::endgroup::"
echo "::group::Start Test Suite"
echo ""
./k8s-test.sh
echo "Test Suite Complete"
echo "::endgroup::"
echo "::group::Tear down Environment"
echo "Terraform Destroy"
terraform destroy -auto-approve

./destroy-aws.sh
echo "::endgroup::"
