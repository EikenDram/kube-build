#!/bin/sh
echo "Publishing release: $1"

echo "Cleaning directory..."
rm -r publish
mkdir publish

echo "Making binaries for all platforms..."
GOOS=linux GOARCH=amd64 go build build
GOOS=windows GOARCH=amd64 go build build
echo "Making archives..."

tar -czvf ./publish/build-linux-amd64-$1.tar.gz ./build
tar -czvf ./publish/build-windows-x64-$1.tar.gz ./build.exe

echo "Making project directory..."
cd publish
curl -L https://github.com/EikenDram/kube-build/archive/refs/heads/main.zip -o main.zip
unzip main.zip
rm main.zip
mv kube-build-main kube-build
rm -r kube-build/.vscode
rm -r kube-build/docker
rm -r kube-build/src
rm kube-build/*
tar cfz build-$1.tar.gz kube-build
rm -r kube-build


