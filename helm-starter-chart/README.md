# Helm Starter Chart

This is a Helm starter chart designed to scaffold new applications following a common pattern:

*   Deployment using a `StatefulSet`.
*   A dedicated configuration volume managed by a `VolumeClaimTemplate` (defaults to `longhorn` StorageClass).
*   Ability to mount one or more existing PersistentVolumeClaims (PVCs) for shared data.
*   Exposure via a `Service` (defaults to `LoadBalancer`).
*   Optional `Ingress` resource creation.

## How to Use

1.  Navigate to the directory where you want to create your new application chart.
2.  Run the Helm create command using this starter chart:

    ```bash
    helm create <your-new-app-name> --starter path/to/helm-starter-chart
    ```

    (Replace `path/to/helm-starter-chart` with the actual path to this directory).

3.  This will create a new directory named `<your-new-app-name>` containing the scaffolded chart based on this starter.

4.  **Edit the `<your-new-app-name>/values.yaml` file:**

    *   **Required:** Set `appName` to a unique name for your application (e.g., `radarr`, `my-app`).
    *   **Required:** Set `image.repository` and `image.tag` to point to the container image for your application.
    *   **Required for Shared Volumes:** Configure the `persistence.shared` list. For each shared volume you need to mount (like your `media-pv-pvc-claim`):
        *   Provide a unique `name` for the mount (e.g., `shared-data`, `downloads`).
        *   Set `enabled: true`.
        *   Set `existingClaim` to the name of the PVC in your cluster.
        *   Set `mountPath` to the desired path inside the container.
        *   Optionally set `subPath` if you need to mount a specific subdirectory from the PVC.
    *   **Adjust Defaults:** Modify `service.ports`, `env` variables (like `PUID`, `PGID`, `TZ`), `persistence.config.size`, `replicaCount`, and other values as needed for your specific application.
    *   **Optional Ingress:** If you need an Ingress resource, set `ingress.enabled: true` and configure `ingress.hosts`, `ingress.tls`, and `ingress.className` as required.

5.  Deploy your new application using Helm:

    ```bash
    helm install <release-name> ./<your-new-app-name> -n <namespace>
    ```

    (Replace `<release-name>`, `<your-new-app-name>`, and `<namespace>` appropriately).

This starter chart provides a flexible template for deploying stateful applications with common persistence and networking patterns in Kubernetes.
