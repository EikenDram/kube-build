#
{{- template "prepare" dict "Version" (index .Version "kube-r") "Images" (index .Images "kube-r")}}
#