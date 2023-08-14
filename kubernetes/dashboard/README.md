# Kubernetes dashboard

Dashboard for kubernetes cluster

## Images

```
kubernetesui/dashboard:v2.7.0
kubernetesui/metrics-scraper:v1.0.8
```

## Installing

Install dashboard:
```sh
kubectl apply -f manifest/dashboard/
```

Obtain the Bearer Token
```sh
kubectl -n kubernetes-dashboard create token admin-user --duration=0s
```

This way of accessing Dashboard is only recommended for development environments in a single node setup.

Edit `kubernetes-dashboard` service:
```sh
kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
```

You should see yaml representation of the service. Change `type: ClusterIP` to `type: NodePort` and save file.

Next we need to check port on which Dashboard was exposed:
```sh
kubectl -n kubernetes-dashboard get service kubernetes-dashboard
```

The output is similar to this:
```
NAME                   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes-dashboard   NodePort   10.100.124.90   <nodes>      443:31707/TCP   21h
```

Dashboard has been exposed on port 31707 (HTTPS). Now you can access it from your browser at: `https://K3S.LOCAL:31707`

Use token authorization, and copy bearer token from previous step