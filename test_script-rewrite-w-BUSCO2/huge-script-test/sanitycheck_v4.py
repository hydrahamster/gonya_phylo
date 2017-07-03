#!/usr/bin/env python
import os, sys, glob, pandas, re, shutil, collections, itertools
from glob import glob
from collections import defaultdict
from re import sub

for file in glob('EP*.clean.aln.fa'): # all new clean alignments
	with open(file , 'a+') as query:
		sourcet = open('ref_transcriptomes.tsv', 'r') #single ' or double " ?
		colnames = ['a'] 
		df = pandas.read_csv(sourcet, names=colnames) #colnames headers for df contruction
		IDlist = df.a.tolist() #turn column a, protein IDs, into list
		IDdict = {key: 0 for key in IDlist}
		for eachkey in IDdict.keys():
			for line in query:
				if line.find(eachkey):
					IDdict[eachkey] =+ 1
					continue
			        else:
					continue
		print IDdict
#		IDdict = defaultdict(int) #dictionatry type makes new key with entry 0 if not present yet an entry
#		for thing in IDlist: #cycle though entries in ID list
#			IDdict[thing] == 0 #+1 to value of the corresponding key from list
#		for line in query:
#			print IDlist
#			for eachkey in IDdict.keys():
#				for line in query:
#					if line.find(eachkey):
#						IDdict[eachkey] += 1
#			        	else:
#			        	    continue
#					print IDdict.values()
#			for eachkey in IDdict.keys():
#				print line.find(eachkey)
#		        	if eachkey in line:
#					IDdict[eachkey] += 1
#	        		print eachkey
#		        	else:
#		        	    continue
#				print eachkey
#			checks = IDdict.keys()
#			check = line.find(checks)
#		for entry in IDdict: #cycle through each key
#			if IDdict.get(entry) >= 2: #if value for each key is the same as target
#		print checks
