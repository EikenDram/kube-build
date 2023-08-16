# IBM DB2 data management console

This is web UI for managing DB2 databases

## Preparing repo database

```sh
db2 create database repodb pagesize 8 k
db2 UPDATE DATABASE CONFIGURATION FOR repodb USING LOGPRIMARY 25 LOGSECOND 200 LOGFILSIZ 8192
db2 UPDATE DATABASE CONFIGURATION FOR repodb USING EXTENDED_ROW_SZ enable
```

Moved this into optional script in IBM DB2 deployment

## Install in kubernetes

Install db2console docker image wont work properly, the startup script will have different environment while inside kubernetes, haven't found a way to fix this yet

## Running in docker

```sh
# make directory with write access
mkdir dmc
sudo chmod 777 dmc

# load and run image
sudo docker load -i packages/db2console.tar
sudo docker run -d --privileged --name dmc -p 11081:8443 -e LICENSE=accept -e ADMIN_NAME=admin -e ADMIN_PASSWORD=coreos -e NAMESERVER=localhost -v /home/core/dmc:/mnt:Z k3s.local:5000/ibmcom/db2console

# check logs
sudo docker logs -f dmc

# auto start after reboot
sudo docker update --restart unless-stopped dmc
```

Check env inside container:
```sh
podman exec -it --user=0 db2console bash

cat /etc/passwd
su - $USER -c 'printenv'
```

Remove dmc:
```sh
podman rm -f db2console
sudo rm -r dmc/*
```

## Testing:

- [x] docker image on coreos = fail
- [x] docker image on ubuntu 20.04 = success
- [x] moving image from ubuntu to coreos = fail
- [x] installing from script to coreos = success-ish (without jobs)
- [x] installing from script to ubuntu container in coreos = fail
- [x] fixed jobs by disabling selinux in coreos on mediator
- [x] check if giving full access fixes jobs aswell = nope
- [x] fixed jobs by disabling selinux in coreos on cluster = success
- [x] maybe move folders from mediator to k3s? = FAIL
- [x] 38 version = NOPE
- [x] NAT = NOPE
- [x] ext4 = NOPE
- [x] httpd-tools golang samba = YES
- [x] no selinux and docker = YES
- [x] --privileged = FINALLY WORKS DAYO!!!