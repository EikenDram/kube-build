# Velero

Service for managing backups inside cluster

## Images

```
velero/velero:v1.11.0
docker.io/bitnami/kubectl:1.27
velero/velero-plugin-for-aws:v1.7.0
```

## Install

```sh
helm install velero helm/velero-4.0.3.tgz -f velero/values.yaml --namespace=velero --create-namespace --set-file credentials.secretContents.cloud=velero/minio-credentials
```

## Working with velero

To create backup of everything in namespace:
```sh
velero backup create <namespace-backup> --include-namespaces <namespace>
```

