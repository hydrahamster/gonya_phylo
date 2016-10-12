#!/bin/bash

OUTPUT_FILE=4_BUSCO_complete-count.txt

# Remove our old file
rm $OUTPUT_FILE
# 'Touch' the file to ensure it's blank
touch $OUTPUT_FILE

# Iterate between 1 and 120109
for ((i=1;i<=120109;i++));
do

#printf -v $i

# Get the number of lines that contain the BUSCO ID
value=$(grep -c $i 3_complete_BUSCOs-17-colA.txt)
# If that number is 17...
 if [ "$value" -eq "17" ]; then
	# Output just the KOG on a fresh line to our file
        echo "$i" >> $OUTPUT_FILE
fi
done
