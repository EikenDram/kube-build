# Installing Minio

This is S3 storage server, which will be used for storing cluster backups

We'll install it from binary

Add minio user and minio group
```sh
sudo groupadd -r minio-user
sudo useradd -M -r -g minio-user minio-user
```

Create minio storage, possibly needs to be on another partition than root
```sh
sudo mkdir -p /mnt/data
sudo chown minio-user:minio-user /mnt/
sudo chown minio-user:minio-user /mnt/data
```

Need to restore selinux executable access
```sh
sudo restorecon -rv /usr/local/bin/minio
```

Start minio service
```sh
sudo systemctl enable minio.service
sudo systemctl start minio.service
```

Check status
```sh
sudo systemctl status minio.service
journalctl -e -u minio.service
```

Login to UI with minioadmin user/password and create new bucket called `k3s.local`