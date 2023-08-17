#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.oauth2 "Images" .Images.oauth2 )}}

{{- define "install"}}
    # none
{{- end}}

{{- define "upgrade"}}
    # none
{{- end}}

{{- define "uninstall"}}
    # none
{{- end}}