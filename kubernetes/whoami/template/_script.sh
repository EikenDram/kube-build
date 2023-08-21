#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.whoami "Images" .Images.whoami)}}


{{- define "install"}}
    #
    kubectl apply -f install/whoami/whoami.yaml
    kubectl apply -f install/whoami/ingress.yaml
{{- end}}

{{- define "uninstall"}}
    # 
    kubectl delete -f install/whoami/ingress.yaml
    kubectl delete -f install/whoami/whoami.yaml
{{- end}}