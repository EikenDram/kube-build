# port-forward from docker container

marcnuri/port-forward

```sh
kubectl run --env REMOTE_HOST=your.service.com --env REMOTE_PORT=8080 --env LOCAL_PORT=8080 --port 8080 --image marcnuri/port-forward test-port-forward

kubectl port-forward test-port-forward 8080:8080
```