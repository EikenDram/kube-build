#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" ( index .Version "port-forward") "Images" (index .Images "port-forward") "Value" (index .Values "port-forward"))}}