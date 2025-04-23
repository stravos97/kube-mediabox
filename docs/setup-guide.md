# Kube-Mediabox Setup Guide

This guide will walk you through the process of setting up Kube-Mediabox on your Kubernetes cluster.

## Prerequisites

Before you begin, make sure you have:

1. A running Kubernetes cluster
2. Helm installed on your system
3. Storage space for your media files
4. kubectl configured to access your cluster

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/kube-mediabox.git
cd kube-mediabox
```

### 2. Configure MetalLB (if needed)

If you need to set up MetalLB for LoadBalancer services:

```bash
cd scripts/setup
chmod +x configure-metallb.sh
./configure-metallb.sh
```

This will:
- Install MetalLB if it's not already installed
- Configure an IP address pool (default: 192.168.1.20-192.168.1.40)
- Set up L2 advertisement

You can modify the IP range in `config/networking/metallb-config.yaml` before running the script.

### 3. Set Up Storage Classes

Apply the storage class configurations:

```bash
kubectl apply -f config/storage/longhorn.yaml
kubectl apply -f config/storage/longhorn-media.yaml
```

This creates:
- `longhorn` - For application configuration volumes
- `longhorn-media` - For shared media storage

### 4. Install Media Storage

Set up the shared storage for your media:

```bash
helm upgrade --install media-pv-pvc ./media-pv-pvc
```

### 5. Install Services

Install each service in the following order. Replace `yourdomain.xyz` with your actual domain:

```bash
# Heimdall Dashboard
cd heimdall
helm dependency build
cd ..
helm upgrade --install heimdall ./heimdall --set ingress.rules.host=heimdall.yourdomain.xyz

# SABnzbd Download Manager
cd sabnzbd
helm dependency build
cd ..
helm upgrade --install sabnzbd ./sabnzbd --set ingress.rules.host=sabnzbd.yourdomain.xyz

# Radarr Movie Manager
cd radarr
helm dependency build
cd ..
helm upgrade --install radarr ./radarr --set ingress.rules.host=radarr.yourdomain.xyz

# Sonarr TV Show Manager
cd sonarr
helm dependency build
cd ..
helm upgrade --install sonarr ./sonarr --set ingress.rules.host=sonarr.yourdomain.xyz

# Plex Media Server
cd plex
helm dependency build
cd ..
helm upgrade --install plex ./plex

# Ombi Request Manager
cd ombi
helm dependency build
cd ..
helm upgrade --install ombi ./ombi --set ingress.rules.host=ombi.yourdomain.xyz
```

## Configuration

### Storage Configuration

The project uses two storage classes:

1. **longhorn** - Used for application configuration volumes
   - Each application has its own PVC for configuration
   - These volumes are typically smaller (2-10Gi)
   - They use ReadWriteOnce access mode

2. **longhorn-media** - Used for shared media storage
   - A single large volume (default: 400Gi) shared by all applications
   - Uses ReadWriteMany access mode to allow multiple pods to access it
   - Mounted at `/mnt/` in each container

### Permissions

All services run with UID and GID of 911. If you encounter permission issues, set the correct permissions:

```bash
# Find a pod that has access to the volume
kubectl exec -it <pod-name> -- chown -R 911:911 /path/to/volume
```

### Customizing Services

Each service's configuration can be customized through its respective `values.yaml` file. Common customizations include:

- Changing ports
- Modifying resource limits
- Adjusting storage sizes
- Setting up TLS certificates

## Accessing Services

After installation, you can access your services:

1. **If using MetalLB**:
   - Services will be available at their assigned LoadBalancer IPs
   - Find the IPs with `kubectl get svc`

2. **If using Ingress**:
   - Services will be available at the configured hostnames
   - Make sure your DNS is configured to point to your cluster

## Troubleshooting

If you encounter issues, refer to the [Troubleshooting Guide](troubleshooting.md) for solutions to common problems.

## Maintenance

### Updating Services

To update a service:

```bash
cd <service-directory>
helm dependency build
cd ..
helm upgrade <service-name> ./<service-directory>
```

### Backing Up Configuration

It's recommended to back up your configuration volumes regularly. You can use Longhorn's backup features or export the data manually.

### Storage Class Issues

If you need to modify a StorageClass, refer to the scripts in `scripts/maintenance/` for handling this process safely.

## Next Steps

After setting up your media server:

1. Configure each service with your preferred settings
2. Add media sources to Radarr and Sonarr
3. Connect Plex to your media library
4. Set up user accounts and permissions
5. Configure automatic backups

Enjoy your personal media server on Kubernetes!
