#!/bin/bash
# Save boot ID and compress previous journal
cat /run/machine-id >> /mnt/journal/id.txt
readarray -t ids < /mnt/journal/id.txt
num_ids=${#ids[@]}
if [ $num_ids -gt 1 ]; then
    prev_id=${ids[num_ids-2]}
    if [ -d "/mnt/journal/$prev_id" ]; then
        if [ ! -f "/mnt/journal/$prev_id.tar.gz" ]; then
            tar -czf /mnt/journal/$prev_id.tar.gz -C /mnt/journal/$prev_id .
        fi
        rm -rf /mnt/journal/$prev_id
    fi
fi
