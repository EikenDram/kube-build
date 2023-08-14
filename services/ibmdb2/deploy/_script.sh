#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.ibmdb2 "Images" .Images.ibmdb2 "Value" .Values.ibmdb2)}}

{{- define "install-echo"}}
    echo "IBM DB2 deployed on port: {{.Values.ibmdb2.port}}"
    #{{- end}}