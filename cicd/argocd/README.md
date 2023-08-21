# Argo CD

Continuous deployment for applications inside cluster

## Install

Install from manifests

Accessing UI via ingress:
```sh
kubectl apply -f install/argocd/ingress.yaml
```

Password is auto-generated, can get it via:
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Need to fix access with
```sh
kubectl apply -f install/argocd/argocd-params.yaml
kubectl scale -n argocd deployment/argocd-server --replicas=0 && kubectl scale -n argocd deployment/argocd-server --replicas=1
```

## Additional images

Different host and path for redis image
```
public.ecr.aws/docker/library/redis:7.0.11-alpine
```