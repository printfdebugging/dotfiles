#!/bin/bash

# install basic system packages
sudo pacman --noconfirm -Sy ansible python-watchdog neovim openssh git


mkdir -p ~/repos && cd ~/repos
git clone https://gitlab.com/printfdebugging/dotfiles.git && cd dotfiles

# ansible-playbook
ansible-playbook main.yml \
    --tags "files,packages,custom,system" \
    --become --ask-become-pass \
    --ask-vault-pass

