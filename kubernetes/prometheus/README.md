# Monitoring system

We'll use `prometheus` with `grafana` dashboards for monitoring K3S cluster

`kube-prometheus-stack` - deploying from helm kube-prometheus-stack (main)

# Images

```
docker.io/jimmidyson/configmap-reload:v0.5.0
docker.io/grafana/grafana:9.5.3
docker.io/bats/bats:v1.4.1
quay.io/brancz/kube-rbac-proxy:v0.14.1
quay.io/prometheus/alertmanager:v0.25.0
quay.io/prometheus/blackbox-exporter:v0.24.0
quay.io/prometheus/node-exporter:v1.5.0
quay.io/prometheus/prometheus:v2.44.0
quay.io/prometheus-operator/prometheus-operator:v0.65.1
quay.io/prometheus-operator/prometheus-operator:v0.65.2
quay.io/prometheus-operator/prometheus-config-reloader:v0.65.1
quay.io/prometheus-operator/prometheus-config-reloader:v0.65.2
quay.io/kiwigrid/k8s-sidecar:1.24.3
registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.9.2
registry.k8s.io/prometheus-adapter/prometheus-adapter:v0.10.0
registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6
```

## Install

Install from helm package:
```sh
helm install kube-prometheus-stack helm/kube-prometheus-stack-46.8.0.tgz -f monitoring/values.yaml --namespace=monitoring  --create-namespace
```

Upgrade values:
```sh
helm upgrade kube-prometheus-stack helm/kube-prometheus-stack-46.8.0.tgz -f monitoring/values.yaml --namespace=monitoring
```

## Accessing UI

Ingress will link `prometheus.k3s.local` and `grafana.k3s.local` to http request

From accessing machine add server ip with these names to hosts:
```
192.168.120.15 prometheus.k3s.local
192.168.120.15 grafana k3s.local
```

## Optimizing

Check top metrics with query:
```
topk(10, count by (__name__)({__name__=~".+"}))
```

To see metrics themselves access pod with
```sh
k exec -ti prometheus-kube-prometheus-stack-core-prometheus-0 -n monitoring -- /bin/sh
```

Then you can use promtool to check metrics
```sh
promtool query series http://localhost:9090 --match=etcd_request_duration_seconds_bucket
```

To remove metrics from storage:
```sh
curl -X POST -g 'http://prometheus.k3s.local/api/v1/admin/tsdb/delete_series?match[]=apiserver_request_duration_seconds_bucket'
```

Could use further optimizing (switching to keep for selected metrics that i need in those servicemonitors configurations), but it's a lot of work, and think this is fine as it is so far, maybe reduce retention to couple of days?

## Uninstalling

Can check installed helm packages
```sh
helm list -n monitoring
```

For uninstalling
```sh
helm uninstall kube-prometheus-stack -n monitoring
```