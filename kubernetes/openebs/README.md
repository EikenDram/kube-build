# Open EBS

Storage service for kubernetes cluster

## Images

```
openebs/node-disk-manager:2.1.0
openebs/node-disk-operator:2.1.0
openebs/node-disk-exporter:2.1.0
openebs/provisioner-localpv:3.4.0
openebs/linux-utils:3.4.0
```

## Install

Install local-pv minimal installation with: 
```sh
kubectl apply -f storage/openebs-operator-lite.yaml 
kubectl apply -f storage/openebs-lite-sc.yaml
```

## Changing default storageclass to openebs

Run
```sh
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

Check that openebs is default now
```sh
kubectl get storageclass
```

## Test that the storage is working

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