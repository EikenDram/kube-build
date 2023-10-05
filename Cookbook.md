# Linux

## System monitor
```sh
top
```

## Disk space
```sh
df -h
```

## Free memory
```sh
free -m
```

## Editing hosts file
```sh
sudo nano /etc/hosts
```

## Archive a directory
```sh
tar cfz name_of_archive_file.tar.gz name_of_directory_to_tar
```

## Extract archive
```sh
tar xf archive.tgz
```

## Adding aliases

To add aliases permanently to bash run `sudo nano ~/.bashrc` and add aliases at the end there (there's an option to use `.bashrc.d` folder, but couldn't do it for some reason, maybe access was wrong?)

## Sync date and time with another server

CoreOS uses `chrony` service

```sh
sudo nano /etc/chrony.conf
```

Add `server <SERVER_IP> iburst` line after/instead of official pool

Restart service with
```sh
sudo systemctl restart chronyd
```

Check sources with 
```sh
chronyc sources
```

Check that `timedatectl` has synced

### Enabling ntp server on a linux with chrony

```sh
sudo nano /etc/chrony.conf
```

Uncomment lines for running a server
```sh
# Allow NTP client access from local network.
allow 192.168.0.0/16

# Serve time even if not synchronized to a time source.
local stratum 10
```

### List hard drives
```sh
fdisk -l
```

### Mount drive partition as directory
```sh
mount -t ext4 /dev/sdb /home/core/data
```

### Edit selinux config
```sh
sudo nano /etc/selinux/config
```

## Sharing a directory via samba

Install samba
```sh
sudo rpm-ostree install samba
sudo systemctl enable smb --now
sudo systemctl reboot
```

Create `guestshare` user
```sh
sudo adduser guestshare
sudo smbpasswd -a guestshare
sudo smbpasswd -e guestshare
```

Share home directory for `guestshare` user
```sh
sudo setsebool -P samba_enable_home_dirs on
```

Could also add a shared folder:
```sh
sudo mkdir /home/core/share
sudo nano /etc/samba/smb.conf
```

Write to configuration:
```ini
[public]
comment = Share
path = /home/core/share
public = yes
writable = yes
printable = no
```

But this doesn't work for some reason, `No access` from windows 10

# Kubernetes

## Restarting k3s:
```sh
systemctl restart k3s
```

## List of nodes:
```sh
kubectl get nodes
```

## List of running pods:
```sh
kubectl get pods --all-namespaces
```

## Open console to pod:
```sh
kubectl exec -ti <pod_name> -n <namespace> -- /bin/sh
```

## Copy file to pod
```sh
kubectl cp filename.ext podname:/folder
```

## Journal K3S logs:
```sh
journalctl -u k3s -e
journalctl -u k3s > k3s.logs.txt
```

## Reading content of a kubectl secret
```sh
kubectl get secret loki-coreos-logs-config -n logging -o jsonpath="{.data['agent\.yml']}" | base64 -d
```

## Configure the selinux label
If you use selinux you can add the z or Z options to modify the selinux label of the host file or directory being mounted into the container. This affects the file or directory on the host machine itself and can have consequences outside of the scope of Docker.

- The z option indicates that the bind mount content is shared among multiple containers.
- The Z option indicates that the bind mount content is private and unshared.

# Helm

## Add repo
```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## Pull chart into tgz file
```sh
helm pull grafana/loki
```

## Pull chart into folder
```sh
helm template grafana/loki --namespace=logging --include-crds --skip-tests --output-dir loki

# pack and move to share
tar czf loki.tar.gz loki
sudo mv *.gz /home/guestshare/share/
```

# WSL

## Share windows SSH key in WSL

```sh
cp -r /mnt/c/Users/<WindowsUser>/.ssh/* ~/.ssh/
chmod 600 ~/.ssh/id_rsa
```

## Restart to update hosts

```sh
Restart-Service LxssManager*
```

# IBM DB2

## Federated database

Let's say we want to add database `APD` on remote server `192.168.120.6` port `50000` user `db2admin` password `db2admin`, add nickname `TEST.N_USERS` for `DB2ACCOUNT.USERS` and create MQT `TEST.MQT_USERS` for pulling data from the remote server on demand with `REFRESH TABLE`

Open shell into ibmdb2 pod:
```sh
kubectl exec -ti db2-ibmdb2-server-0 -n ibmdb2 -c ibmdb2 -- /bin/sh

# Switch to db2inst1 user
su db2inst1

# First, we need to add remote node to local catalog:
db2 catalog tcpip node NODE6 remote 192.168.120.6 server 50000

# Then, add database from this remote node to catalog:
db2 catalog database APD as APD at node NODE6 authentication server

# Check that we can connect to database:
db2 connect to APD user db2admin using db2admin
db2 connect reset
```

Now, we can connect to federated database and add necessary objects:
```sql
CREATE WRAPPER "WrapperDB2" LIBRARY 'libdb2drda.so' OPTIONS ( ADD DB2_FENCED 'N' );

CREATE SERVER NVP TYPE DB2/UDB VERSION '9.7' WRAPPER "WrapperDB2" AUTHORIZATION "db2admin" PASSWORD "db2admin" OPTIONS ( ADD DBNAME 'APD' );

CREATE USER MAPPING FOR "db2inst1" SERVER NVP OPTIONS ( ADD REMOTE_AUTHID 'db2admin', ADD REMOTE_PASSWORD 'db2admin' );

CREATE NICKNAME TEST.N_USERS FOR NVP.DB2ACCOUNT.USERS;

CREATE TABLE TEST.MQT_USERS ( ID_USER, LOGIN, PASS, IS_ACTIVE, IS_EXPIRED, NAME, DESC, PASS_DATE ) AS ( SELECT * FROM TEST.N_USERS ) DATA INITIALLY DEFERRED REFRESH DEFERRED MAINTAINED BY SYSTEM;
SET INTEGRITY FOR TEST.MQT_USERS IMMEDIATE CHECKED FULL ACCESS;

REFRESH TABLE TEST.MQT_USERS;
```