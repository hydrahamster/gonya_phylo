#!/usr/bin/env python

import os,sys,pandas, glob

#sourcef = open('BUSCOs-complete-frag.csv', 'r') #single ' or double " ?
#for file in sourcef:
#	for line in file:
#		colA = line.split("\t")[0] #just use first column to process
#		with open('$colA.csv', 'w') as prod: #do I need the $ here?
			#from pandas import DataFrame
from glob import glob
for file in glob('*_query.tsv'):
	sources = file
	colnames = ['a', 'b', 'c', 'd', 'e', 'f']
	df = pandas.read_csv(sources, sep='\t', names=colnames)
	colA = df.a.tolist()
	print colA

			






			#colAnz = colA[5:] #remove letters at start of BUSCO ID
			#colAn = colAnz.rstrip("0") #remove leading zeroes
			#colF = line.split("\t")[5] #check unique rep per transcriptome later # not working
			#iterations = range(50000000133, 740000041382) #memory error
			#for i in iterations: #cycle through all iterations
			#	hit = colAn.find(i)
			#	if hit ==2: #how to specify that it needs to be found 2ce?
			#		prod.write(line) #write whole line into prod file

# how about making all the first columns of transcriptomes into sets then checking for commonly represented entities
#$transcr1IDhits = set([colA of that transcriptome])
#$transcr2IDhits = set([colA of that transcriptome])
#print($transcr1IDhits & $transcr2IDhits) # prints only common IDs
#commonIDs = $transcr1IDhits & $transcr2IDhits #new variable only with the common elements


