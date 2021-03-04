#!/bin/bash
# Extract and read an older journal
readarray -t ids < /mnt/journal/id.txt
num_ids=${#ids[@]}
if [[ ! -z $1 && $1 -gt 0 ]]; then
    num_want=$((num_ids-$1-1))
    if [ $num_want -ge 0 ]; then
        id_want=${ids[$num_want]}
        if [ ! -d "/tmp/$id_want" ]; then
            mkdir /tmp/$id_want
        fi
        if [ ! -f "/tmp/$id_want/system.journal" ]; then
            if [ -f "/mnt/journal/$id_want.tar.gz" ]; then
                tar -xzf /mnt/journal/$id_want.tar.gz -C /tmp/$id_want
                if [ -f "/tmp/$id_want/system.journal" ]; then
                    journalctl --file /tmp/$id_want/system.journal
                fi
            else
                echo "Archive not found for journal $id_want"
            fi
        else
            journalctl --file /tmp/$id_want/system.journal
        fi
    else
        echo "Only have $num_ids journals available"
    fi
fi
