# IBM DB2 server

There's a cloud-native version of DB2 Community edition called `db2u`, which is the one that's installed with the official helm chart, but there's some IBM Cloud prerequisites, and limitation are too restrictive i think

## Fix

If there's some access error

Run as root inside pod:
```sh
chmod a+w /database/config
```

And restart pod (kill in k9s for example)

## DB2 CLI

Run `db2` commands on container with 
```sh
k exec -ti ibmdb2-0 -n ibmdb2 -- su db2inst1
```