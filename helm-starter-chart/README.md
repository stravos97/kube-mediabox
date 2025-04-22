# Helm Starter Chart

This is a Helm starter chart designed to scaffold new applications for a media server setup, following the pattern used by applications like Lidarr, Radarr, and Sonarr:

* Deployment using a `StatefulSet` with a specific naming convention
* A dedicated configuration volume using a PersistentVolumeClaim
* Mounting of a shared media PersistentVolumeClaim
* Exposure via a `Service` (defaults to `LoadBalancer`)
* Optional `Ingress` resource creation with nginx annotations

## How to Use

1. Navigate to the directory where you want to create your new application chart.
2. Run the Helm create command using this starter chart:

   ```bash
   helm create <your-new-app-name> --starter path/to/helm-starter-chart
   ```

   (Replace `path/to/helm-starter-chart` with the actual path to this directory).

3. This will create a new directory named `<your-new-app-name>` containing the scaffolded chart based on this starter.

4. **Edit the `<your-new-app-name>/values.yaml` file:**

   * **Required:** Rename the `app` key under `statefulset` to match your application name (e.g., change `app` to `radarr`, `sonarr`, etc.)
   * **Required:** Set `statefulset.<app-name>.image.repository` and `statefulset.<app-name>.image.tag` to point to the container image for your application
   * **Adjust Service:** Modify `service.ports` with the correct port for your application
   * **Configure PVC:** Adjust `persistentVolumeClaim.storage` and `persistentVolumeClaim.storageClass` if needed
   * **Optional Ingress:** If you need an Ingress resource, set `ingress.enabled: true` and configure `ingress.rules.host` with your desired hostname

5. **Edit the template files if needed:**

   * Update any app-specific references in the templates (the templates use `{{ .Chart.Name }}` by default)
   * Ensure the volume mounts in `statefulset.yaml` match your application's requirements
   * The default configuration assumes:
     * A config volume mounted at `/config`
     * A shared media volume mounted at `/mnt/`
     * The shared media volume uses a PVC named `media-pv-pvc-claim`

6. Deploy your new application using Helm:

   ```bash
   helm install <release-name> ./<your-new-app-name> -n <namespace>
   ```

   (Replace `<release-name>`, `<your-new-app-name>`, and `<namespace>` appropriately).

## Example values.yaml

```yaml
statefulset:
  myapp:  # Replace 'myapp' with your application name
    nodeSelector:
      app: mediabox
    image:
      repository: lscr.io/linuxserver/myapp
      tag: latest
  replicas: 1
persistentVolumeClaim:
  storage: 2Gi  # Adjust storage size as needed
  storageClass: longhorn  # Use appropriate storage class for your cluster
service:
  ports:
  - port: 8080  # Replace with your app's port
    protocol: TCP
    targetPort: 8080  # Should match the port value
  type: LoadBalancer
ingress:
  enabled: false
  rules:
    host: myapp.mediabox.local  # Replace with your desired hostname
```

This starter chart provides a template for deploying media server applications with common networking patterns in Kubernetes.
