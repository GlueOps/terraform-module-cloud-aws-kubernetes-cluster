# #!/usr/bin/env bash

./destroy-aws.sh

echo "Terraform Init"
terraform init
echo "Terraform Plan"
terraform plan
echo "Terraform Apply"
terraform apply -auto-approve
echo "Authenticate with Kubernetes"
aws eks update-kubeconfig --region us-west-2 --name captain-cluster --role-arn arn:aws:iam::761182885829:role/glueops-captain
kubectl delete daemonset -n kube-system aws-node
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm repo update
helm install calico projectcalico/tigera-operator --version v3.25.1 --namespace tigera-operator -f values.yaml --create-namespace
sed  -i.bak 's/^#//' main.tf
terraform apply -auto-approve
echo "Get nodes and pods from kubernetes"
kubectl get nodes
kubectl get pods -A -o=wide
echo "Start Test Suite"
./k8s-test.sh
echo "Test Suite Complete"
echo "Terraform Destroy"
terraform destroy -auto-approve

./destroy-aws.sh
