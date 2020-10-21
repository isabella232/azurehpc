#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

inventory=$1
private_key=$2
remote_user=$3
playbook=${4-$DIR/playbook.yml}

# Disable SSH host checking to avoid prompting
export ANSIBLE_HOST_KEY_CHECKING=False

if [ -n "$private_key" ]; then
    key_options="--private-key $private_key -u $remote_user"
else
    key_options=""
fi
if ! rpm -q ansible; then
    sudo yum install -y ansible
fi
ansible-playbook -v $key_options -i $inventory $playbook
