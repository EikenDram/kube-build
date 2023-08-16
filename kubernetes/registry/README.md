# Private registry on K3S server without internet access

Docker registry for air-gapped environment

## Tools image

Run
```sh
sudo nano Dockerfile
```

And enter:
```dockerfile
FROM alpine
RUN  apk --no-cache add curl && \
     apk --no-cache add skopeo --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
```

Build image with `podman`:
```sh
podman build -t tools:v1.0 .
```

Then copy the local image into a tar file:
```sh
skopeo copy containers-storage:localhost/tools:v1.0 docker-archive:./tools.tar:tools:v1.0
```

## Certificate

### Certificate settings

- cfssl.json
- registry.json
- serverRequest.json

### htpasswd

Install the `htpasswd` tool on the server and create `htpasswd` file for `admin`:
```sh
sudo htpasswd –B -c htpasswd admin
```

Enter password, for example: `coreos`

The htpasswd file should be looks like below:
```
admin:{{ .encrypted }}
```

### Create certificates

Install the `cfssl` and `cfssljson` tool from binaries.

Generate self-signed root CA cert:
```sh
cfssl gencert -initca registry.json | cfssljson -bare registry-ca
```

Check server port (6443 for K3S) by running `kubectl config view`

Generate server certificate:
```sh
cfssl gencert -ca=registry-ca.pem -ca-key=registry-ca-key.pem -config=cfssl.json -profile=server -hostname=K3S.LOCAL serverRequest.json | cfssljson -bare registry -server=https://127.0.0.1:6443
```

Let the OS trust the CA, `registry-ca.pem`:
```sh
sudo cp registry-ca.pem /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```

Update the k3s registry settings as in the configuration file, `registries.yaml`:
```sh
sudo mv registries.yaml /etc/rancher/k3s/
```

Path certs don't exist in configured directories, should create it:
```sh
sudo mkdir /etc/rancher/k3s/certs
sudo cp registry.pem /etc/rancher/k3s/certs/
sudo cp registry-key.pem /etc/rancher/k3s/certs/
sudo cp registry-ca.pem /etc/rancher/k3s/certs/
```

Restart the K3s service for the change to take effect:
```sh
sudo systemctl restart k3s
```

## Running private registry in K3S

Create the namespace
```sh
kubectl create namespace registry
```

Create secret with password:
```sh
kubectl -n registry create secret generic htpasswd --from-file=htpasswd=htpasswd
```

Create tls secret:
```sh
kubectl -n registry create secret tls tls-registry --cert=registry.pem --key=registry-key.pem
```

Create deployment:
```sh
kubectl create -f deployment.yaml
```

Now if you do a `curl` against the registry, you should see an empty list of the images:
```sh
curl -u admin:coreos https://K3S.LOCAL:5000/v2/_catalog
{"repositories":[]}
```

Run the tooling image for loading images into registry as a pod:
```sh
kubectl run loader --image=tools:v1.0 --command -- sh -c 'while true; do sleep 10; done'
```