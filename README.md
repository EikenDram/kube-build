# About

This is a CLI tool for building a [K3S](https://k3s.io/) kubernetes cluster deployment for a [Fedora CoreOS](https://fedoraproject.org/coreos/) server in an air-gapped environment

## Introduction

Coming from developing .net web applications for windows server, switching recently to dotnet core allowed me to build applications for linux platform as well. Decided to try updating server architecture to cloud and implement some DevOps; after a bit of research ended up with K3S on Fedora CoreOS - as something that looked simple enough to start with.

This project was initially a set of notes about setting everything up on a virtual machine, but as the production environment i'm working with is air-gapped, setting everything up required quite a lot of additional work, which I then decided to automate by making this tool.

## Cluster configuration

| COMPONENT         | DIRECTORY              | CONTENT
|-------------------|------------------------|-----------------------------------
| **SYSTEM**        |                        |
| os                | os/coreos              | [Fedora CoreOS](https://fedoraproject.org/coreos/)
| vmtools           | os/vmtools             | Optional [vmware tools](https://github.com/vmware/open-vm-tools)
| port-forward      | os/port-forward        | Optional [port-forwarding container](https://hub.docker.com/r/marcnuri/port-forward/)
| **KUBERNETES**    |                        |
| k3s               | kubernetes/k3s         | [K3S](https://k3s.io/) kubernetes cluster
| registry          | kubernetes/registry    | Private [Docker registry](https://docs.docker.com/registry/)
| openebs           | kubernetes/openebs     | [OpenEBS](https://openebs.io/) storage provider
| chartmuseum       | kubernetes/chartmuseum | Helm chart repository [Chartmuseum](https://chartmuseum.com/)
| keycloak          | kubernetes/keycloak    | Access manager [Keycloak](https://www.keycloak.org/)
| oauth2            | kubernetes/oauth2      | Reverse proxy [OAuth2-proxy](https://oauth2-proxy.github.io/oauth2-proxy/)
| dashboard         | kubernetes/dashboard   | [Kubernetes dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
| portainer         | kubernetes/portainer   | Kubernetes manager [Portainer CE](https://docs.portainer.io/start/install-ce)
| registry-ui       | kubernetes/registry-ui | [Docker registry dashboard](https://github.com/Joxit/docker-registry-ui)
| traefik-ui        | kubernetes/traefik-ui  | [Traefik dashboard](https://doc.traefik.io/traefik/operations/dashboard/)
| prometheus        | kubernetes/prometheus  | Monitoring service [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/)
| loki              | kubernetes/loki        | Logging service [Loki](https://grafana.com/oss/loki/)
| minio             | kubernetes/minio       | Backup storage [MinIO](https://min.io/)
| velero            | kubernetes/velero      | Backup service [Velero](https://velero.io/)
| nfs               | kubernetes/nfs         | [NFS server] (https://hub.docker.com/r/itsthenetwork/nfs-server-alpine)
| **CI/CD**         |                        |
| gitea             | cicd/gitea             | Git and package repository [Gitea](https://about.gitea.com/)
| tekton            | cicd/tekton            | CI/CD pipeline [Tekton](https://tekton.dev/)
| argocd            | cicd/argocd            | CD automation [Argo CD](https://argo-cd.readthedocs.io/en/stable/)
| dev               | cicd/dev               | Loaders for npm/nuget/go packages into gitea
| **SERVICES**      |                        |
| ibmdb2            | services/ibmdb2        | [IBM DB2 community edition](https://www.ibm.com/products/db2/developers) database server
| db2console        | services/db2console    | [DB2 data management console](https://www.ibm.com/products/db2-data-management-console)
| rabbitmq          | services/rabbitmq      | Message query server [Rabbit MQ](https://www.rabbitmq.com/)
| rocker            | services/rocker        | [RStudio server](https://posit.co/download/rstudio-server/)
| **APPLICATIONS**  |                        |
| kube-home         | apps/kube-home         | [KubeHome](https://github.com/EikenDram/kube-home) home page for cluster
| kube-r            | apps/kube-r            | [KubeR](https://github.com/EikenDram/kube-r) service for processing reports as R scripts
| kube-utils        | apps/kube-utils        | [KubeUtils](https://github.com/EikenDram/kube-utils) tools for managing cluster resources
| kube-app-template | apps/kube-app-tempalte | [KubeAppTemplate](https://github.com/EikenDram/kube-app-template) template application

## Development status

KubeR, KubeUtils, KubeAppTemplate, Keycloak authorization, application development are work in progress

## Project structure

- `apps` - Application components
- `cicd` - Continuous Integration/Continuous Delivery components
- `config` - Build configuration
- `deployment` - Default cluster deployment
- `docker` - Docker files
- `kubernetes` - Kubernetes components
- `os` - OS component
- `services` - Service components
- `src` - source code for build tool
- `Cookbook.md` - List of commands i wrote down as i was learning linux

# Tutorial 

[Tutorial](docs/TUTORIAL.md) is available in `docs` directory

# Compilation

## Running from source code

Install [go](https://go.dev/)

Clone this git repository and run 
```sh
go run github.com/EikenDram/kube-build/build
```

## Building from source code

Run 
```sh
GOOS=$os GOARCH=$arch go build github.com/EikenDram/kube-build/build
``` 
for building tool for specific platform

## Customization

### Configuration files

Build tool uses `text/template` module to process files as templates using following data:

- `.Values` contains component values configuration loaded from `config/values.yaml` by default

- `.Version` contains component version configuration loaded from `config/version.yaml` by default

- `.Images` contains component images configuration loaded from `config/images.yaml` by default

- `.Components` contains build configuration loaded from `config/build.json` by default

### Update images configuration

Build tool has command `images` that creates `images.sh` script in deployment directory from template `_images.sh` in `config` directory, runs it and updates `images.yaml` configuration with the list of used images from helm charts, .yaml files in manifest and install directories, and images from `config/version.yaml` (for some charts the image plugin wont retrieve all the images that will be used in deployment, you will have to update those versions manually)

Script uses:
- `/bin/bash` linux shell

- `helm` tool with installed [images](https://github.com/nikhilsbhat/helm-images) plugin 
```sh
helm plugin install https://github.com/nikhilsbhat/helm-images
```

- [yq](https://github.com/mikefarah/yq) tool
```sh
# for ubuntu
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod a+x /usr/local/bin/yq
```

### Build process

Build program goes through all components as defined in `components` array in `build.json`, looks for files in `.path` + `/template/` directory, and processes them as follow:

- `_prepare.sh` files are all appended to `config/_prepare.sh` into single `config/prepare.sh` template and then processed into `deployment/prepare.sh` script

- `_script.sh` files are each combined with `config/_script.sh` and processed into `deployment/scripts/{component name}.sh` scripts

- everything else is processed as a template into `deployment/install/{component name}/` directory with the same file name

Files in `.path` + `/copy/` directory are copied into deployment directly

### Script templates

Templates `_prepare.sh` and `_script.sh` in `config` directory contain service scripts and following sub-templates:

- `_prepare.sh`/`prepare` - template for preparing component files, pass component value from `.Versions`

- `_script.sh`/`script` - template for running script, pass `dict` function with `Values` as `.Values`, `Version` as component value from `.Version`, `Images` as component value from `.Images` and `Value` as component value from `.Values`; template contains following blocks:
  - `init` - initializing components, should be run as root user
  - `install` - installing component
  - `install-pre` - injection before helm install
  - `install-post` - injection after helm install
  - `install-echo` - injecting message about component install
  - `upgrade` - upgrading component
  - `upgrade-pre` - injection before helm upgrade
  - `upgrade-post` - injection after helm upgrade
  - `upgrade-echo` - injecting message about component upgrade
  - `uninstall` - uninstalling component
  - `uninstall-pre` - injection before helm uninstall
  - `uninstall-post` - injection after helm uninstall
  - `uninstall-echo` - injecting message about component uninstall

Place a `#` at the end of `-echo` block to comment out the default message if necessary

- `_script.sh`/`wait` - template for waiting for the pod to be ready, pass `dict` function with `Label` as name of pod label, `Name` as value of pod label and `Namespace` as value of pod namespace

- `_script.sh`/`etc-hosts` - template for adding records to `/etc/hosts` on server, pass `dict` function with `Values` as `.Values` and `Ingress` as ingress value

### Build configuration

Build configuration is loaded from `build.json`, with following structure: 
```json
{
  "pre": [],
  "build": [],
  "components": [],
  "post": []
}
```

`components` array contains a list of all build components with structure:
```json
{
  "name": "",
  "path": "",
  "message": "",
  "comment" : ""
}
```
Where:
- `comment` - description of a component
- `name` - the name of component as defined in `version.yaml` and `values.yaml`
- `path` - path relative to project root where `deploy` directory of a component is located
- `message` - title of component as displayed in build log

`pre`, `build` and `post` arrays contain a list of build commands with structure: 
```json
{
  "comment": "",
  "message": "",
  "type": "",
  "name": "",
  "location": "",
  "from": {
    "location": "",
    "name": ""
  },
  "to": {
    "location": "",
    "name": ""
  }
}
```
Where:
- `comment` - description of command
- `message` - a message displayed in build log
- `location` - a value from:
  - `config` - directory name will be equal to one with configurations during build
  - `deployment` - directory name will be equal to one of deployment during build
- `type` is a value from:
  - `remove` - removes file `.name` from `.location` directory
  - `removeAll` - removes directory `.name` from `.location` directory
  - `mkDir` - creates new directory `.name` in `.location` directory
  - `copy` - copies file `.from.name` in `.from.location` directory to file `.to.name` in `.to.location` directory
  - `move` - moves file `.from.name` in `.from.location` directory to file `.to.name` in `.to.location` directory
  - `template` - processes file `.from.name` in `.from.location` as template into file `.name` in deployment directory

### Snippets

Project contains [Visual Studio Code](https://code.visualstudio.com/) snippets for `_prepare.sh` and `_script.sh` script templates in component's `deploy` directories, shortcuts are: `shPrepare` and `shScript`

### VS Code launch.json

```json
        {
            "name": "Launch Build",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "program": "${workspaceFolder}/src/",
            "cwd": "${workspaceFolder}",
            "args": [
                "--values=values.yaml"
            ]
        }
```
