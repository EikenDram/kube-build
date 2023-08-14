# NodeJS

## npm package repository

We'll have our private npm registry running on gitea server on cluster accessible from inside with `http://gitea-http.gitea:3000/api/packages/gitea_admin/npm/`

To populate it we'll need docker image: `node:lts-alpine`

```sh
skopeo copy docker://docker.io/library/node:lts-alpine docker-archive:./node.tar:library/node:lts-alpine

k cp packages/node.tar loader:/tmp
k exec -i loader -- skopeo copy --dest-creds admin:coreos --dest-tls-verify=false --insecure-policy docker-archive:/tmp/node.tar docker://K3S.LOCAL:5000/library/node:lts-alpine
```

Run loader:
```sh
k run loader-npm --image=node:lts-alpine --command -- sh -c 'while true; do sleep 10; done'
```

Login into gitea web UI and generate new token in `Settings-Applications` with name `npm` and access to packages:
```
d3de3b86b20965b99e018160232c2f3473acc175
```

SSH into container, and run 
```sh
npm config set registry http://gitea.gitea-http:3000/api/packages/gitea_admin/npm/
npm config set -- '//gitea.gitea-http:3000/api/packages/gitea_admin/npm/:_authToken' "d3de3b86b20965b99e018160232c2f3473acc175"
```

Now you can publish packages to gitea server with
```sh
npm publish filename.tgz
```

In nodejs project add `.yarnrc` file with `yarn-offline-mirror "./packages-cache"`

Initialize project with command `yarn`, all packages will be downloaded to `packages-cache` directory

Move these files to cluster, copy them to `loader-npm` pod and publish every `.tgz` file to gitea server with script:
```sh
for i in *.tgz; do npm publish $i; done
```

## Dockerfile

For building stage inside cluster we'll replace link to official registry with our gitea registry:
```dockerfile
# build stage
FROM k3s.local:5000/library/node:lts-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN yarn config set registry http://gitea-http.gitea:3000/api/packages/gitea_admin/npm/
RUN yarn config set -- '//gitea-http.gitea:3000/api/packages/gitea_admin/npm/:_authToken' "a6deb579cbdf60d9fa6d01b3128b375465f05dca"
COPY . .
RUN sed -i -e "s#https://registry.npmjs.org/#http://gitea-http.gitea:3000/api/packages/gitea_admin/npm/#g" yarn.lock
RUN yarn
RUN yarn build

# production stage
FROM k3s.local:5000/library/nginx:stable-alpine as production-stage
COPY  --from=build-stage /app/dist /usr/share/nginx/html
#COPY ./.nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```