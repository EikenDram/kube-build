#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.k3s "Images" .Images.k3s "Value" .Values.k3s)}}

{{- define "init"}}
    ## K3S binaries
    echo "Installing K3S binaries"
    mkdir -p /var/lib/rancher/k3s/agent/images/
    mv bin/{{.Version.dir}}/k3s-airgap-images-amd64.tar /var/lib/rancher/k3s/agent/images/
    mv bin/{{.Version.dir}}/k3s /usr/local/bin/
    mv bin/{{.Version.dir}}/install.sh ./

    echo "Fixing access"
    chmod a+rx install.sh
    chmod a+rx /usr/local/bin/k3s
    chmod a+rx /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar

    ## K9S binary
    echo "Installing K9S binary to /usr/local/bin/"
    mv bin/{{.Version.dir}}/k9s /usr/local/bin/
    chmod a+rx /usr/local/bin/k9s

    ## Helm binary
    echo "Installing helm binary to /usr/local/bin/"
    mv bin/{{.Version.dir}}/helm /usr/local/bin/
    chmod +x /usr/local/bin/helm

    ## Helm cm-push plugin
    #echo "Installing cm-push helm plugin"
    #mkdir bin/{{.Version.dir}}/cm-push
    #tar -xvf bin/{{.Version.dir}}/cm-push.tar.gz -C bin/{{.Version.dir}}/cm-push
    # will next line work without kubernetes configuration?
    #helm plugin install bin/{{.Version.dir}}/cm-push

    {{- if .Values.server.dummy.enabled }}
    # Adding dummy connection 
    echo "Adding dummy connection with nmcli"
    nmcli connection add save yes type dummy ifname dummy0 ipv4.method manual ipv4.addresses {{.Values.server.dummy.mask}} ipv4.gateway {{.Values.server.dummy.gateway}} ipv4.dns {{.Values.server.dummy.dns}}
    {{- end }}
{{- end }}

{{- define "install"}}
    # Installing K3S
    INSTALL_K3S_SKIP_DOWNLOAD=true INSTALL_K3S_EXEC="--write-kubeconfig-mode 644"  INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_SELINUX_WARN=true ./install.sh
{{- end}}


