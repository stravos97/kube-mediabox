# Gluetun VPN Client Helm Chart

This Helm chart deploys Gluetun, a VPN client and proxy container, on Kubernetes. Gluetun supports various VPN providers and protocols, making it ideal for securing your Kubernetes applications.

## Features

- Supports multiple VPN providers (NordVPN, PIA, Mullvad, etc.)
- Supports OpenVPN and WireGuard protocols
- Built-in HTTP proxy for other containers to use
- Web UI for monitoring and configuration
- Automatic updates of VPN server lists

## Prerequisites

Before you begin, make sure you have:

1. Kubernetes cluster up and running
2. Helm installed on your computer
3. kubectl configured to talk to your cluster
4. VPN service credentials (username/password or WireGuard keys)

## Installation

### Step 1: Create a Secret for VPN Credentials

First, create a Kubernetes secret to store your sensitive VPN credentials:

```bash
# For WireGuard (as configured in this chart)
kubectl create secret generic gluetun-wireguard-secret \
  --from-literal=WIREGUARD_PRIVATE_KEY='your_private_key_here' \
  --from-literal=WIREGUARD_ADDRESSES='your_wireguard_ip/32' \
  -n your-namespace
```

Replace `your_private_key_here` and `your_wireguard_ip/32` with your actual WireGuard credentials.

### Step 2: Configure the Chart

The default configuration in `values.yaml` is set up for NordVPN with WireGuard. You may need to adjust these settings based on your VPN provider and preferences:

```yaml
statefulset:
  gluetun:
    # VPN configuration
    env:
      VPN_SERVICE_PROVIDER: nordvpn  # Change to your provider
      VPN_TYPE: wireguard            # or openvpn
      SERVER_REGIONS: Europe         # Change to your preferred region
      # Other settings...
```

### Step 3: Deploy Gluetun

Deploy the chart using Helm:

```bash
# Create namespace if needed
kubectl create namespace vpn

# Install the chart
helm install gluetun ./gluetun -n vpn

# Check if it's running
kubectl get pods -n vpn
```

## Usage

### Accessing the Web UI

The Gluetun web UI is available on port 8888. If you've deployed with LoadBalancer service type, you can access it at:

```
http://<load-balancer-ip>:8888
```

### Using Gluetun as a Proxy for Other Applications

To use Gluetun as a proxy for other applications, configure them to use the Gluetun service as an HTTP proxy:

```
http://<gluetun-service>:8888
```

For example, in a Docker/Kubernetes environment:

```yaml
environment:
  - HTTP_PROXY=http://gluetun-service:8888
  - HTTPS_PROXY=http://gluetun-service:8888
```

## Configuration

### Important Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `statefulset.gluetun.image.repository` | Gluetun image repository | `qmcgaw/gluetun` |
| `statefulset.gluetun.image.tag` | Gluetun image tag | `latest` |
| `statefulset.gluetun.env.VPN_SERVICE_PROVIDER` | VPN provider | `nordvpn` |
| `statefulset.gluetun.env.VPN_TYPE` | VPN protocol | `wireguard` |
| `statefulset.gluetun.env.SERVER_REGIONS` | VPN server regions | `Europe` |
| `statefulset.gluetun.secrets.existingSecret` | Secret containing credentials | `gluetun-wireguard-secret` |
| `service.ports[0].port` | Web UI port | `8888` |
| `persistentVolumeClaim.storage` | Storage size for config | `1Gi` |

## Troubleshooting

If you encounter issues:

1. Check the Gluetun logs:
   ```bash
   kubectl logs -l app=gluetun -n your-namespace
   ```

2. Verify your secret was created correctly:
   ```bash
   kubectl describe secret gluetun-wireguard-secret -n your-namespace
   ```

3. Check if the pod has the NET_ADMIN capability:
   ```bash
   kubectl describe pod -l app=gluetun -n your-namespace
   ```

## Security Considerations

- The WireGuard private key is sensitive information. Always use Kubernetes secrets to store it.
- The container requires the NET_ADMIN capability, which is a privileged operation.
- Consider network policies to restrict which pods can access the Gluetun proxy.

## Upgrading

To upgrade the chart:

```bash
helm upgrade gluetun ./gluetun -n your-namespace
```

## Uninstalling

To uninstall the chart:

```bash
helm uninstall gluetun -n your-namespace
```

## Additional Resources

- [Gluetun GitHub Repository](https://github.com/qdm12/gluetun)
- [Gluetun Documentation](https://github.com/qdm12/gluetun/wiki)
