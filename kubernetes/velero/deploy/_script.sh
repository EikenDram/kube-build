#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.velero "Images" .Images.velero "Value" .Values.velero)}}

{{- define "install-echo"}}
    echo "Velero deployed on cluster and configured to use minio backup storage"
    echo "Can use velero cli to backup data in namespace:"
    echo "velero backup create <namespace-backup> --include-namespaces <namespace>"
    #{{- end}}

{{- define "uninstall-post" }}
    # delete namespace
    kubectl delete ns {{.Value.helm.namespace}}
{{- end}}