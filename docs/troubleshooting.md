# Troubleshooting Guide for Kube-Mediabox

This guide addresses common issues you might encounter when running Kube-Mediabox and provides solutions.

## Longhorn StorageClass Sync Failure

### Problem

You may encounter an ArgoCD sync failure with an error like:

```
Failed sync attempt to be99317bd6e5b52650f5aab8bb8ce576d0dd7173: one or more objects failed to apply, reason: error when replacing "/dev/shm/3939400155": StorageClass.storage.k8s.io "longhorn" is invalid: [parameters: Forbidden: updates to parameters are forbidden., reclaimPolicy: Forbidden: updates to reclaimPolicy are forbidden.]
```

This error occurs because certain fields in Kubernetes StorageClass objects are immutable after creation:
- The `parameters` field cannot be modified
- The `reclaimPolicy` field cannot be modified

### Solution

You need to delete the existing StorageClass and all dependent PVCs, then recreate them with the desired configuration.

#### Steps to Fix

1. **Backup Important Data (Optional)**

   If you have important data in any of the PVCs, back it up before proceeding.

2. **Delete Existing Resources**

   Use the provided script to delete all resources:

   ```bash
   cd kube-mediabox/scripts/maintenance
   chmod +x delete-longhorn-resources.sh
   ./delete-longhorn-resources.sh
   ```

   This will delete:
   - All PVCs using the "longhorn" StorageClass
   - The "longhorn" StorageClass itself

3. **Recreate Resources**

   Use the provided script to recreate all resources:

   ```bash
   cd kube-mediabox/scripts/maintenance
   chmod +x recreate-pvcs.sh
   ./recreate-pvcs.sh
   ```

   This will:
   - Apply the new StorageClass configuration
   - Recreate all PVCs with the same names and configurations

4. **Restart Applications**

   You may need to restart your applications to reconnect to the new PVCs:

   ```bash
   kubectl rollout restart deployment <deployment-name> -n <namespace>
   # or
   kubectl rollout restart statefulset <statefulset-name> -n <namespace>
   ```

5. **Verify ArgoCD Sync**

   After completing these steps, try syncing your application in ArgoCD again. The sync should now succeed.

## PVC Access Issues

### Problem

Sometimes pods may fail to start with errors about not being able to access their PVCs.

### Solution

1. **Check PVC Status**

   ```bash
   kubectl get pvc
   ```

   Ensure all PVCs are in the "Bound" state.

2. **Check Longhorn Volume Status**

   Access the Longhorn UI and verify that:
   - All volumes are healthy
   - Volumes are properly attached to nodes
   - There are no degraded replicas

3. **Check Pod Events**

   ```bash
   kubectl describe pod <pod-name>
   ```

   Look for events related to volume mounting issues.

4. **Fix Permissions**

   If it's a permissions issue, you may need to set the correct ownership:

   ```bash
   kubectl exec -it <some-pod-with-access> -- chown -R 911:911 /path/to/volume
   ```

## Network Connectivity Issues

### Problem

Services cannot communicate with each other or are not accessible from outside the cluster.

### Solution

1. **Check MetalLB Configuration**

   ```bash
   kubectl get ipaddresspools -n metallb-system
   kubectl get l2advertisements -n metallb-system
   ```

   Ensure the IP range is correctly configured.

2. **Verify Service Configuration**

   ```bash
   kubectl get svc
   ```

   Check that services have external IPs assigned if they are of type LoadBalancer.

3. **Check Network Policies**

   If you're using network policies, ensure they're not blocking required traffic.

4. **Reconfigure MetalLB**

   If needed, run the MetalLB configuration script:

   ```bash
   cd kube-mediabox/scripts/setup
   chmod +x configure-metallb.sh
   ./configure-metallb.sh
   ```

## Important Notes

- When modifying StorageClass configurations, remember that certain fields are immutable
- Always back up important data before making significant changes
- The scripts in the `scripts/maintenance` directory are designed to help recover from common issues
- If you need to modify the StorageClass in the future, you'll need to follow a similar process to delete and recreate it
