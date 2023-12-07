#
{{- template "prepare" dict "Version" (index .Version "port-forward") "Images" (index .Images "port-forward") }}
#