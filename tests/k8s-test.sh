#!/bin/bash

set -e

# Step 1: Verify pods can get created on the current ami_release_version
echo "::group::Creating daemonset on every node in the cluster"
kubectl apply -f daemonset.yaml
echo "::group::Checking the all pods are in running state"
POD_COUNT=$(kubectl get pods -n test-pods-creation --field-selector=status.phase=Running  --no-headers | wc -l)

echo "::group::Comparing number of running pods to the desired count"
if [ "$POD_COUNT" -ne 8 ]; then
  echo "Expected 8 pods, but found $POD_COUNT."
  exit 1
else
  echo "Pod count matches expected value: $POD_COUNT."
fi

# Step 1: Verify storage driver installation (Amazon EBS CSI Driver)
echo "::group::Checking if the storage driver is installed..."
kubectl get pods -n kube-system | grep "ebs-csi-"
echo "::endgroup::"

# Step 2: Create a StorageClass
echo "::group::Creating StorageClass..."
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp2
EOF
echo "::endgroup::"

# Step 3: Deploy a test application with a PersistentVolumeClaim (PVC)
echo "::group::Deploying test application..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: ebs-sc
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: test-container
        image: busybox
        command: ["/bin/sh"]
        args: ["-c", "while true; do sleep 3600; done"]
        volumeMounts:
        - name: test-volume
          mountPath: /data
      volumes:
      - name: test-volume
        persistentVolumeClaim:
          claimName: test-pvc
EOF
echo "::endgroup::"

# Step 4: Verify the PVC and pod are created and bound
echo "::group::Waiting for the PVC to be bound and the pod to be running..."
sleep 30
kubectl get pvc
kubectl get pods
kubectl describe pods
kubectl describe pvc
echo "::endgroup::"


# Step 5: Test the storage functionality
TEST_POD_NAME=$(kubectl get pods -l app=test-app -o jsonpath="{.items[0].metadata.name}")
echo "::group::Writing and reading data from the PVC in the test pod $TEST_POD_NAME..."
kubectl exec -it $TEST_POD_NAME -- /bin/sh -c "echo 'Hello, World!' > /data/test.txt"
kubectl exec -it $TEST_POD_NAME -- cat /data/test.txt
echo "::endgroup::"

# Step 6: Clean up (Optional)
echo "::group::Cleaning up test resources..."
kubectl delete deployment test-app
kubectl delete pvc test-pvc
kubectl delete storageclass ebs-sc
echo "::endgroup::"
