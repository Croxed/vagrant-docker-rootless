#!/usr/bin/env bash

prettyPrint() {
    echo "--- $1 ---"
}

prettyPrint 'Upgrading and updating'
sudo apt update -qq -y
sudo apt upgrade -qq -y

prettyPrint 'Installing dependencies'
sudo apt install -y bash bash-completion overlayroot lxc

prettyPrint 'Setting environment variables (if not present)'
[ ! -f /etc/profile.d/docker-rootless-env.sh ] && {
    sudo mkdir -p /etc/profile.d
    #  shellcheck disable=SC2016
    printf '#!/bin/sh\n\n%s\n%s\n%s\n%s\n' 'export PATH="$HOME"/bin:$PATH' 'export PATH=$PATH:/sbin' 'export DOCKER_HOST=unix:///run/user/1000/docker.sock' '#export DOCKERD_ROOTLESS_ROOTLESSKIT_NET=lxc-user-nic' | sudo tee /etc/profile.d/docker-rootless-env.sh > /dev/null
}

prettyPrint 'Setting some config for ports/ping'
[ ! -f /etc/sysctl.d/docker-rootless-env.sh ] && {
    sudo mkdir -p /etc/sysctl.d

    printf '%s\n%s\n' 'net.ipv4.ping_group_range = 0 2147483647' 'net.ipv4.ip_unprivileged_port_start = 0' | sudo tee /etc/sysctl.d/docker-rootless-env.conf > /dev/null
    sudo sysctl --system
}

prettyPrint 'Adding lxc usernet conf for docker'
#  shellcheck disable=SC2016
if ! grep 'vagrant veth lxcbr0 1' < /etc/lxc/lxc-usernet; then
    printf '\nvagrant veth lxcbr0 1\n' | tee -a /etc/lxc/lxc-usernet > /dev/null
fi

prettyPrint 'Adding vagrant to group docker'
sudo groupadd docker
sudo usermod -a -G docker vagrant
