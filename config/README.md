# Information

This is a deployment for K3S cluster from `https://github.com/EikenDram/Kubernetes` project

Build log in `log/build.log` file

Build values in `log/values.yaml` file

Build version in `log/version.yaml` file

Build version in `log/version.yaml` file

Build version in `log/version.yaml` file

# Deployment

Connect to server with `ssh {{.Values.server.user}}@{{.Values.server.hostname}}`, go to `deployment` directory with `cd deployment` command and start running scripts:

## Required components

### 1. OS initialization

Run
```sh
sudo os.sh
```
to change ntp server in air-gapped environment and add hostname to /etc/hosts

### 2. [K3S](https://k3s.io/)

Kubernetes cluster

Run
```sh
sudo k3s.sh -i
```
to place binaries in correct directories, and to add dummy default route

Next, run
```sh
k3s.sh -a
```
to install K3S

Wait until K3S is up before proceeding to the next step

### 3. [Docker registry](https://docs.docker.com/registry/)

Private docker registry to pull container images from in our air-gapped environment

Run
```sh
sudo registry.sh -i
```
to install cfssl binaries, load images into containerd from tar files, and create certificates for the registry

Next, run
```sh
sudo registry.sh -a
```
to install docker registry

### 4. [OpenEBS](https://openebs.io/)

Kubernetes storage provider

Run
```sh
sudo openebs.sh -i
```
to remove local-storage from K3S on the next reboot

Next, run
```sh
openebs.sh
```
to install OpenEBS from manifests and set it as default storageclass

Reboot server with `sudo reboot` to remove `local-storage` from K3S

### 5. [Chartmuseum](https://chartmuseum.com/)

Helm chart repository

Run
```sh
sudo chartmuseum.sh -i
```
to add chartmuseum's address to /etc/hosts

Next, run
```sh
chartmuseum.sh
```
to install Chartmuseum from helm chart

### 6. [Keycloak](https://www.keycloak.org/)

Access management

Run
```sh
keycloak.sh
```
to install Keycloak from helm chart

### 7. [OAuth2-proxy](https://github.com/oauth2-proxy/oauth2-proxy)

Reverse proxy

Run
```sh
oauth2.sh
```
to load OAuth2-proxy image to registry

## Kubernetes management

### [Traefik dashboard](https://doc.traefik.io/traefik/operations/dashboard/)

Run
```sh
traefik-ui.sh
```
to install dashboard for traefik

### [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

Run
```sh
dashboard.sh
```
to install kubernetes dashboard from helm chart

Use long-lived token printed in console to access the dashboard

You can retrieve token later with command
```sh
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

### [Portainer CE](https://docs.portainer.io/start/install-ce)

Run
```sh
portainer.sh
```
to install Portainer CE from helm chart

After installing you need to access portainer through web to do initial setup before portainer goes into timeout mode

### [Docker registry UI](https://github.com/Joxit/docker-registry-ui)

Dashboard for the private docker registry

Run
```sh
registry-ui.sh
```
to install docker registry dashboard from helm chart

Since docker registry uses self-signed certificate there will be error when accessing the dashboard for the first time

Access the registry with http://{{.Values.server.hostname}}:5000 and allow insecure certificate to be able to use registry dashboard

## Monitoring

### 1. [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/)

Monitoring stack from `prometheus-community/kube-prometheus-stack` helm chart

Run
```sh
sudo prometheus.sh -i
```
to configure K3S to work with prometheus

Next, run
```sh
prometheus.sh
```
to install Prometheus and Grafana from helm chart

Import `openebs-dashboard.json` from `bin/prometheus` as a new dashboard in grafana to monitor openebs

### 2. [Loki](https://grafana.com/oss/loki/)

Log aggregator stack from `grafana/loki-stack` helm chart

Run
```sh
loki.sh
```
to install Loki from helm chart

To view logs in grafana, add http://loki.{{.Values.prometheus.helm.namespace}}:3100 as a new loki data source

Import `loki-dashboard.json` from `bin/loki/` as a new dashboard in grafana to monitor loki logs

## Backup

### 1. [Minio](https://min.io/)

Storage for backups (should be preferably installed on a separate server, and velero configured accordingly)

Run
```sh
sudo minio.sh
```
to install MinIO on server

Then access server and create a bucket with name {{.Values.minio.bucket}}

### 2. [Velero](https://velero.io/)

Backup tool for creating cluster backups to MinIO storage

Run
```sh
sudo velero.sh -i
```
to install Velero CLI binary

Next, run
```sh
velero.sh
```
to install Velero from helm chart

## CI/CD

### 1. [Gitea](https://about.gitea.com/)

Git, nuget, npm repository server

Run
```sh
sudo gitea.sh -i
```
to add gitea's address to /etc/hosts

Next, run
```sh
gitea.sh
```
to install Gitea from helm chart

### 2. [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)

Continuous delivery service 

Run
```sh
argocd.sh
```
to install Argo CD from helm chart

Password for user {{.Values.cluster.user}} will be auto-generated and displayed in console

Can retrieve it later with command
```sh
kubectl -n {{.Values.argocd.namespace}} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### 3. [Tekton](https://tekton.dev/)

Continuous integration and continuous delivery pipelines 

Run
```sh
sudo tekton.sh -i
```
to install Tekton CLI binary

Next, run
```sh
tekton.sh
```
to install Tekton from manifests

### 4. Developing applications

Images for running tekton pipelines

Run
```sh
dev.sh
```
to load necessary images to run package loaders and init cluster-config git repository to gitea

## Services

### [Rabbit MQ](https://www.rabbitmq.com/)

Message queue server 

Run
```sh
rabbitmq.sh
```
to install Rabbit MQ server from helm chart

### [IBM DB2 community edition](https://www.ibm.com/products/db2/developers)

Database server 

Run
```sh
ibmdb2.sh
```
to install IBM DB2 community edition from custom helm chart

### [DB2 data management console](https://www.ibm.com/products/db2-data-management-console)

Database server management console (will run inside podman container on the server)

Run
```sh
db2console.sh
```
to install DB2 data management console as podman container on server

### [R studio server](https://posit.co/download/rstudio-server/)

Run
```sh
rocker.sh
```
to install R Studio server from custom helm chart

## Applications

### KubeHome

Home page for cluster

Run
```sh
kube-home.sh
```
to install home page for cluster as ArgoCD application from helm chart hosted on chartmuseum and `values.yaml` from git repository `cluster-config` hosted on gitea

### KubeR

Service to run R scripts from message queue

Run
```sh
kube-r.sh
```
to install service as ArgoCD application from helm chart hosted on chartmuseum and `values.yaml` from git repository `2D` hosted on gitea

### KubeUtils

Console tools for managing cluster

Run
```sh
kube-utils.sh
```
to publish tools in cluster as git repository release

### KubeAppTemplate

Template application

Run
```sh
kube-app-template.sh
```
to install application as full CI/CD with tekton pipeline and ArgoCD application from manifest in kube-app-template-manifest git repository