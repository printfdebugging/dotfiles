## Dotfile management with Ansible

Best place to learn ansible is from the [official docs](https://docs.ansible.com/ansible/latest/getting_started/index.html).

## Install ansible using the package manager on the control node

```sh
sudo pacman -S ansible
```

- python should be installed on the servers.

## Inventory File

- if only the IP address is given in the inventory file, then default user is
  taken as the user on the control node.

- learn yaml before touching ansible, that would be helpful. Also prefer yaml
  inventory file over ini one.

- default inventory file is in /etc/ansible/inventory, and it can be specified
  using the -i flag.

## Playbooks and plays

- A playbook has plays, and is executed from top to bottom. A play is an ordered
  list of tasks. A task is one action to be done, using one module.

## Tags

look into tags if they are usefull. I think they are, considering that they are used to
run groups of tasks, tagged similarly
