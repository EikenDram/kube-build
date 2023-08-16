# Open EBS

Storage service for kubernetes cluster

## Install

Install local-pv minimal from manifests

Changing default storageclass to openebs
```sh
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

Check that openebs is default now
```sh
kubectl get storageclass
```

## Testing

Run
```sh
k apply -f storage/local-hostpath-pvc.yaml
k apply -f storage/local-hostpath-pod.yaml
```

Check that data is being written:
```sh
kubectl exec hello-local-hostpath-pod -- cat /mnt/store/greet.txt
```

Verify that container is using openebs:
```sh
kubectl describe pod hello-local-hostpath-pod
```

Clean up:
```sh
kubectl delete pod hello-local-hostpath-pod
kubectl delete pvc local-hostpath-pvc
```

## Troubleshooting
OpenEBS Dynamic Local Provisioner logs can be fetched using:
```sh
kubectl logs -n openebs -l openebs.io/component-name=openebs-localpv-provisioner
```

## Monitoring

There's a ServiceMonitor for prometheus operator, but not sure if it works with the lite version