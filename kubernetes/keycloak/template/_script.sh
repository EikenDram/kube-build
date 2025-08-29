#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.keycloak "Images" .Images.keycloak "Value" .Values.keycloak)}}

{{- define "init"}}
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -config san.cnf -extensions req_ext
{{- end}}

{{- define "install-post"}}
    # create secret with cert
    kubectl create secret generic keycloak-cert \
        --from-file=tls.key=./tls.key \
        --from-file=tls.crt=./tls.crt \
        --namespace={{.Values.keycloak.helm.namespace}} \
        --dry-run=client -o yaml | kubectl apply -f -

    {{ template "wait" dict "Name" "keycloak" "Namespace" .Values.keycloak.helm.namespace}}
{{- end}}


{{- define "uninstall-post"}}
    # delete namespace - OR DONT?
    kubectl delete ns {{.Value.helm.namespace}}
{{- end}}
