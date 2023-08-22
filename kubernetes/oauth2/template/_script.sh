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
    # might not be necessary
    echo "Copying traefik-config.yaml to /var/lib/rancher/k3s/server/manifests/"
    cp install/traefik-ui/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/
{{- end}}

{{- define "install-post"}}
    # add ingress
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