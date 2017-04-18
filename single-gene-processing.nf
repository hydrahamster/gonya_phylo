#!/usr/bin/env nextflow


params.fulltable = "/mnt/transient_nfs/transciptomes/output/full_table_*"
params.hmmerlib = "/mnt/transient_nfs/programs/busco/protists_ensembl/hmms"

fulltable = file(params.fulltable)
hmmerlib = file(params.hmmerlib

/*
 *Work out which complete BUSCOs are in each transcriptome asm
 *Make directory wirh all full tables to work im rather than searching sub directories OR change path in script to folder
 *input/output should be correct in script
 */
process completequery {

input
file fulltable

output
file("BUSCOs-complete-frag.tsv") into compq

"""
#!/usr/bin/env python

import os,sys,glob
from glob import glob
with open('BUSCOs-complete-frag.tsv', 'w') as out:
    for file in glob(${fulltable}):
	sfile = file.split("_")[3]
        with open(file, 'r') as f:
            for line in f:
                if 'Complete' in line or 'Fragmented' in line:
			out.write(line.strip())
			out.write("\t")
			out.write(sfile)
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
	sourcef = open(${BUSCOs-list}, 'r') #single ' or double " ?
	colnames = ['a', 'b', 'c', 'd', 'e', 'f'] 
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

import sys
import os

#argv[2] is 555_BUSCO_unique-single-count.txt
goodfile = open(sys.argv[2])
goodids = {}
for line in goodfile:
    goodids[line.rstrip("\n")]=1

#argv[1] is 14trans_complete_BUSCOs-plus-frag-carib.txt
buscofile = open(sys.argv[1])
for line in buscofile:
    l = line.split()
    buscoid = l[0].split(":")[1] #BUSCO
    contigid = l[2] #MMETSP
    if buscoid in goodids:
        contigfile = "translated_proteins/" + contigid + "_ts.fas"
        if not os.path.isfile(contigfile):
        	continue
        cat_cmd = "cat " + contigfile + " >> " + buscoid + ".fasta"
        print cat_cmd
        os.system(cat_cmd)
        print buscoid + "\t" + contigid
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
 *
 */
process characterchange {

input

output

"""
sed -i -e s/MMETSP0228-Protoceratium-reticulatum-CCCM535__CCMP1889_.1/PROTOCERATIUM-RETICULATUM/g *.aln.fa
sed -i -e s/MMETSP0093-Alexandrium-monilatum-JR08.1/ALEXANDRIUM-MONILATUM/g *.aln.fa
sed -i -e s/MMETSP0790-Alexandrium-catenella-OF101.1/ALEXANDRIUM-CATANELLA/g *.aln.fa
sed -i -e s/MMETSP0796-Pyrodinium-bahamense-.1/PYRODINIUM-BAHAMENSE/g *.aln.fa
sed -i -e s/Karenia-brevis-CCMP2229.1/KARENIA-BREVIS/g *.aln.fa
sed -i -e s/MMETSP1439-Gonyaulax-spinifera-CCMP409.1/GONYAULAX-SPINIFERA/g *.aln.fa
sed -i -e s/hg4/GAMBIERDISCUS-LAPILLUS/g *.aln.fa
sed -i -e s/MMETSP0797-Dinophysis-acuminata-DAEP01.1/DINOPHYSIS-ACUMINATA/g *.aln.fa
sed -i -e s/MMETSP1032-Lingulodinium-polyedra-CCMP1738.1/LINGULODINIUM-POLYEDRA/g *.aln.fa
sed -i -e s/MMETSP0766_2-Gambierdiscus-australes-CAWD149.1/GAMBIERDISCUS-AUSTRALES/g *.aln.fa
sed -i -e s/hg5/GAMBIERDISCUS-CF-SILVAE/g *.aln.fa
sed -i -e s/MMETSP1074-Ceratium-fusus-.1/CERATIUM-FUSUS/g *.aln.fa
sed -i -e s/MMETSP0326_2-Crypthecodinium-cohnii-Seligo.1/CRYPTHECODINIUM-CHONII/g *.aln.fa
sed -i -e s/MMETSP1036_2-Azadinium-spinosum-3D9.1/AZADINIUM-SPINOSUM/g *.aln.fa
sed -i -e s/CL32990Contig1_1-1335_4/GAMBIERDISCUS-CARIBAEUS_CL32990CONTIG1_4/g *.aln.fa
sed -i -e s/CL192098Contig1_1-376_1/GAMBIERDISCUS-CARIBAEUS_CL192098CONTIG1_1/g *.aln.fa
sed -i -e s/CL74Contig8_1-995_2/GAMBIERDISCUS-CARIBAEUS_CL74CONTOG8_2/g *.aln.fa
sed -i -e s/CL11296Contig1_1-828_6/GAMBIERDISCUS-CARIBAEUS_CL11296CONTIG1_6/g *.aln.fa
sed -i -e s/CL47658Contig1_1-2218_6/GAMBIERDISCUS-CARIBAEUS_CL47658CONTIG1_6/g *.aln.fa
sed -i -e s/contig/CONTIG/g *.aln.fa
sed -i -e s/[a-z]/-/g *.aln.f
sed -i -e s/*/-/g *.aln.fa
"""

}

/*
 *
 *may need to find a better way to make readseq work, wildcard may not work 
 */
process convertnexus {

input

output

"""
java -jar readseq.jar -f17 *.aln.fa
"""
}
