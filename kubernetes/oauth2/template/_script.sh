#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.oauth2 "Images" .Images.oauth2 "Value" .Values.oauth2)}}

{{- define "init"}}
    # need to prepare keycloak first
    echo "Keycloak has to have a ream named 'cluster' and a client named 'oauth2-proxy'"
    # then ask for client token
    cookie=$(openssl rand -base64 32 | head -c 32 | base64)
    read -p "Enter oauth2-proxy client secret from keycloak: " secret

    sed -i "s/__cookie__/$cookie/gi" install/{{.Version.dir}}/values.yaml
    sed -i "s/__secret__/$secret/gi" install/{{.Version.dir}}/values.yaml

    # change traefik configuration
    echo "Copying traefik-config.yaml to /var/lib/rancher/k3s/server/manifests/"
    cp install/{{.Version.dir}}/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/

    # patch coredns
    echo "Patching coredns configuration..."
    kubectl patch configmap coredns -n kube-system --patch-file install/{{.Version.dir}}/coredns-patch.yaml

    # restart coredns
    echo "Restarting coredns"
    kubectl delete pod -l k8s-app=kube-dns -n kube-system
    sleep 2
    kubectl wait --for=condition=ready pod -l k8s-app=kube-dns -n kube-system
    
{{- end}}

{{- define "install-post"}}
    # add ingress
    echo "Adding ingress..."
    kubectl apply -f install/{{.Version.dir}}/ingress.yaml

    
{{- end}}

{{- define "upgrade"}}
    # ingress
    kubectl apply -f install/{{.Version.dir}}/ingress.yaml
{{- end}}

{{- define "uninstall-post"}}
    #
    kubectl delete ns {{.Value.helm.namespace}}
{{- end}}