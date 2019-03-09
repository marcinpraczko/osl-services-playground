#!/usr/bin/env bash

# Original source comes from:
# https://github.com/michaelcontento/ansible-vagrant/blob/master/bin/ansible-vagrant-update-hosts

# Changes - adjusted:
#   - Read valid hostname from ssh-config
#   - Work with ansible 2.X (http://docs.ansible.com/ansible/intro_inventory.html)
#     There is info in section: 'List of Behavioral Inventory Parameters'
set -e

HOSTSFILE="./hosts_vagrant"

CONFIG=$(vagrant ssh-config)
HOSTNAME=$(echo "$CONFIG" | egrep -o "^Host .+" | cut -d " " -f2-)
HOST=$(echo "$CONFIG" | egrep -o "HostName .+" | cut -d" " -f2-)
PORT=$(echo "$CONFIG" | egrep -o "Port .+" | cut -d" " -f2-)
USER=$(echo "$CONFIG" | egrep -o "User .+" | cut -d" " -f2-)
KEY=$(echo "$CONFIG" | egrep -o "IdentityFile .+" | cut -d" " -f2-)

REPLACE_REGEX="^$HOSTNAME .*"
LINE="$HOSTNAME \
   ansible_host=$HOST \
   ansible_port=$PORT \
   ansible_user=$USER \
   ansible_ssh_private_key_file=$KEY"

touch "$HOSTSFILE"
FOUND=$(egrep "$REPLACE_REGEX" $HOSTSFILE | wc -l)

if [ $FOUND -eq 0 ]; then
    printf "[vagrant]\n$LINE" >> $HOSTSFILE
else
    sed -i".backup" -e "s#^$HOSTNAME .*#$LINE#g" $HOSTSFILE
    rm -f "$HOSTSFILE.backup"
fi