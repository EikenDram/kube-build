#!/bin/sh

# need to create ignition file from install/os/coreos.yaml
# butane.exe should be in bin/os/
./bin/os/butane --pretty --strict ./install/os/coreos.yaml --output ./coreos.ign

echo "Ignition file generated with name 'coreos.ign' in current directory"
echo "To install Fedora CoreOS from this file it needs to be accessible from server with some URL"
echo "MIME type .ign files:"
echo "  application/vnd.coreos.ignition+json"