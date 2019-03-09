# Simple file with issues and suggestions

## 001: Ansible and Vagrant - inventory

There are plugins for inventories working with VBox and Vagrant, however they are really
slow. Every time when script is running is requesting Vagrant - which is slow.
Is easier to generate inventory file based on initial request and then just use flat file.

This script can be used during build / initial stage - not all the time.

Please see details in `scripts/ansible-vagrant-update-hosts.sh`

