#!/bin/sh
echo "Publishing release: $1"

# build image
echo "Building image..."
docker build -t ghcr.io/eikendram/tools:$1 -f Dockerfile.tools .

# push image
echo "Pushing image..."
docker push ghcr.io/eikendram/tools:$1