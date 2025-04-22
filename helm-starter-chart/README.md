# Helm Starter Chart for Media Server Applications

Welcome to the Helm Starter Chart documentation! This guide will help you create and deploy media server applications on Kubernetes, even if you're new to Helm charts.

## What is This Chart?

This is a template (what we call a "starter chart" in Helm) that helps you deploy media server applications like Plex, Sonarr, or Radarr on Kubernetes. Think of it as a blueprint that includes all the common pieces these applications need:

- A way to run the application (using StatefulSet)
- Storage for the application's settings (using a dedicated volume)
- Access to your media files (using a shared volume)
- Network access to the application (using a LoadBalancer)
- Web access through your domain (optional, using Ingress)

## Prerequisites

Before you begin, make sure you have:

1. Kubernetes cluster up and running
2. Helm installed on your computer
3. kubectl configured to talk to your cluster
4. Basic understanding of YAML files

If you need to install any of these tools:

```bash
# Install Helm (on macOS using Homebrew)
brew install helm

# Install Helm (on Linux)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Check Helm installation
helm version
```

## Getting Started

Here's how to use this starter chart, broken down into simple steps:

### Step 1: Create Your New Application Chart

First, create a new chart for your application:

```bash
# Navigate to where you want to create your application
cd /path/to/your/projects

# Create a new chart using this starter
helm create my-new-app --starter path/to/helm-starter-chart
```

Replace `my-new-app` with whatever you want to call your application, and `path/to/helm-starter-chart` with the actual path to this starter chart.

### Step 2: Configure Your Application

Now you need to edit the `values.yaml` file in your new chart. Here's what to change:

1. Open `my-new-app/values.yaml` in your favorite text editor
2. Find the `statefulset` section and change these settings:

```yaml
statefulset:
  myapp:  # Change 'myapp' to your application name (e.g., 'plex', 'sonarr')
    nodeSelector:
      app: mediabox
    image:
      repository: lscr.io/linuxserver/myapp  # Change to your app's image
      tag: latest  # Change if you want a specific version
```

### Step 3: Configure Storage and Networking

In the same `values.yaml` file:

```yaml
# Storage settings
persistentVolumeClaim:
  storage: 2Gi  # Change if you need more space
  storageClass: longhorn  # Change if using different storage

# Network settings
service:
  ports:
  - port: 8080  # Change to your app's port
    protocol: TCP
    targetPort: 8080  # Usually same as port
  type: LoadBalancer

# Web access settings (optional)
ingress:
  enabled: false  # Set to true if you want web access
  rules:
    host: myapp.mediabox.local  # Change to your domain
```

### Step 4: Deploy Your Application

Once everything is configured, deploy your application:

```bash
# Create namespace (if you haven't already)
kubectl create namespace media

# Install your application
helm install my-app ./my-new-app -n media

# Check if it's running
kubectl get pods -n media

# Check the service
kubectl get services -n media

# Check the ingress (if enabled)
kubectl get ingress -n media
```

### Common Tasks

Here are some common commands you might need:

```bash
# Update your application after changes
helm upgrade my-app ./my-new-app -n media

# Remove your application
helm uninstall my-app -n media

# See the status of your application
helm status my-app -n media

# List all your Helm releases
helm list -n media
```

### Troubleshooting

If something goes wrong, try these commands:

```bash
# Check pod status
kubectl describe pod [pod-name] -n media

# Check logs
kubectl logs [pod-name] -n media

# Check persistent volumes
kubectl get pv,pvc -n media

# Check service status
kubectl describe service [service-name] -n media
```

## Understanding the Files

Your chart contains several important files:

- `values.yaml`: Main configuration file where you set your preferences
- `templates/statefulset.yaml`: Defines how your application runs
- `templates/service.yaml`: Sets up network access to your application
- `templates/ingress.yaml`: Configures web access (if enabled)
- `templates/pvc.yaml`: Sets up storage for your application

## Need Help?

If you run into issues:

1. Check the application logs using kubectl logs
2. Verify your values.yaml configuration
3. Make sure your Kubernetes cluster has enough resources
4. Confirm that storage and networking are properly configured

Remember: Kubernetes errors often appear in the pod's description or logs. Always start your troubleshooting there!

## Learning More

To learn more about how this works:

1. Read about StatefulSets in Kubernetes documentation
2. Learn about PersistentVolumes and PersistentVolumeClaims
3. Understand how Services and Ingress work in Kubernetes
4. Explore Helm chart structure and templates

Happy deploying! 🚀