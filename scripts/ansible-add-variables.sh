#!/bin/bash
# variables and values need to be passed as key=values

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for var in "$@"
do
    var_name=$(echo $var | cut -d '=' -f1)
    var_value=$(echo $var | cut -d '=' -f2)
    cat <<EOF >> $DIR/group_vars/all.yml
$var_name: $var_value
EOF
done
