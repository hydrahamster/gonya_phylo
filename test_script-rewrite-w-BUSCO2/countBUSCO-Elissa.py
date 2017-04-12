#!/usr/bin/env python

import os,sys

sourcef = open('BUSCOs-complete-frag.tsv', 'r') #single ' or double " ?

with open('BUSCOs-unique-single.tsv', 'w') as prod:
	#for file in sourcef:
	prodID = file.split("\t")[0] #use BUSCO ID as file name
		with open(file, 'r') as f:
			instances={}
			for line in f:
				colA = line.split("\t")[0] #just use first column to process
				colAn = colA[5:] #remove letters at start of BUSCO ID
				colF = line.split("\t")[5] #check unique rep per transcriptome later
				if instances.has_key(colA):
					instances[colA].append(line)
				else:
					instances[colA] = [line]
			for instance, lines in instance.items():
				if len(lines) == 2:
					print "2x %s" % instance
				#iterations = range(740000041381) #will this fuck up with two x 0 before start 
				#for i in iterations: #cycle through all iterations
				#	number = "%012d" % i
				#	if number in colAn:
				#		if instances.has_key(number):
				#			instances[number] = [line]
				#		else:
				#			instances[number].append(line)
				#for instance, lines in instances.items():
				#	if len(lines) == 2:
				#		if lines[5] = colF

# Iterate between 1 and 740000041381
#for ((i=1;i<=740000041381;i++));
#do

#printf -v $i

# Get the number of lines that contain the BUSCO ID
#value=$(grep -c $i 333_complete_BUSCOs-14-colA.txt)
# If that number is 1...
# if [ "$value" -eq "14" ]; then
	# Output just the KOG on a fresh line to our file
#        echo "$i" >> $OUTPUT_FILE
#fi
#done
