#!/bin/sh

ssh-keygen

echo "Enter password for admin user on CoreOS"
mkpasswd --method=yescrypt

echo "Enter password for registry"
htpasswd -B -n regadmin