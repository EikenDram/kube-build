#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.vmtools "Images" .Images.vmtools)}}