# Kubernetes dashboard

Dashboard for kubernetes cluster

## Installing

Install from helm chart

Add access with
```sh
kubectl apply -f install/dashboard/access.yaml
```

Obtain the Bearer Token
```sh
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```