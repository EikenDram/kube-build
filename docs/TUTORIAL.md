# Tutorial

[Video link](https://youtube.com/2D)

## 1. Create new deployment

Download `build.tar.gz` and `build-tool.tar.gz` from [releases](https://github.com/EikenDram/kube-build/releases/) for your platform and unpack them

Open `config/values.yaml` and change necessary parameters:

| PARAMETER                 | DESCRIPTION
|---------------------------|-------------------
| **server**                | 
| hostname                  | hostname of your server
| ip                        | ip address of your server
| ssh                       | generate ssh key to access server with command `ssh-keygen` and copy content of `id_rsa.pub`
| admin.name admin.password | credentials for server's user that will use password authentication in case ssh key gets lost
| ntp                       | NTP server in your air-gapped network
| dummy                     | dummy default route for your server, if your network configuration doesn't have one
| **cluster**               |
| user password             | credentials that will be used for accessing most cluster resources
| **registry**              |
| user password             | credentials that will be used for accessing private docker registry
| cert                      | self-signed certificate configuration for docker registry
| **charts**                |
| user password             | credentials that will be used for accessing chartmuseum repository
| **prometheus**            |
| endpoint                  | endpoint for prometheus
| **velero**                |
| minio-url minio-public    | urls to minio server
| **ibmdb2**                |
| instance                  | db2 instance/admin name
| password                  | db2 instance/admin password
| **kube-home**             |
| contacts spec minio utils | configuration for cluster's home page

Once `values.yaml` is ready, run build tool in project root directory to build deployment in `deployment` directory:
```sh
./build
```

Build tool supports optional parameters to change default configuration files and directory names, check the available options by running:
```sh
./build --help
```

## 2. Prepare necessary files

Server will be in air-gapped environment so you'll need to download and transfer all the necessary files to the server first.

Run the `prepare.sh` script in `deployment` directory:
```sh
sh prepare.sh
```

You'll need to run it on an internet-facing machine in linux shell (for example, [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install-manual)) while having necessary tools:

- [helm](https://helm.sh/docs/intro/install/) for pulling helm charts
```sh
# for ubuntu:
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

- [skopeo](https://github.com/containers/skopeo/blob/main/install.md) for downloading docker images
```sh
# for ubuntu:
sudo apt-get -y install skopeo
```

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for cloning git repositories
```sh
# for ubuntu:
sudo apt install git
```

- `mkpasswd` and `htpasswd` tools for encrypting passwords

`prepare.sh` script supports optional parameters to prepare only specified parts of the deployment, check the available options by running:
```sh
sh prepare.sh -h
```

## 3. Install Fedora CoreOS on the new server

First you'll need to generate ignition file by running:
```sh
sh ignition.sh
```
and then having the ignition file `deployment/coreos.ign` to be accessible from some URL on the new server, for example: `http://URL/coreos.ign`

Live ISO will be downloaded to `deployment/bin/os/` directory, mount it on a new server and it'll load into memory-only mode with command prompt. 

You can check that ignition is accessible from server by running:
```sh
curl http://URL/coreos.ign
```

To install Fedora CoreOS run:
```sh
sudo coreos-installer install /dev/sda --ignition-url http://URL/coreos.ign --insecure-ignition
```

Next remove ISO and reboot the server:
```sh
sudo reboot
```

## 4. Deploy cluster components

Next step is to install kubernetes cluster and deploy applications on the server

Transfer necessary files to the server with `transfer.sh` or `transfer.bat` script in `deployment` directory:
```sh
sh transfer.sh
```

`transfer.sh` script supports optional parameters to transfer only specified parts of the deployment, you can check the available options by running:
```sh
sh transfer.sh -h
```

After transferring files connect to server with ssh:
```sh
ssh user@HOSTNAME
```
where `user` is server user defined in `values.yaml` and `HOSTNAME` is server's hostname

### Initialize OS

Run:
```sh
sudo os.sh
```
to change ntp server in air-gapped environment and add hostname to /etc/hosts

### Install K3S

Run:
```sh
sudo k3s.sh -i
k3s.sh -a
```
to place binaries in correct directories, add dummy default route, and install K3S

Wait until kubernetes cluster is up, you can monitor cluster with
```sh
k9s
```

![k9s](img/k9s.png)

### Deploy docker registry

Run:
```sh
sudo registry.sh -i
sudo registry.sh -a
```
to install cfssl binaries, load images into containerd from tar files, create certificates for the registry, and install private docker registry

### Deploy OpenEBS

Run:
```sh
sudo openebs.sh -i
openebs.sh
```
to remove `local-storage` from K3S on the next reboot, and install OpenEBS from manifests and set it as default storageclass

Reboot server with
```sh
sudo reboot
```
to remove `local-storage` from K3S

### Deploy Chartmuseum

Run:
```sh
sudo chartmuseum.sh -i
chartmuseum.sh
```
to add chartmuseum's address to /etc/hosts, and install Chartmuseum from helm chart

### Deploy Keycloak

Run:
```sh
keycloak.sh
```
to install Keycloak from helm chart

### Configure Keycloak

Access Keycloak cluster with provided URL an create a new realm called "cluster":

![keycloak-realm](img/keycloak-realm.png)

Create new client scopes called "audience":

![keycloak-scope-audience](img/keycloak-scope-audience.png)
![keycloak-scope-audience-mapper](img/keycloak-scope-audience-mapper.png)

and "groups":

![keycloak-scope-groups](img/keycloak-scope-groups.png)
![keycloak-scope-groups-mapper](img/keycloak-scope-groups-mapper.png)

Create new client called "oauth2-proxy":

![keycloak-client-1](img/keycloak-client-1.png)
![keycloak-client-2](img/keycloak-client-2.png)
![keycloak-client-3](img/keycloak-client-3.png)

Create new user as provided in `values.yaml`:

![keycloak-user](img/keycloak-user.png)

Check that user can authorize in client:

![keycloak-user-evaluate](img/keycloak-user-evaluate.png)

### Deploy OAuth2-proxy

Run:
```sh
sudo oauth2.sh -i
oauth2.sh
```
to initialize oauth2-proxy by entering client secret from Keycloak, and install reverse proxy for Keycloak

### Deploy Kubernetes dashboard

Run:
```sh
dashboard.sh
```
to install kubernetes dashboard from helm chart

Use provided long-lived token to access kubernetes dashboard

### Deploy Portainer CE

Run:
```sh
portainer.sh
```
to install Portainer CE from helm chart

Then access Portainer CE with provided URL and complete initial setup before server goes into timeout mode

### Deploy Docker registry UI

Run:
```sh
registry-ui.sh
```
to install docker registry dashboard from helm chart

Open registry with provided URL and allow insecure certificate in browser to be able to access registry dashboard

### Deploy Traefik dashboard

Run:
```sh
traefik-ui.sh
```
to install dashboard for traefik

### Deploy Prometheus and Grafana

Run:
```sh
sudo prometheus.sh -i
prometheus.sh
```
to configure K3S to work with prometheus, and install Prometheus and Grafana from helm chart

### Deploy Loki

Run:
```sh
loki.sh
```
to install Loki from helm chart

To view logs in grafana, add http://loki.monitoring:3100 as a new loki data source:

![loki](img/loki.png)

Import `loki-dashboard.json` from `bin/loki/` as a new dashboard in grafana to monitor loki logs:

![loki-dashboard](img/loki-dashboard.png)

### Deploy MinIO

This will install minio on same server as kubernetes cluster:
```sh
sudo minio.sh -i
sudo minio.sh
```

Access MinIO with provided URL and create a new bucked with the name "k3s":

![minio](img/minio.png)

### Deploy Velero

Run:
```sh
sudo velero.sh -i
velero.sh
```
to install Velero CLI binary, and install Velero from helm chart

### Deploy Gitea

Run:
```sh
sudo gitea.sh -i
gitea.sh
```
to add Gitea's address to /etc/hosts, and install Gitea from helm chart

### Deploy ArgoCD

Run:
```sh
sudo argocd.sh -i
argocd.sh
```
to initialize Argo CD installation, and install Argo CD from helm chart

### Deploy Tekton

Run:
```sh
sudo tekton.sh -i
tekton.sh
```
to install Tekton CLI binary, and install Tekton from manifests

### Deploy images for developing applications

Run:
```sh
dev.sh
```
to load necessary images for running package loaders into docker registry

### Deploy RabbitMQ server

Run:
```sh
rabbitmq.sh
```
to install Rabbit MQ server from helm chart

### Deploy IBM DB2 server

Run:
```sh
ibmdb2.sh
```
to install IBM DB2 community edition from custom helm chart

### Deploy IBM DB2 data management console

Run:
```sh
sudo db2console.sh -i
db2console.sh -a
```
to prepare mounted directory for installation, and install DB2 data management console as podman container on the server 

Access console with provided URL and configure repository database:

![db2console](img/db2console.png)

### Deploy RStudio server

Run:
```sh
rocker.sh
```
to install RStudio server from custom helm chart

### Deploy KubeHome

Run:
```sh
kube-home.sh
```
to install home page for cluster as ArgoCD application from custom helm chart using values in Gitea's `cluster-config` git repository

![kube-home](img/kube-home.png)

Edit `kube-home/values.yaml` in Gitea's `cluster-config` repository to update home page

### Deploy KubeR

Run:
```sh
kube-r.sh
```
to install service as ArgoCD application from custom helm chart using values in Gitea's `2D` git repository

### Deploy KubeUtils

Run:
```sh
kube-utils.sh
```
to publish KubeUtils tools in Gitea as git repository release

### Deploy KubeAppTemplate

Run:
```sh
kube-app-template.sh
```
to install template application as CI/CD tekton pipeline from Gitea's `kube-app-tempalte` git repository and ArgoCD application from manifest in Gitea's `kube-app-template-manifest` git repository
