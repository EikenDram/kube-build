#!/bin/sh
Write-Output "Publishing release: 17.5.0-debian-12-r20"

# build image
Write-Output "Building image..."
docker build -t ghcr.io/eikendram/postgresql:17.5.0-debian-12-r20 -f Dockerfile.postgresql .

# push image
Write-Output "Pushing image..."
# docker push ghcr.io/eikendram/postgresql:17.5.0-debian-12-r20