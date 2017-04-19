#!/usr/bin/env python
import os,sys,pandas, glob
from glob import glob

#argv[2] is 555_BUSCO_unique-single-count.txt
for line in open('BUSCOs-unique-single.tsv', 'r'):
	goodids = line
#for line in goodfile:
#    goodids[line.rstrip("\n")]=1

#argv[1] is 14trans_complete_BUSCOs-plus-frag-carib.txt
	buscofile = open('BUSCOs-complete-frag.tsv', 'r')
	for line in buscofile:
  		l = line.split("\t")
   		buscoid = l[0] #BUSCO
		contigid = l[3] #transcript
		sourcetrans =l[5] #transcriptome source
		for file in glob('run_*/translated_proteins/*.faa'):
			contigfile = file
			if goodids in buscoid:
			        if not os.path.isfile(contigfile):
			        	continue
			        cat_cmd = "cat " + contigfile + " >> " + buscoid + ".fasta"
#			cat_cmd2 = "print" + buscoid + "\t" + sourcetrans + contigid #pretty sure this is all forms of messed up. Better in python than pseudo-bash
				print cat_cmd
				os.system(cat_cmd)
#		        print cat_cmd2
#		        os.system(cat_cmd2)
#buscoid + "\t" + sourcetrans + "t" + contigid	
