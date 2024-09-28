#!/bin/env bash

function init_archlinux() {
    # install basic system packages
    sudo pacman --noconfirm -Sy ansible python-watchdog neovim openssh git
}

function init_voidlinux() {
    # copy the mirror file
    cp /usr/share/xbps.d/00-repository-main.conf /etc/xbps.d/00-repository-main.conf

    # install the required packages
    sudo xbps-install -Syu git openssl ansible python3-watchdog neovim
}

function init() {
    # check for distro in /etc/os-release file
    case $(cat /etc/os-release | grep -e "^NAME" | awk -F "=" '{gsub(/"/, "", $2); print $2}') in
        "Arch Linux") init_archlinux;;
        "Void") init_voidlinux;;
        *) echo "distro not supported" && exit ;;
    esac
}

function clone_dotfiles() {
    mkdir -p /home/printfdebugging/repos && cd /home/printfdebugging/repos
    [ ! -d "/home/printfdebugging/repos/dotfiles" ] && git clone https://gitlab.com/printfdebugging/dotfiles.git /home/printfdebugging/repos/dotfiles
    cd /home/printfdebugging/repos/dotfiles
}

function run_ansible_tasks_with_tag() {
    if ! command -v ansible-playbook; then
        init
    fi

    # setup dotfiles repository
    clone_dotfiles

    # run the ansible-playbook command
    ansible-playbook main.yml \
        --tags "${@}" \
        --become --ask-become-pass \
        --ask-vault-pass
}


case "$1" in 
    "init") init;;
    "full") run_ansible_tasks_with_tag include,files,packages,system;;
    *) run_ansible_tasks_with_tag ${@};;
esac
