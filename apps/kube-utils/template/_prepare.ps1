#
{{- template "prepare" dict "Version" (index .Version "kube-utils") "Images" (index .Images "kube-utils")}}
#