# Argo CD

Continuous deployment for applications inside cluster

## Install

From manifest:
```sh
k create namespace argocd
k apply -n argocd -f argocd/install.yaml
```

Accessing Argo UI via Ingress:
```sh
k apply -f argocd/ingress.yaml
```

Password is auto-generated, can get it via:
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```