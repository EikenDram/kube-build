#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.nfs "Images" .Images.nfs)}}

{{- define "install"}}
    #
    kubectl apply -f install/nfs/pvc.yaml
    kubectl apply -f install/nfs/deployment.yaml
    kubectl apply -f install/nfs/service.yaml
{{- end}}

{{- define "uninstall"}}
    # 
    kubectl delete -f install/nfs/deployment.yaml
    kubectl delete -f install/nfs/service.yaml
    kubectl delete -f install/nfs/pvc.yaml
{{- end}}