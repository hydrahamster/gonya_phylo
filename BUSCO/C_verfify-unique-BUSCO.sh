#!/bin/bash

OUTPUT_FILE=5_BUSCO_unique-single-count.txt

# Remove our old file
rm $OUTPUT_FILE
# 'Touch' the file to ensure it's blank
touch $OUTPUT_FILE

#set ID from file .txt, line by line
ID=$()

while read p; do
	value=$(find . | grep hmm$ | grep euk$p.hmm | wc -l)
	if [ "$value" -eq "1" ]; then
	# Output just the BUSCO ID on a fresh line to our file
        echo "$p" >> $OUTPUT_FILE
	fi
done <4_BUSCO_complete-count.txt

# Get the number of files that contain the BUSCO ID 
#value=$(ls -d */hmm_eukaryota/hmms/BUSCOeuk$ID.hmm* | wc -l)
# If that number is unique...
# if [ "$value" -eq "1" ]; then
	# Output just the BUSCO ID on a fresh line to our file
#        echo "$ID" >> $OUTPUT_FILE
#fi
#done

