#!/bin/bash

# copy the mirror file
cp /usr/share/xbps.d/00-repository-main.conf /etc/xbps.d000-repository-main.conf
sudo xbps-install -Su

# install the required packages
sudo xbps-install git openssl ansible python3-watchdog

# setup dotfiles
mkdir -p ~/repos && cd ~/repos
[ ! -d "~/repos/dotfiles" ] && git clone https://gitlab.com/printfdebugging/dotfiles.git 
cd dotfiles

# ansible-playbook
ansible-playbook ~/repos/dotfiles/main.yml \
    --tags "files,packages,custom,system" \
    --become --ask-become-pass \
    --ask-vault-pass
