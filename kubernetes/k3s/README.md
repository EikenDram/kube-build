# Kubernetes

We'll be using K3S as a single-node (at first) kubernetes cluster server

## Default route

K3s requires a default route in order to auto-detect the node's primary IP, and for kube-proxy ClusterIP routing to function properly. Therefore, a default route must be configured on each node, even if that route is a dummy route or a black hole.

```sh
sudo nmcli connection add type dummy ifname dummy0 ipv4.method manual ipv4.addresses 192.168.120.12/24 ipv4.gateway  192.168.120.1 ipv4.dns 8.8.8.8
sudo nmcli connection edit dummy-dummy0
save persistent
quit
```

CoreDNS will have a loop without dns server, so check that following is in `/etc/NetworkManager/system-connections/dummy-dummy0.nmconnection`

```ini
[ipv4]
dns=8.8.8.8;
dns-search=
```

## Installing

Now we can install K3S with command:

```sh
INSTALL_K3S_SKIP_DOWNLOAD=true INSTALL_K3S_EXEC="--write-kubeconfig-mode 644"  INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_SELINUX_WARN=true ./install.sh
```

## Editing etc/hosts

We'll need for kubernetes to be able to resolve its own hostname so need to add
```
127.0.0.1 K3S.LOCAL
```

to `etc/hosts`:
```sh
sudo nano /etc/hosts
```

## Helpful aliases for kubectl

Added K3S aliases `xx-aliases.sh` to `/etc/profile.d/` in butane config

## Using K9S to work with cluster

Add to default bash
```sh
sudo nano .bashrc
# Add next line to exports:
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

Now you can enter `k9s` to launch interface for managing cluster in ssh console