#!/usr/bin/env nextflow


params.fulltable = "/mnt/wonderworld/transcriptomes/output/run_*/full_table_*"
params.hmmerlib = "/mnt/wonderworld/programs/busco/protists_ensembl/hmms/*"
params.protseqs = "/mnt/wonderworld/transcriptomes/output/run_*/translated_proteins/*"

fulltable = file(params.fulltable)
hmmerlib = file(params.hmmerlib
protfiles = file(params.protseqs)

/*
 *How do I deal with the input channles?
 */
process buscofasta {
    publishDir 'align_output', mode: 'copy', overwrite: 'true'
input:
file protraw from protfiles
file tables from

output:
file("EP*.fasta") into uniquebuscos

#"""
#!/usr/bin/env python
import os, sys, glob, pandas, re, shutil, collections
from glob import glob
from collections import defaultdict

def completequery():
	with open('BUSCOs-complete-frag.tsv', 'w') as out:
		for file in glob('run*/full_table_*'):
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
	uniqueids = open('BUSCOs-unique-single.tsv', 'r')
	colnames = ['a']
	df = pandas.read_csv(uniqueids, sep='\t', names=colnames) #turning column into dataframe with single column
	goodids = df.a.tolist() #dataframe to list of common BUSCO IDs
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


completequery()
countBUSCOs()
IDfasta()

#"""

}



/*
 *how do I match the file and the hmmlib here to feed in?
 */
process hmmsearchalign {

input:
file fastas from uniquebuscos
file buschm from hmmerlib

output:
file("BUSCO*.aln.fa") into aln

#"""
#!/bin/bash
BUSCOID=$(basename ${buschm} .hmm)
for BUSCOID in ${fastas}; do #somehow split on '.' and only use first half as "in"
# search and output names of hits into table
	/panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmsearch --tblout BUSCOeuk$BUSCOID.tbl hmmer_profiles/BUSCOeuk$BUSCOID.hmm $BUSCOID.fasta

# make index for input file
	/panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch --index $BUSCOID.fasta

# use table to extract sequences with hits
	grep -v "^#" BUSCOeuk$BUSCOID.tbl | gawk '{print $1}' | /panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch -f $BUSCOID.fasta - > BUSCOeuk$BUSCOID-seq.fa

# align extracted seqs to library file
	/panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmalign --outformat afa hmmer_profiles/BUSCOeuk$BUSCOID.hmm BUSCOeuk$BUSCOID-seq.fa > BUSCOeuk$BUSCOID.aln.fa

done
#"""
}

/*
 * clean uncertain alignments
 */
process characterchange {
    publishDir 'align_output', mode: 'copy', overwrite: 'true'
input:
file algns from aln

output:
file("BUSCO*.aln.fa") into clnaln

#"""
sed -i -e s/[a-z]/-/g ${algns}
sed -i -e s/*/-/g ${algns}
#"""

}

/*
 *
 */
process convertnexus {
    publishDir 'align_output', mode: 'copy', overwrite: 'true'
input:
file cleaned from clnaln

output:
file("*.nexus") into voila

#"""
java -jar readseq.jar -f17 ${cleaned}
#"""
}
