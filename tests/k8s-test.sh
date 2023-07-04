#!/bin/bash

# Step 1: Verify storage driver installation (Amazon EBS CSI Driver)
echo "Checking if the storage driver is installed..."
kubectl get pods -n kube-system | grep "ebs-csi-"

# Step 2: Create a StorageClass
echo "Creating StorageClass..."
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

# Step 3: Deploy a test application with a PersistentVolumeClaim (PVC)
echo "Deploying test application..."
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

# Step 4: Verify the PVC and pod are created and bound
echo "Waiting for the PVC to be bound and the pod to be running..."
sleep 120
kubectl get pvc
kubectl get pods
kubectl describe pods

# Step 5: Test the storage functionality
TEST_POD_NAME=$(kubectl get pods -l app=test-app -o jsonpath="{.items[0].metadata.name}")
echo "Writing and reading data from the PVC in the test pod $TEST_POD_NAME..."
kubectl exec -it $TEST_POD_NAME -- /bin/sh -c "echo 'Hello, World!' > /data/test.txt"
kubectl exec -it $TEST_POD_NAME -- cat /data/test.txt

# Step 6: Clean up (Optional)
echo "Cleaning up test resources..."
kubectl delete deployment test-app
kubectl delete pvc test-pvc
kubectl delete storageclass ebs-sc
