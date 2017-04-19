#!/usr/bin/env python

import sys
import os

sourcef = open('BUSCOs-complete-frag.tsv', 'r')
for line in sourcef: #current problem: only calls first line
	buscoIDs = line.split("\t")[0]
	contig = line.split("\t")[2]
	sourcetrans = line.split("\t")[5]
	for line in sourcef:
		with open(buscoIDs + '_rep.tsv', 'w') as out:
			if buscoIDs in line:
				out.write(line.strip())
				out.write("\n")
#
#print buscoIDs

#argv[2] is 555_BUSCO_unique-single-count.txt
#goodfile = open(sys.argv[2])
#goodids = {}
#for line in goodfile:
#    goodids[line.rstrip("\n")]=1

#argv[1] is 14trans_complete_BUSCOs-plus-frag-carib.txt
#buscofile = open(sys.argv[1])
#for line in buscofile:
#    l = line.split()
#    buscoid = l[0].split(":")[1] #BUSCO
#    contigid = l[2] #MMETSP
#    if buscoid in goodids:
#        contigfile = "translated_proteins/" + contigid + "_ts.fas"
#        if not os.path.isfile(contigfile):
#        	continue
#        cat_cmd = "cat " + contigfile + " >> " + buscoid + ".fasta"
#        print cat_cmd
#        os.system(cat_cmd)
#        print buscoid + "\t" + contigid
