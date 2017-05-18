#!/usr/bin/env python
import os, sys, glob, pandas, re, shutil, collections
from glob import glob
from collections import defaultdict

def completequery():
	with open('BUSCOs-complete-frag.tsv', 'w') as out:
#now this is input:
		for file in glob('run*/full_table_*'):
#		fulltable =  glob('run_*/full_table_*')
#		for file in fulltable:
			nfile = file.split("/")[1]
			sfile = nfile.split("_")[3]
        		with open(file, 'r') as f:
        		    for line in f:
				if 'Complete' in line or 'Fragmented' in line:
					l = line.split("\t")
					buscoid = l[0]
					contigid = l[2]
					out.write(buscoid.strip())
					out.write("\t")
					out.write(contigid.strip())
					out.write("\t")
					out.write(sfile.strip())
					out.write("\n")
def countBUSCOs():
	with open('BUSCOs-unique-single.tsv', 'w') as prod:
#input:
		sourcef = open('BUSCOs-complete-frag.tsv', 'r') #single ' or double " ?
		colnames = ['a', 'b', 'c'] 
		df = pandas.read_csv(sourcef, sep='\t', names=colnames) #colnames headers for df contruction
		IDlist = df.a.tolist() #turn column a, protein IDs, into list
		IDdict = defaultdict(int) #dictionatry type makes new key with entry 0 if not present yet an entry
		for thing in IDlist: #cycle though entries in ID list
			IDdict[thing] += 1 #+1 to value of the corresponding key from list
		for entry in IDdict: #cycle through each key
			if IDdict.get(entry) == 2: #if value for each key is the same as transcriptomes queried
				prod.write(entry)
				prod.write("\n") #next entry on new line

def IDfasta(): # this one is so many ways fucked to sunday
#input uniqueids:
	uniqueids = open('BUSCOs-unique-single.tsv', 'r')
	colnames = ['a']
	df = pandas.read_csv(uniqueids, sep='\t', names=colnames) #turning column into dataframe with single column
	goodids = df.a.tolist() #dataframe to list of common BUSCO IDs
#input masterfile:
	masterfile = open('BUSCOs-complete-frag.tsv', 'r')
	mornames = ['buscoid', 'contigid', 'sourcetrans']
	masterdata = pandas.read_csv(masterfile, sep='\t', names=mornames) #dataframe of BUSCOIDs, contig IDs and organsim
	for ping in goodids: #for each entry in list of common BUSCO IDs
		mast = masterdata[masterdata.buscoid == ping ]
		with open(ping + '_info.tsv', 'w') as infom: #making info file with data for each common busco ID
			print >> infom , mast 
		with open(ping + '.fasta', 'w') as fasta:
			protlist = mast.contigid.tolist()
			for file in glob('run_*/translated_proteins/*.faa'): #PROBLEM - re-write
				fie = file.split("/")
				proteingoop = fie[2] #pull contig IDs from file name
				srcint = fie[0]
				src = srcint.split("_")[2]
				with open(file, 'r') as f:
					for line in f:
						for protbusc in protlist:
							if protbusc in proteingoop:
								lined = line.replace('>', '>' + src + '_')
								linedup = lined.upper()
								fasta.write(linedup.strip()) #needs to be written in  upper case
								fasta.write("\n")

#def AAtag():
#this is going to be function input:
#(btables = for file in glob('run_*/translated_proteins/*.faa'): #looking through all sub directories )
#	for file in glob('*.fasta'): #looking through all sub directories
#		fie = file.split("/")[0]
#		name = file.split("/")[2]
#		nup = name.upper()
#		sourcey = fie.split("_")[2] #pull contig IDs from file name
#		upsourcey = sourcey.upper()
#		with open(file, 'r') as inni:
#			with open(upsourcey + '_' + nup, 'w') as outy:
#				for line in inni:
#					if '>' in line:
#						lined = line.replace('>', '>' + upsourcey + '_')
#						linedup = lined.upper()
#						outy.write(linedup.strip())
#						outy.write("\n")
#					else:
#						outy.write(line)
#btables = glob('run_*/translated_proteins/*.faa')
#fulltable =  glob('run_*/full_table_*')
completequery()
countBUSCOs()
IDfasta()
#AAtag()
# what if I let the things run and do the AA tag of the output files only?

#btables = glob('run_*/translated_proteins/*.faa') #input for AAtag
#call AAtag

#fulltable =  glob('full_table_*') #input completequery ~ need to fix file PATH
#call completequery

#sourcef = open('BUSCOs-complete-frag.tsv', 'r') #input countBUSCOs
#call countBUSCOs

#uniqueids = open('BUSCOs-unique-single.tsv', 'r') #arg1 ID-fasta
#masterfile = open('BUSCOs-complete-frag.tsv', 'r') #arg2 ID-fasta
#call ID-fasta
