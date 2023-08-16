# Velero

Service for managing backups inside cluster

## Install

Install from helm chart

## Working with velero

To create backup of everything in selected namespace:
```sh
velero backup create $BACKUP --include-namespaces $NAMESPACE
```

