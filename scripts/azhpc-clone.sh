#!/bin/bash
branch=$1
cd
git clone https://github.com/Azure/azurehpc.git

if [ "$branch" != "" ]; then
    cd azurehpc
    git checkout $branch
fi

cat <<EOF >>~/.bashrc 
export azhpc_dir=~/azurehpc
EOF

