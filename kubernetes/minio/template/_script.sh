#!/bin/bash

# check root access
if [ 0 != $(id -u) ]; then echo "This script must be run as root"; exit 1; fi

# Install minio binary
echo "Installing minio binary into /usr/local/bin"
mv bin/{{.Version.minio.dir}}/minio /usr/local/bin/
chmod +x /usr/local/bin/minio

# add minio user and minio group
echo "Creating minio user"
groupadd -r {{.Values.minio.group}}
pw=$(openssl passwd -1 {{.Values.minio.password}})
useradd -M -r -g {{.Values.minio.group}} -p "$pw" {{.Values.minio.user}}

# this is minio storage, needs to be on another partition than root?
echo "Creating minio storage volume"
mkdir -p {{.Values.minio.volume}}
chown {{.Values.minio.user}}:{{.Values.minio.group}} {{.Values.minio.volume}}

# install minio service
echo "Installing minio service"
mv install/{{.Version.minio.dir}}/minio.service /etc/systemd/system/
mv install/{{.Version.minio.dir}}/minio /etc/default/

# need to restore selinux executable access
echo "Fixing selinux"
restorecon -rv /usr/local/bin/minio
restorecon /etc/systemd/system/minio.service
chown {{.Values.minio.user}}:{{.Values.minio.group}} /etc/default/minio
restorecon /etc/default/minio

# start minio service
echo "Starting minio service"
systemctl enable minio.service
systemctl start minio.service

echo "Check minio status with command:"
echo "  sudo systemctl status minio.service"
echo "Check minio log with command:"
echo "  journalctl -e -u minio.service"
echo "Login to Minio UI http://{{.Values.server.hostname | lower}}:9001 and create new bucket with name '{{.Values.minio.bucket}}'"