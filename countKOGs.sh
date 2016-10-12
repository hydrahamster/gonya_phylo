#!/bin/bash

OUTPUT_FILE=KOG_results.txt

# Remove our old file
rm $OUTPUT_FILE
# 'Touch' the file to ensure it's blank
touch $OUTPUT_FILE

# Iterate between 1 and 5000
for ((i=1;i<=5000;i++));
do

# Create a padded version of our integer with up to three leading zeros
printf -v padded_i "%04g\n" $i

# Get the number of lines that contain the KOG
value=$(grep -c $padded_i all-KOG.fasta)
# If that number is 17...
if [ "$value" -eq "17" ]; then
	# Output just the KOG on a fresh line to our file
        printf "$padded_i" >> $OUTPUT_FILE
fi
done
