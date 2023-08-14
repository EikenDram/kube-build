#
{{- template "prepare" dict "Version" (index .Version "kube-app-template") "Images" (index .Images "kube-app-template") }}
#