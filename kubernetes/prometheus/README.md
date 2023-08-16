# Monitoring system

We'll use `prometheus` with `grafana` dashboards for monitoring K3S cluster

`kube-prometheus-stack` - deploying from helm kube-prometheus-stack (main)

## Install

Install from helm chart

Accessing UI via ingress will link `prometheus.k3s.local` and `grafana.k3s.local` to http request

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