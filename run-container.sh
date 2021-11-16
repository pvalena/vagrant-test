#!/bin/bash
set -xe
bash -n "$0"
f="container_test.log"
podman rmi -f fedora/vagrant
podman build -f Dockerfile . -t fedora/vagrant
podman run --rm -it -v /run/libvirt:/run/libvirt fedora/vagrant 2>&1 | tee "$f"
nn "$f"
cat -v "$f" | grep -v '\^M^' | fpaste
