#!/bin/bash

INT_FILE1=1_BUSCO_full-table-17.txt

# Remove our old file
rm $INT_FILE1
# 'Touch' the file to ensure it's blank
touch $INT_FILE1

INT_FILE2=2_complete_BUSCOs-17.txt

# Remove our old file
rm $INT_FILE2
# 'Touch' the file to ensure it's blank
touch $INT_FILE2

OUTPUT_FILE=3_complete_BUSCOs-17-colA.txt

# Remove our old file
rm $OUTPUT_FILE
# 'Touch' the file to ensure it's blank
touch $OUTPUT_FILE

grep -v "^#" full_tables/full_table_BUSCO_* >> $INT_FILE1

grep -i "complete" $INT_FILE1 >> $INT_FILE2

awk '{print $1}' $INT_FILE2 >> $OUTPUT_FILE
