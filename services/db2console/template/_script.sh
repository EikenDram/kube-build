#!/bin/sh

# IN DOCKER - working

# check root access
# if [ 0 != $(id -u) ]; then echo "This script must be run as root"; exit 1; fi

# make directory with write access
echo "Making /home/{{.Values.server.user}}/{{.Values.db2console.dir}} directory for db2console mount"
mkdir /home/{{.Values.server.user}}/{{.Values.db2console.dir}}
#chmod 777 /home/{{.Values.server.user}}/{{.Values.db2console.dir}}

# load and run image
echo "Loading db2console image..."
podman load -i packages/{{.Version.db2console.dir}}/{{index .Version.db2console.images 0 "name"}}-{{index .Version.db2console.images 0 "version"}}.tar

echo "Running db2console in podman"
podman run -d --privileged --name {{.Values.db2console.docker}} -p 11081:8443 -e LICENSE=accept -e ADMIN_NAME={{.Values.cluster.user}} -e ADMIN_PASSWORD={{.Values.cluster.password}} -e NAMESERVER=localhost -v /home/{{.Values.server.user}}/{{.Values.db2console.dir}}:/mnt:Z {{index .Version.db2console.images 0 "path"}}/{{index .Version.db2console.images 0 "name"}}:{{index .Version.db2console.images 0 "version"}}

# auto start after reboot
echo "Set db2console to restart if rebooted"
podman update --restart unless-stopped {{.Values.db2console.docker}}

echo "DB2 data management console deployed on https://{{.Values.server.hostname}}:11081"
echo "Docker name: {{.Values.db2console.docker}}"
echo "Check logs with:"
echo "  sudo docker logs -f {{.Values.db2console.docker}}"
echo "Open console with:"
echo "  sudo docker exec -it dmc sh"
echo "Delete pod with:"
echo "  sudo docker rm -f dmc"
echo "List images with:"
echo "  sudo docker images"
echo "Remove image with:"
echo "  sudo docker image rm <IMAGE ID>"
echo "Remove content of mounted directory with:"
echo "  sudo rm -r /home/{{.Values.server.user}}/{{.Values.db2console.dir}}/*"