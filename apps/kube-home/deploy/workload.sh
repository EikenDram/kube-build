# user configuration
git config --global user.name "{{.Values.cluster.user}}"
git config --global user.email "{{.Values.cluster.email}}"
# clone cluster-config dir
git clone http://{{.Values.cluster.user}}:{{.Values.cluster.password}}@{{.Values.gitea.helm.name}}-http.{{.Values.gitea.helm.namespace}}:3000/{{.Values.cluster.user}}/cluster-config.git cluster-config
cd cluster-config
# make kube-home directory
mkdir kube-home
# copy values.yaml
cp /tmp/values.yaml ./kube-home/
# stage all and commit
git add -A && git commit -m "Init KubeHome values.yaml"
# push to gitea
git push