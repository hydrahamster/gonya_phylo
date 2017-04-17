#!/usr/bin/env python

import os,sys,pandas, collections
from collections import defaultdict

with open('BUSCOs-unique-single.tsv', 'w') as prod:
	sourcef = open('BUSCOs-complete-frag.tsv', 'r') #single ' or double " ?
	colnames = ['a', 'b', 'c', 'd', 'e', 'f'] 
	df = pandas.read_csv(sourcef, sep='\t', names=colnames) #colnames headers for df contruction
	IDlist = df.a.tolist() #turn column a, protein IDs, into list
	IDdict = defaultdict(int) #dictionatry type makes new key with entry 0 if not present yet an entry
	for thing in IDlist: #cycle though entries in ID list
		IDdict[thing] += 1 #+1 to value of the corresponding key from list
print IDdict.keys()[IDdict.values().index(2)]	

#	IDdict = {} #make empty dictionary
#		for thing in IDlist: #for each entry in IDs list
#		if not thing in IDdict:
#			IDdict[thing] = 1 #if x in dict, add +1 to value
#		else:
#			IDdict[thing] += 1 #if x not in dict, make key w/ value of 1
#		print IDdict


#		IDname = line.split("\t")[0] #just use first column to process
#		IDs = #make colA into list


			
#		sourcef = file
#		colnames = ['a', 'b', 'c', 'd', 'e', 'f'] 
#		df = pandas.read_csv(colA, sep='\t', names=colnames) #colnames headers for df contruction
#		IDlist = df.a.tolist() #turn column a, protein IDs, into list
#		print colA
		#for line in file:


#					prod.write(line) #write whole line into prod file
