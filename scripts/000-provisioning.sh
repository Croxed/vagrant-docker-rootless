#!/usr/bin/env bash

[[ $COLOR_OFF ]]    || COLOR_OFF="\e[0m"
readonly COLOR_OFF

# shellcheck disable=SC2059
print_info() {
    printf "$COLOR_BLUE"
    printf '%s %s %s\n' '---' "$@" '---'
    printf "$COLOR_OFF"
}

print_info 'Installing docker rootless'
curl -fsSL https://get.docker.com/rootless | sh > /dev/null
print_info 'Done installing docker rootless'

print_info 'Enabling docker on login'
systemctl --user start docker
sudo loginctl enable-linger "$(whoami)"
print_info 'Docker is now enabled on boot'

print_info 'Setting some config for ports/ping'
sudo setcap cap_net_bind_service=ep "$HOME"/bin/rootlesskit
print_info 'Docker can now bind to restricted ports'
