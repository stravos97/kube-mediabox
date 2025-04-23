#!/bin/bash
# Enhanced cleanup script for k3s media server

echo "!!!! WARNING !!!!"
echo "This script will completely delete ALL resources related to your media server."
echo "ALL DATA WILL BE LOST!"
echo
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation canceled."
    exit 1
fi

# Get all services and delete them
echo "Deleting all services..."
kubectl get services -o name | grep -v kubernetes | xargs -r kubectl delete

# Get all deployments (if any)
echo "Deleting all deployments..."
kubectl get deployments -o name | xargs -r kubectl delete

# Get all statefulsets
echo "Deleting all statefulsets..."
kubectl get statefulsets -o name | xargs -r kubectl delete

# List and delete all PVCs
echo "Deleting all PVCs..."
kubectl get pvc -o name | xargs -r kubectl delete

# Wait for PVCs to terminate
echo "Waiting for PVCs to terminate..."
sleep 10

# Find and delete any orphaned PVs
echo "Deleting orphaned PVs..."
kubectl get pv -o name | xargs -r kubectl delete

# Use kubectl patch to remove finalizers from StorageClass (if any)
echo "Removing finalizers from StorageClass..."
kubectl get storageclass longhorn -o name 2>/dev/null | xargs -r -I{} kubectl patch {} --type json --patch='[{"op": "remove", "path": "/metadata/finalizers"}]'

# Delete the StorageClass with --force flag
echo "Force deleting StorageClass..."
kubectl delete storageclass longhorn --force --grace-period=0 2>/dev/null
kubectl delete storageclass longhorn-media --force --grace-period=0 2>/dev/null

# Wait for complete deletion
echo "Waiting for resources to be fully deleted..."
sleep 20

echo
echo "Cleanup complete."
echo
echo "NEXT STEPS:"
echo "1. To recreate the storage classes, run:"
echo "   kubectl apply -f ../../config/storage/longhorn.yaml"
echo "   kubectl apply -f ../../config/storage/longhorn-media.yaml"
echo
echo "2. To recreate PVCs, run the recreate-pvcs.sh script"
echo
echo "3. Set up your applications in the correct order"

# Clean up temporary files
rm -f storageclass.yaml media-pv-pvc.yaml
