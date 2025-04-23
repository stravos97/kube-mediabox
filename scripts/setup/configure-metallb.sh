#!/bin/bash
# Script to configure MetalLB in your Kubernetes cluster

# Check if MetalLB is installed
if ! kubectl get namespace metallb-system &>/dev/null; then
  echo "MetalLB namespace not found. Installing MetalLB..."
  # Apply MetalLB manifests
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
  
  # Wait for MetalLB to be ready
  echo "Waiting for MetalLB components to be ready..."
  sleep 30
else
  echo "MetalLB already installed, configuring address pool..."
fi

# Create the configuration file
cat > ../../config/networking/metallb-config.yaml << 'EOF'
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.20-192.168.1.40
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
EOF

# Apply the configuration
echo "Applying MetalLB configuration..."
kubectl apply -f ../../config/networking/metallb-config.yaml

# Verify configuration
echo "Verifying MetalLB configuration..."
kubectl get ipaddresspools -n metallb-system
kubectl get l2advertisements -n metallb-system

echo "MetalLB configuration complete. LoadBalancer services will be assigned IPs from range 192.168.1.20-192.168.1.40"
echo ""
echo "To test, create a simple LoadBalancer service:"
echo "kubectl create deployment nginx --image=nginx"
echo "kubectl expose deployment nginx --port=80 --type=LoadBalancer"
echo ""
echo "Then check if an external IP was assigned:"
echo "kubectl get svc nginx"
