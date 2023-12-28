#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" ( index .Version "port-forward") "Images" (index .Images "port-forward") "Value" (index .Values "port-forward"))}}

{{- define "install"}}
    #
    kubectl apply -f install/port-forward/deployment.yaml

    echo "Use command to start port-forwarding: kubectl port-forward deployment/port-forward 50000:80"
    echo "List of running kubectl processes: ps -u | grep kubectl"
    echo "Terminate process: kill <ID>"
{{- end}}

{{- define "uninstall"}}
    # 
    kubectl delete -f install/port-forward/deployment.yaml
{{- end}}