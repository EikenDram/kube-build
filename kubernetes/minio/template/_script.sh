#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.minio)}}

{{- define "init"}}
    # Install minio binary
    echo "Installing minio binary into /usr/local/bin"
    cp bin/{{.Version.dir}}/minio /usr/local/bin/
    chmod +x /usr/local/bin/minio

    # add minio user and minio group
    echo "Creating minio user"
    groupadd -r {{.Values.minio.group}}
    useradd -M -r -g {{.Values.minio.group}} -p "$(openssl passwd -1 {{.Values.minio.password}})" {{.Values.minio.user}}

    # this is minio storage, needs to be on another partition than root?
    echo "Creating minio storage volume"
    mkdir -p {{.Values.minio.volume}}
    chown {{.Values.minio.user}}:{{.Values.minio.group}} {{.Values.minio.volume}}
{{- end}}

{{- define "install"}}
    # check root access
    if [ 0 != $(id -u) ]; then echo "This script must be run as root"; exit 1; fi    

    # install minio service
    echo "Installing minio service"
    cp install/{{.Version.dir}}/minio.service /etc/systemd/system/
    cp install/{{.Version.dir}}/minio /etc/default/

    # need to restore selinux executable access
    echo "Fixing selinux"
    restorecon -rv /usr/local/bin/minio
    restorecon -rv /etc/systemd/system/minio.service
    chown {{.Values.minio.user}}:{{.Values.minio.group}} /etc/default/minio
    restorecon -rv /etc/default/minio

    # start minio service
    echo "Starting minio service"
    systemctl enable minio.service
    systemctl start minio.service
{{- end}}

{{- define "install-echo"}}
    echo "Check minio status with command:"
    echo "  sudo systemctl status minio.service"
    echo "Check minio log with command:"
    echo "  journalctl -e -u minio.service"
    echo "Login to Minio UI http://{{.Values.server.hostname | lower}}:9001 and create a new bucket with the name '{{.Values.minio.bucket}}'"
    #{{- end}}

{{- define "upgrade"}}
    # 2D
{{- end}}

{{- define "uninstall"}}
    # check root access
    if [ 0 != $(id -u) ]; then echo "This script must be run as root"; exit 1; fi

    # remove service
    systemctl stop minio.service
    systemctl disable minio.service
    rm /etc/systemd/system/minio.service
    rm /etc/default/minio

    echo "MinIO uninstalled"
{{- end}}