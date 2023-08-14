#
{{- template "prepare" dict "Version" (index .Version "kube-home") "Images" (index .Images "kube-home")}}
#