#!/usr/bin/env nextflow


params.fulltable = "/mnt/wonderworld/transcriptomes/output/run_*/full_table_*"
params.hmmerlib = "/mnt/wonderworld/programs/busco/protists_ensembl/hmms/*"
params.protseqs = "/mnt/wonderworld/transcriptomes/output/run_*/translated_proteins/*"

fulltable = file(params.fulltable)
hmmerlib = file(params.hmmerlib
protfiles = file(params.protseqs)

/*
 *Count how many single complete/frag BUSCOs are common across the transcriptomes
 *input/output should be correct in script
 */
process AAtag {

input:
file protraw from protfiles

output:

"""
#!/usr/bin/env python
import os,sys,pandas, glob, pandas, re, shutil
from glob import glob

for file in glob('run_*/translated_proteins/*.faa'): #looking through all sub directories 
	fie = file.split("/")[0]
	name = file.split("/")[2]
	nup = name.upper()
	sourcey = fie.split("_")[2] #pull contig IDs from file name
	upsourcey = sourcey.upper()
	with open(file, 'r') as inni:
		with open(upsourcey + '_' + nup, 'w') as outy:
#		with open(sourcey + '_' + file, 'w') as p:
			for line in inni:
				if '>' in line:
#			f.write(line.replace('>', '>' + sourcey + '_'))
					lined = line.replace('>', '>' + upsourcey + '_')
					linedup = lined.upper()
					outy.write(linedup.strip())
					outy.write("\n")
				else:
					outy.write(line)
"""

}


/*
 *Work out which complete BUSCOs are in each transcriptome asm
 *Make directory wirh all full tables to work im rather than searching sub directories OR change path in script to folder
 *input in python still ${xx}? Do I still need glob?
 */
process completequery {

input:
file tablesin from fulltable

output
file("BUSCOs-complete-frag.tsv") into compq

"""
#!/usr/bin/env python

import os,sys,glob
from glob import glob
with open('BUSCOs-complete-frag.tsv', 'w') as out:
    for file in glob(${tablesin}):
	sfile = file.split("_")[3]
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
"""

}


/*
 *Count how many single complete/frag BUSCOs are common across the transcriptomes
 *input/output should be correct in script
 */
process countBUSCO {

input
file BUSCOs-list from compq

output
file("BUSCOs-unique-single.tsv") into uniquelist

"""
#!/usr/bin/env python

import os,sys,pandas, collections
from collections import defaultdict

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
#			prod.write(line.strip())
			prod.write(entry)
			prod.write("\n") #next entry on new line
"""

}

/*
 *
 */
process IDtofasta {

input

output

"""
#!/usr/bin/env python
import os,sys,pandas, glob, pandas, re, shutil
from glob import glob

#argv[2] is 555_BUSCO_unique-single-count.txt // make into list to cycle though
uniqueids = open('BUSCOs-unique-single.tsv', 'r')
colnames = ['a']
df = pandas.read_csv(uniqueids, sep='\t', names=colnames) #turning column into dataframe with single column
goodids = df.a.tolist() #dataframe to list of common BUSCO IDs
masterfile = open('BUSCOs-complete-frag.tsv', 'r')
mornames = ['buscoid', 'contigid', 'sourcetrans']
masterdata = pandas.read_csv(masterfile, sep='\t', names=mornames) #dataframe of BUSCOIDs, contig IDs and organsim
for thing in goodids: #for each entry in list of common BUSCO IDs
	mast = masterdata[masterdata.buscoid == thing ]
	with open(thing + '_info.csv', 'w') as infom: #making info file with data for each common busco ID
		print >> infom , mast 
	with open(thing + '.fasta', 'w') as fasta:
		protlist = mast.contigid.tolist()
		for file in glob('run_*/translated_proteins/*.faa'): #looking through all sub directories 
			fie = file.split("/")
			proteingoop = fie[2] #pull contig IDs from file name
			srcint = fie[0]
			src = srcint.split("_")[2]
			with open(file, 'r') as f:
				for line in f:
					for protbusc  in protlist:
						if protbusc in proteingoop:
#							fasta.write(src + '_' + line.strip())
							fasta.write(line.strip())
							fasta.write("\n")
"""
}

/*
 *
 */
process hmmsearchalign {

input

output

"""
#!/bin/bash

BUSCOID=$1

#remove previously built reference
#rm all15incl-caribaeus-6xORfs.fasta.ssi

# search and output names of hits into table
/panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmsearch --tblout BUSCOeuk$BUSCOID.tbl hmmer_profiles/BUSCOeuk$BUSCOID.hmm $BUSCOID.fasta

# make index for input file
/panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch --index $BUSCOID.fasta

# use table to extract sequences with hits
grep -v "^#" BUSCOeuk$BUSCOID.tbl | gawk '{print $1}' | /panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch -f $BUSCOID.fasta - > BUSCOeuk$BUSCOID-seq.fa

# align extracted seqs to library file
/panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmalign --outformat afa hmmer_profiles/BUSCOeuk$BUSCOID.hmm BUSCOeuk$BUSCOID-seq.fa > BUSCOeuk$BUSCOID.aln.fa
"""
}

/*
 * clean uncertain alignments
 */
process characterchange {

input

output

"""
sed -i -e s/[a-z]/-/g *.aln.f
sed -i -e s/*/-/g *.aln.fa
"""

}

/*
 *
 */
process convertnexus {

input

output

"""
java -jar readseq.jar -f17 *.aln.fa
"""
}
