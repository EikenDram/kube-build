#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.oauth2 "Images" .Images.oauth2 "Value" .Values.oauth2)}}

{{- define "install-pre"}}
    # need to prepare keycloak first
    echo "Keycloak has to have a ream named 'cluster' and a client named 'oauth2-proxy'"
    # then ask for client token
    cookie=$(openssl rand -base64 32 | head -c 32 | base64)
    read -p "Enter oauth2-proxy client secret from keycloak: " secret

    sed -i "s/__cookie__/$cookie/gi" install/{{.Version.dir}}/values.yaml
    sed -i "s/__secret__/$secret/gi" install/{{.Version.dir}}/values.yaml
{{- end}}

{{- define "upgrade"}}
    #
{{- end}}

{{- define "uninstall"}}
    #
{{- end}}