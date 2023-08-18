#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.oauth2 "Images" .Images.oauth2 "Value" .Values.oauth2)}}

{{- define "install"}}
    #
{{- end}}

{{- define "upgrade"}}
    #
{{- end}}

{{- define "uninstall"}}
    #
{{- end}}