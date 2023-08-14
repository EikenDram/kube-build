#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.rocker "Images" .Images.rocker "Value" .Values.rocker)}}