#!/bin/sh

# check root access
if [ 0 != $(id -u) ]; then echo "This section must be run as root"; exit 1; fi

# disable countme
# systemctl mask --now rpm-ostree-countme.timer

# change ntp server in airgapped environment
echo "Changing ntp server in air-gapped environment"
sed -i '2s/.*/server {{.Values.server.ntp}} iburst/' /etc/chrony.conf
systemctl restart chronyd

# add own hostname to /etc/hosts
echo "Adding hostname to /etc/hosts"
echo '{{.Values.server.ip}} {{.Values.server.hostname}}' >> /etc/hosts

echo "Done"