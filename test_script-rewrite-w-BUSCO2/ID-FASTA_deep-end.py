#!/usr/bin/env python
import os,sys,pandas, glob, pandas, re
from glob import glob

#argv[2] is 555_BUSCO_unique-single-count.txt // make into list to cycle though
uniqueids = open('BUSCOs-unique-single.tsv', 'r')
colnames = ['a']
df = pandas.read_csv(uniqueids, sep='\t', names=colnames)
goodids = df.a.tolist()
masterfile = open('BUSCOs-complete-frag.tsv', 'r')
mornames = ['a', 'b', 'c', 'd', 'e', 'f']
df = pandas.read_csv(masterfile, sep='\t', names=mornames)
buscoid = df.a.tolist()
contigid = df.c.tolist()
sourcetrans = df.f.tolist()
buscodict = zip(contigid , buscoid)
for file in glob('run_*/translated_proteins/*.faa'):
	proteingoop = file
	if goodids in buscodict:

#make dictionary with contigs as key, buscoids as values (use zip of 2 lists)
#scan good ids through dict values, if hit use key to extract relevant proteingoop (.faa)
#append .faa file to new file w/ good id name
#also make master file with all info ie. file w/ goodid, contifid, sourcetrans

#for line in masterfile:
#	l = line.split("\t")
#	buscoid = l[0] #BUSCO
#	contigid = l[3] #transcript
#	sourcetrans = l[5] #transcriptome source
for file in glob('run_*/translated_proteins/*.faa'):
	contigfile = file
	for thing in goodids:
		with open(thing + '.fasta', 'w') as fasta:
			with open(thing + '_master.csv', 'w') as master:
				if thing in buscoid:
					master.write(line.strip())
					master.write("\n")
						



#			if goodids in buscoid:
#			        if not os.path.isfile(contigfile):
#			        	continue
#			        cat_cmd = "cat " + contigfile + " >> " + buscoid + ".fasta"
#			cat_cmd2 = "print" + buscoid + "\t" + sourcetrans + contigid #pretty sure this is all forms of messed up. Better in python than pseudo-bash
#				print cat_cmd
#				os.system(cat_cmd)
#		        print cat_cmd2
#		        os.system(cat_cmd2)
#buscoid + "\t" + sourcetrans + "t" + contigid	
