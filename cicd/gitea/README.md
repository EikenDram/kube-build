# Gitea

Git server and packages repository

## Install

From helm:
```sh
helm install gitea helm/gitea-8.3.0.tgz -f manifest/gitea/values.yaml --namespace=gitea --create-namespace
```

## Accessing UI

Ingress will link `git.k3s.local` to gitea server

From accessing machine add to hosts:
```
192.168.120.15  git.k3s.local
```