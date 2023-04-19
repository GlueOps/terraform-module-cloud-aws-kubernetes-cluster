# #!/usr/bin/env bash

./destroy-aws.sh

echo "Terraform Init"
terraform init
echo "Terraform Plan"
terraform plan
echo "Terraform Apply"
terraform apply -auto-approve
terraform apply -auto-approve
echo "Authenticate with Kubernetes"
aws eks update-kubeconfig --region us-west-2 --name captain-cluster --role-arn arn:aws:iam::761182885829:role/glueops-captain
echo "Get nodes and pods from kubernetes"
kubectl get nodes
kubectl get pods --all-namespaces
echo "Start Test Suite"
./k8s-test.sh
echo "Test Suite Complete"
echo "Terraform Destroy"
terraform destroy -auto-approve

./destroy-aws.sh
