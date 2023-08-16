# IBM DB2 server

There's a cloud-native version of DB2 Community edition called `db2u`, which is the one that's installed with the official helm chart, but there's some IBM Cloud prerequisites, and limitation are too strict

Ended up writing helm chart for installing db2 community edition docker image in kubernetes

## Install

Install from helm chart

## Access error

Run as root inside pod to fix access error on startup:
```sh
chmod a+w /database/config
```

And restart pod (kill in k9s)

## DB2 CLI

Run `db2` commands on container with 
```sh
k exec -ti ibmdb2-0 -n ibmdb2 -- su db2inst1
```