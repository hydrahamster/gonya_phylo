#!/usr/bin/env python

import os,sys,pandas

with open('BUSCOs-unique-single.tsv', 'w') as prod:
	sourcef = open('BUSCOs-complete-frag.tsv', 'r') #single ' or double " ?
	for file in sourcef:
		for line in file:
			colA = line.split("\t")[0] #just use first column to process
			colAnz = colA[5:] #remove letters at start of BUSCO ID
			colAn = colAnz.rstrip("0") #remove leading zeroes
			#colF = line.split("\t")[5] #check unique rep per transcriptome later # not working
			iterations = range(50000000133, 740000041382) #memory error
			for i in iterations: #cycle through all iterations
				hit = colAn.find(i)
				if hit ==2: #how to specify that it needs to be found 2ce?
					prod.write(line) #write whole line into prod file

# how about making all the first columns of transcriptomes into sets then checking for commonly represented entities
$transcr1IDhits = set([colA of that transcriptome])
$transcr2IDhits = set([colA of that transcriptome])
print($transcr1IDhits & $transcr2IDhits) # prints only common IDs
commonIDs = $transcr1IDhits & $transcr2IDhits #new variable only with the common elements

# Iterate between 1 and 740000041381
#for ((i=1;i<=740000041381;i++));
#do

#printf -v $i

# Get the number of lines that contain the BUSCO ID
#value=$(grep -c $i 333_complete_BUSCOs-14-colA.txt)
# If that number is 1...
 #if [ "$value" -eq "14" ]; then
	# Output just the KOG on a fresh line to our file
  #      echo "$i" >> $OUTPUT_FILE
#fi
#done
