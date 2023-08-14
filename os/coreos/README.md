# Installing OS

Will be using CoreOS with K3S kubernetes cluster of a single server for start

Download and mount CoreOS image `image/fedora-coreos-38.20230609.3.0-live.x86_64.iso`, server will load into memory-only mode with command prompt

## Prepare ignition file

Download `butane-x86_64-pc-windows-gnu.exe` to make ignition file out of yaml

### Hostname

This part is server's hostname:
```yaml
- path: /etc/hostname
      mode: 0644
      contents:
        inline: <HOSTNAME>
```

### SSH

This section with is SSH key for user `core`
```yaml
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - ssh-rsa <SSH>
```

To generate it from windows:
```sh
ssh-keygen
```

Copy content of the key from `id_rsa` file
```
ssh-rsa <COPY KEY>
```

And paste it to yaml configuration:
```yaml
  ssh_authorized_keys:
    - ssh-rsa <PASTE KEY HERE>
```

### Admin password

This section adds user `admin` with `sudo` and `docker` groups
```yaml
    - name: admin
      groups:
        - "sudo"
        - "docker"
      password_hash: <HASH>
```

To generate secure password hash, use `mkpasswd` from the `whois` package by running it from a container:
``` sh
podman run -ti --rm quay.io/coreos/mkpasswd --method=yescrypt
```

## Deploy ignition file

Ignition file needs to be accessible from new server through some url (`192.168.120.3` for example): `http://192.168.120.3/coreos.ign`

Check that ignition file is accessible from server with command: 
```sh
curl http://192.168.120.3/coreos.ign
```

If you deploy `coreos.ign` in IIS add this MIME type for `.ign`: `application/vnd.coreos.ignition+json`

## Install CoreOS

Install CoreOS with command:
```sh
sudo coreos-installer install /dev/sda --ignition-url http://192.168.120.3/coreos.ign --insecure-ignition
```

Turn off server with 
```sh
sudo shutdown
``` 

and remove ISO image. Ensure that server is accessible by the hostname thought DNS or `hosts` file, after booting server again we can connect to it through ssh with:
```sh
ssh core@$HOSTNAME
```

We can also access server with password for user `admin` as defined in yaml configuration

## Synchronizing time and date

By default CoreOS will use internet ntp servers

In air-gapped environment we'll need to replace it with some internal NTP server:
```sh
sudo nano /etc/chrony.conf
```

Replace source with:
```sh
server $NTP_IP iburst 
```

Restart chrony service with
```sh
sudo systemctl restart chronyd
```

Server should sync up with NTP after a while

## Installing packages

If we'll be using Longhorn as storage manager for kubernetes cluster, we need to replace `nfs-utils-core` rpm package with `nfs-utils`

To do this found this `rpm` image:

```dockerfile
FROM registry.fedoraproject.org/fedora:33
RUN dnf install -y nginx dnf-utils createrepo_c && dnf clean all
WORKDIR /srv/repo
RUN yumdownloader httpd-tools nfs-utils skopeo apr apr-util
ENTRYPOINT nginx -g 'daemon off;'
```

Now you’d need to build this image, deploy and expose it via service / route. Once hosts can reach it, place a repo config pointing to this service in `/etc/yum.repos.d`
```ini
[local.repo]
name=local
baseurl=http://localhost:8080
enabled=1
gpgcheck=0
```

And your hosts can install RPMs via `rpm-ostree install <>` in air-gapped environment:
```sh


rpm-ostree override remove nfs-utils-coreos --install nfs-utils httpd-tools skopeo
```

Alright, no idea how it's supposed to work, exposing 80 port doesn't seem to work, not that i know how to check if it's working or not, but `rpm-ostree install skopeo` doesn't find the package so fail for now

Can try building a custom coreos image, but that's quite a lot of work, so maybe sometime later