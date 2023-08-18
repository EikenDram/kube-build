```sh
# build image
docker build -t ghcr.io/eikendram/tools:v1.0 -f Dockerfile.tools .

# push to ghcr.io
docker login ghcr.io -u eikendram
### enter token
docker push ghcr.io/eikendram/tools:v1.0
```