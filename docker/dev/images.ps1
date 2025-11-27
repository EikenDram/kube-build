# Images:
# - alpine/git - for git operations in Tekton tasks
# - kube/go-alpine - custom Go environment based on Alpine Linux
# - kube/dotnet - custom .NET environment
# - kube/node-pnpm - custom Node.js environment with pnpm
# - kube/go-alpine-runtime - runtime environment for Go applications based on Alpine Linux
# - buildah/stable - for building OCI and Docker images in Tekton tasks

# Build Docker images
$PNPM_IMAGE_TAG = "v10.12.1"
$DOTNET_IMAGE_TAG = "9.0-noble"
$GO_IMAGE_TAG = "1.24.3-alpine"

#docker pull alpine/git:latest
#docker build -f Dockerfile.kube-go-alpine -t kube/go-alpine:$GO_IMAGE_TAG .
docker build -f Dockerfile.kube-dotnet -t kube/dotnet:$DOTNET_IMAGE_TAG .
#docker build -f Dockerfile.kube-node-pnpm -t kube/node-pnpm:$PNPM_IMAGE_TAG .
#docker build -f Dockerfile.kube-go-alpine-runtime -t kube/go-alpine-runtime:latest .
#docker pull quay.io/buildah/stable:latest

# Save images as tar files
#docker save alpine/git:latest -o git-latest.tar
docker save kube/dotnet:$DOTNET_IMAGE_TAG -o dotnet-$DOTNET_IMAGE_TAG.tar
#docker save kube/go-alpine:$GO_IMAGE_TAG -o go-alpine-$GO_IMAGE_TAG.tar
#docker save kube/node-pnpm:$PNPM_IMAGE_TAG -o node-pnpm-$PNPM_IMAGE_TAG.tar
#docker save kube/go-alpine-runtime:latest -o go-alpine-runtime-latest.tar
#docker save quay.io/buildah/stable:latest -o stable-latest.tar