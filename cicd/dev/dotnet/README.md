# dotnet core

## Package repository

We'll have our private npm registry running on gitea server on cluster accessible from inside with `http://gitea-http.gitea:3000/api/packages/gitea_admin/npm/`

To populate it we'll need image: mcr.microsoft.com/dotnet/sdk:7.0

```
skopeo copy docker://mcr.microsoft.com/dotnet/sdk:7.0 docker-archive:./sdk.tar:dotnet/sdk:7.0

k cp packages/sdk.tar loader:/tmp
k exec -i loader -- skopeo copy --dest-creds admin:coreos --dest-tls-verify=false --insecure-policy docker-archive:/tmp/sdk.tar docker://K3S.LOCAL:5000/dotnet/sdk:7.0
```

Run loader:
```
k run loader-nuget --image=dotnet/sdk:7.0 --command -- sh -c 'while true; do sleep 10; done'
```

## Dockerfile