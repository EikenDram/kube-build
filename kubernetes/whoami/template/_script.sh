#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.whoami "Images" .Images.whoami)}}


{{- define "install"}}
    #
    kubectl apply -f install/whoami/whoami.yaml
    helm install whoami chartmuseum/oauth2-proxy -f install/whoami/values-oauth2.yaml
    kubectl apply install/whoami/ingress.yaml
{{- end}}

{{- define "uninstall"}}
    # 
    kubectl delete -f install/whoami/ingress.yaml
    helm uninstall whoami
    kubectl delete -f install/whoami/whoami.yaml
{{- end}}