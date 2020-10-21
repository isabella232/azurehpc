#!/bin/bash
private_key=$1
remote_user=$2
ssh_bastion=$3

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p $DIR/group_vars

cat <<EOF > $DIR/group_vars/all.yml
---

azhpc_dir: $azhpc_dir
EOF

# If a bastion is provided then configure Ansible to use it
if [ "$ssh_bastion" != "" ]; then
cat <<EOF >> $DIR/group_vars/all.yml
ansible_ssh_common_args: '-o ProxyCommand="ssh -q -i $private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p $remote_user@$ssh_bastion"'
EOF
fi


# Add the roles path
# TODO : 
# Test with the free strategy 
# strategy = free
# Increase the number of forks
# forks = 30
cat <<EOF > $DIR/../ansible.cfg
[defaults]
roles_path = $azhpc_dir/ansible/roles
forks = 128
strategy = free
EOF
