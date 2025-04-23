#!/bin/bash

# This script recreates all the PVCs that were deleted
# after the StorageClass has been recreated.

# Set the namespace where your resources are located
NAMESPACE="default"

echo "Applying the storage classes..."
kubectl apply -f ../../config/storage/longhorn.yaml
kubectl apply -f ../../config/storage/longhorn-media.yaml

echo "Recreating PVCs..."

# Create a temporary directory for PVC manifests
mkdir -p temp-pvcs

# Create PVC manifests
cat > temp-pvcs/media-pv-pvc-claim.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-pv-pvc-claim
  annotations:
    "helm.sh/resource-policy": keep
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 400Gi
  storageClassName: longhorn-media
EOF

cat > temp-pvcs/plex-config.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: plex-config
  labels:
    app: plex
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: longhorn
EOF

cat > temp-pvcs/sonarr-config.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sonarr-config
  labels:
    app: sonarr
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: longhorn
EOF

cat > temp-pvcs/sabnzbd-config.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sabnzbd-config
  labels:
    app: sabnzbd
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: longhorn
EOF

cat > temp-pvcs/ombi-config.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ombi-config
  labels:
    app: ombi
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: longhorn
EOF

cat > temp-pvcs/lidarr-config.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lidarr-config
  labels:
    app: lidarr
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: longhorn
EOF

cat > temp-pvcs/radarr-config.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: radarr-config
  labels:
    app: radarr
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: longhorn
EOF

cat > temp-pvcs/heimdall-config.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: heimdall-config
  labels:
    app: heimdall
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: longhorn
EOF

# Apply all PVC manifests
kubectl apply -f temp-pvcs/ -n $NAMESPACE

echo "PVCs recreated successfully."
echo "Note: You may need to restart your applications to reconnect to the new PVCs."
