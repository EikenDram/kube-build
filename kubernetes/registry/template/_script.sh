#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.registry "Images" .Images.registry "Value" .Values.registry)}}

{{- define "init"}}
    # install cfssl binaries
    echo "Installing cfssl binaries into /usr/local/bin/"
    mv bin/{{.Version.dir}}/cfssl /usr/local/bin/
    mv bin/{{.Version.dir}}/cfssljson /usr/local/bin/
    chmod +x /usr/local/bin/{cfssl,cfssljson}

    # Load tar files into containerd filesystem
    echo "Loading images into k3s ctr"
    {{- range .Images}}
    k3s ctr images import packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar
    {{- end}}
    
    # certificates
    echo "Generating certificates in cert/ directory"
    cd cert

    # Generate CA certificate
    cfssl gencert -initca ./../install/{{.Version.dir}}/registry.json | cfssljson -bare registry-ca

    # Generate server certificate
    cfssl gencert -ca=registry-ca.pem -ca-key=registry-ca-key.pem -config=./../install/{{.Version.dir}}/cfssl.json -profile=server -hostname={{.Values.server.hostname}} ./../install/{{.Version.dir}}/serverRequest.json | cfssljson -bare registry -server=https://127.0.0.1:6443

    # change owner to user
    chown {{.Values.server.user}}:{{.Values.server.user}} *

    echo "Updating trusted certificates"
    cp registry-ca.pem /etc/pki/ca-trust/source/anchors/
    update-ca-trust
    
    # Copy certificates to rancher directory
    echo "Installing certificates into /etc/rancher/k3s/certs/"
    mkdir /etc/rancher/k3s/certs
    cp registry.pem /etc/rancher/k3s/certs/
    cp registry-key.pem /etc/rancher/k3s/certs/
    cp registry-ca.pem /etc/rancher/k3s/certs/
    cd ..
{{- end}}

{{- define "install"}}
    # Create namespace 
    echo "Creating namespace"
    kubectl create namespace {{.Values.registry.namespace}}

    # Create htpasswd secret
    echo "Creating secrets"
    kubectl -n {{.Values.registry.namespace}} create secret generic htpasswd --from-file=htpasswd=./install/{{.Version.dir}}/htpasswd

    # Create tls secret
    kubectl -n {{.Values.registry.namespace}} create secret tls tls-registry --cert=cert/registry.pem --key=cert/registry-key.pem

    # Create deployment
    echo "Creating deployment"
    kubectl create -f install/{{.Version.dir}}/deployment.yaml

    # wait til pod is created
    {{template "wait" dict "Label" "app" "Name" "registry" "Namespace" .Values.registry.namespace}}

    # Update k3s registry settings
    echo "Copying registries.yaml into /etc/rancher/k3s/"
    cp install/{{.Version.dir}}/registries.yaml /etc/rancher/k3s/

    # Restart k3s service for changes to take effect
    echo "Restarting k3s"
    systemctl restart k3s
{{- end}}

{{- define "install-echo"}}
    echo "Registry deployed"

    # Can check that registry is available with
    echo "Checking that registry is available:"
    {{template "wait" dict "Label" "app" "Name" "registry" "Namespace" .Values.registry.namespace}}
    
    sleep 2
    curl -u {{.Values.registry.user}}:{{.Values.registry.password}} https://{{.Values.server.hostname}}:5000/v2/_catalog
    #{{- end}}

{{- define "upgrade"}}
    # 2D
{{- end}}

{{- define "uninstall"}}
    # 2D
    
    # namespace
    kubectl delete ns {{.Values.registry.namespace}}
{{- end}}