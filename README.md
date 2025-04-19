# kube-mediabox
Mediabox services for Kubernetes via Helm, utilizing TrueCharts dependencies.

This project provides Helm charts for common mediabox services. It leverages the TrueCharts common chart for standardized configuration.

Services:

plex
sabnzbd
heimdall
radarr
sonarr
ombi

There are 2 ways to mount the config volume for the services. The default way is a local hostPath for a selected node. The other way is to use longhorn. If you want to use longhorn, you dont need the nodeSelector for the services. Keep in mind that sabnzbd/sonarr/radarr should be on the same node for speed reasons.
See instructions in the end.

For the config of each service the cluster needs it on a cluster with a nodeSelector mediabox. It is supposed to be in /config/{servicename}

There is a pv/pvc for shared mount volume for sabnzbd/sonarr/radarr
On my first try I did the same here with a running NFS server but importing of large files took forever, thats why I use a nodeSelector so those 3 service run on the same node.
The nodeSelector label is called mediabox.
This PV/PVC is a hostPath mount on the node on /mnt/
Please label your node accordingly:
``` kubectl label node3 app=mediabox ```

In my case plex and services have all the media mounted into /mnt/unionfs/Media/ and from there it goes to TV and Movies.
Plex has that folder mounted.
Service that folder via NFS or change it accordingly if you want it on all worker nodes.

Please change hostname of each service under service/values.yaml under ingress.rules.host.
you will find e.g.````radarr.yourservice.xyz````
Change it to your hostname, e.g. ```radarr.mediabox.xyz```
TLS is activated, so this assumes you have letsencrypt running on your cluster.
If you havent, delete the following on each ingress, e.g. service.yaml in /radarr:
```
  tls:
  - hosts:
    - radarr.yourservice.xyz
    secretName: radarr-tls
```

First install the media-pv-pvc:

```bash
helm upgrade --install media-pv-pvc ./media-pv-pvc
```

Then, for each service, update dependencies and install/upgrade:

**Note:** Replace `yourdomain.xyz` with your actual domain or hostname configuration.

**Heimdall:**
```bash
cd heimdall
helm dependency build
cd ..
helm upgrade --install heimdall ./heimdall --set ingress.rules.host=heimdall.yourdomain.xyz # Adjust hostname
```

**Sabnzbd:**
```bash
cd sabnzbd
helm dependency build
cd ..
helm upgrade --install sabnzbd ./sabnzbd --set ingress.rules.host=sabnzbd.yourdomain.xyz # Adjust hostname
```

**Radarr:**
```bash
cd radarr
helm dependency build
cd ..
helm upgrade --install radarr ./radarr --set ingress.rules.host=radarr.yourdomain.xyz # Adjust hostname
```

**Sonarr:**
```bash
cd sonarr
helm dependency build
cd ..
helm upgrade --install sonarr ./sonarr --set ingress.rules.host=sonarr.yourdomain.xyz # Adjust hostname
```

**Plex:**
```bash
cd plex
helm dependency build
cd ..
helm upgrade --install plex ./plex # Adjust values as needed
```

**Ombi:**
```bash
cd ombi
helm dependency build
cd ..
helm upgrade --install ombi ./ombi --set ingress.rules.host=ombi.yourdomain.xyz # Adjust hostname
```

please make sure that UID and GID of folders that are used are set to '911'

If you run into permission issues try to chown the folders first before installing via helm.

In my own setup I've started running longhorn (https://longhorn.io). Ive created a disk and created 1 volume for each service and created the PV/PVc within longhorn.
They are named $service-config, e.g. radarr-config.

### Longhorn
If you need want to install longhorn for this setup also (see https://longhorn.io/docs/1.2.2/deploy/install/install-with-helm/):

```helm repo add longhorn https://charts.longhorn.io```
``` helm repo update```
``` helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace```

Create 1 Disk on each node where you want your services running and set replicas of volumes accordingly.
You can attach, mount the volume in your node, and copy your data locally. Afterwards, deattach the volume again and create the pv/pvc via UI in longhorn.
