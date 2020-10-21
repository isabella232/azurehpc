#!/bin/bash
INVENTORY_FILE=${1-inventory}
# Iterate thru all files in the hostlists/tags directory and for each file add the following content to the inventory file
# [file_name]
# file_content
#

rm -f $INVENTORY_FILE
for file in hostlists/tags/*; do 
    if [ -f "$file" ]; then 
        base=$(basename $file)
        echo "[$base]" >> $INVENTORY_FILE
        cat $file >> $INVENTORY_FILE
        echo "" >> $INVENTORY_FILE
    fi 
done

