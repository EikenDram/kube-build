#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.db2console "Images" .Images.db2console)}}

{{- define "init"}}
    # make directory with write access
    echo "Making /home/{{.Values.server.user}}/{{.Values.db2console.dir}} directory for db2console mount"
    mkdir /home/{{.Values.server.user}}/{{.Values.db2console.dir}}
    chown {{.Values.server.user}}:{{.Values.server.user}} /home/{{.Values.server.user}}/{{.Values.db2console.dir}}
    chmod 777 /home/{{.Values.server.user}}/{{.Values.db2console.dir}}
{{- end}}

{{- define "install"}}
    # load and run image
    echo "Loading db2console image..."
    podman load -i packages/{{.Version.dir}}/{{index .Images 0 "name"}}-{{index .Images 0 "version"}}.tar

    echo "Running db2console in podman"
    podman run -d --privileged --name {{.Values.db2console.docker}} -p 11081:8443 -e LICENSE=accept -e ADMIN_NAME={{.Values.cluster.user}} -e ADMIN_PASSWORD={{.Values.cluster.password}} -e NAMESERVER=localhost -v /home/{{.Values.server.user}}/{{.Values.db2console.dir}}:/mnt:Z {{index .Images 0 "path"}}/{{index .Images 0 "name"}}:{{index .Images 0 "version"}}

    # auto start after reboot
    echo "Set db2console to restart if rebooted"
    podman update --restart unless-stopped {{.Values.db2console.docker}}
{{- end}}

{{- define "install-echo"}}
    echo "DB2 data management console deployed on https://{{.Values.server.hostname}}:11081"
    echo "Docker name: {{.Values.db2console.docker}}"
    echo "Check logs with:"
    echo "  podman logs -f {{.Values.db2console.docker}}"
    echo "Open console with:"
    echo "  podman exec -it dmc sh"
    #{{- end}}

{{- define "upgrade"}}
    # 2D
{{- end}}

{{- define "uninstall"}}
    podman rm -f dmc

    echo "List images with:"
    echo "  podman images"
    echo "Remove image with:"
    echo "  podman image rm <IMAGE ID>"
    echo "Remove content of mounted directory with:"
    echo "  sudo rm -r /home/{{.Values.server.user}}/{{.Values.db2console.dir}}/*"
{{- end}}




