# #!/usr/bin/env bash

set -e

#./destroy-aws.sh

export AWS_ACCESS_KEY_ID=****************
export AWS_SECRET_ACCESS_KEY=****************
export AWS_DEFAULT_REGION=****************
export AWS_ROLE_ARN=****************

export CILIUM_CURRENT_VERSION=1.12.9
export CILIUM_NEW_VERSION=1.13.2
#export TF_LOG=DEBUG

echo "Terraform Init"
terraform init
echo "Terraform Plan"
terraform plan
echo "Terraform Apply"
terraform apply -auto-approve
echo "Authenticate with Kubernetes"
aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name captain-cluster --role-arn $AWS_ROLE_ARN
echo "Delete AWS CNI"
kubectl delete daemonset -n kube-system aws-node

echo "Install Cilium CNI"
helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade --install cilium cilium/cilium --version $CILIUM_CURRENT_VERSION --namespace=kube-system -f cilium-values.yaml
kubectl delete po --all -n kube-system
echo "Cilium installed: $CILIUM_CURRENT_VERSION. Wait for 1m ..."
sleep 60
kubectl create ns cilium-test || true
kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/v$CILIUM_CURRENT_VERSION/examples/kubernetes/connectivity-check/connectivity-check.yaml
echo "Cilium connectivity check: $CILIUM_CURRENT_VERSION. Wait for 1m ..."
sleep 60
kubectl get pods -n cilium-test
NUM_RUNNING=$(kubectl get po -n cilium-test | grep "1/1" | wc -l)
kubectl delete -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/v$CILIUM_CURRENT_VERSION/examples/kubernetes/connectivity-check/connectivity-check.yaml

if [ $((NUM_RUNNING)) -eq 14 ]
then
  echo "Cilium test passed: $CILIUM_CURRENT_VERSION"

else
  echo "Cilium test failed: $CILIUM_CURRENT_VERSION"
  exit 1
fi

helm template cilium/cilium --version $CILIUM_NEW_VERSION \
  --namespace=kube-system \
  --set preflight.enabled=true \
  --set agent=false \
  --set operator.enabled=false \
  > cilium-preflight.yaml
kubectl apply -f cilium-preflight.yaml
echo "Preflight check. Wait for 1m ..."
sleep 60

kubectl get daemonset -n kube-system | sed -n '1p;/cilium/p'
kubectl get deployment -n kube-system cilium-pre-flight-check

NUMBER_READY=$(kubectl get daemonset cilium -n kube-system -o json | jq ".status.numberReady")
NUMBER_READY_PRE_FLIGHT=$(kubectl get daemonset cilium-pre-flight-check -n kube-system -o json | jq ".status.numberReady")

kubectl delete -f cilium-preflight.yaml
if [ $((NUMBER_READY)) -eq $((NUMBER_READY_PRE_FLIGHT)) ]
then
  echo "Cilium pre-flight check passed: $CILIUM_NEW_VERSION"
else
  echo "Cilium pre-flight check failed: $CILIUM_NEW_VERSION"
  exit 1
fi

helm upgrade --install cilium cilium/cilium --version $CILIUM_NEW_VERSION --namespace=kube-system -f cilium-values.yaml
echo "Cilium installed: $CILIUM_NEW_VERSION. Wait for 1m ..."
sleep 60
kubectl delete po --all -n kube-system
kubectl create ns cilium-test || true
kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/v$CILIUM_NEW_VERSION/examples/kubernetes/connectivity-check/connectivity-check.yaml
echo "Cilium connectivity check: $CILIUM_NEW_VERSION. Wait for 1m ..."
sleep 60
kubectl get pods -n cilium-test
NUM_RUNNING=$(kubectl get po -n cilium-test | grep "1/1" | wc -l)
kubectl delete -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/v$CILIUM_NEW_VERSION/examples/kubernetes/connectivity-check/connectivity-check.yaml
if [ $((NUM_RUNNING)) -eq 14 ]
then
  echo "Cilium test passed: $CILIUM_NEW_VERSION"

else
  echo "Cilium test failed: $CILIUM_NEW_VERSION"
  exit 1
fi

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
