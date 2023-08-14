# Loki

Log aggregation service

## Images

```
docker.io/grafana/loki-canary:2.8.2
docker.io/grafana/agent-operator:v0.25.1
docker.io/nginxinc/nginx-unprivileged:1.19-alpine
docker.io/grafana/loki:2.8.2
docker.io/grafana/loki-helm-test:latest
docker.io/grafana/agent:v0.25.1
quay.io/prometheus-operator/prometheus-config-reloader:v0.47.0
docker.io/grafana/promtail:2.8.2

docker.io/grafana/promtail:2.7.4
grafana/loki:2.6.1
bats/bats:1.8.2
```

## Install

Install loki-stack from helm:
```sh
helm install loki-stack helm/loki-stack-2.9.10.tgz --namespace=monitoring
```

Get `loki-stack` service IP, and add a new loki datasource from grafana UI

This works, but remaining question is how to archive these logs, need to research into configuring loki to auto delete old logs