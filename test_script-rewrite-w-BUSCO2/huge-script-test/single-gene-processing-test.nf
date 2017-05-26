#!/usr/bin/env nextflow

/*
 * requires Python 2.7.x
 * 
 *How to run: 
 * - change params for correct PATHs
 * - ./single-gene-processing.nf
 *
 *params.fulltable PATH to pipeline1 BUSCO full table output. as ${full_table}
 *params.hmmerlib PATH to hmmer reference libraries ie. BUSCO.hmm. as ${hmmer_lib}
 *params.hmmerbin PATH to hmmer binaries. as ${hmmer_bin}
 *params.protseqs PATH to pipeline1 BUSCO trnaslated protein output, as ${protseqs}
 *trans_number for number of transcriptomes BUSCOs should be represented in. as ${trans_number}
 *params.reaseq PATH to readseq.jar. as ${readseqpath}
 */

params.fulltable = "/home/nurgling/PhD/gonya_phylo/test_script-rewrite-w-BUSCO2/huge-script-test/run_*/full_table_*" 
params.hmmerlib = "/home/nurgling/Programs/busco/protists_ensembl/hmms/" 
params.hmmerbin = "/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/binaries" 
params.protseqs = "/home/nurgling/PhD/gonya_phylo/test_script-rewrite-w-BUSCO2/huge-script-test/run_*/translated_proteins" 
params.reaseq = "/home/nurgling/Programs" 
trans_number = 2

full_table = file(params.fulltable)
hmmer_lib = file(params.hmmerlib)
hmmer_bin = file(params.hmmerbin)
protseqs = file(params.protseqs)
readseqpath = file(params.reaseq)


/*
 *How do I deal with the input channles?
 */

process buscofasta {
    publishDir 'align_output', mode: 'copy', overwrite: 'true'

output:
file("*.clean.aln.fa") into clnalin

"""
#!/usr/bin/env python
import os, sys, glob, pandas, re, shutil, collections
from glob import glob
from collections import defaultdict
from re import sub

def completequery(): #find which BUSCOs are complete or fragmented in run
	with open('BUSCOs-complete-frag.tsv', 'w') as out:
#now this is input:
		for file in glob('!{params.fulltable}'):
			nfile = file.split("/")[1]
			sfile = nfile.split("_")[3] #get source organism name
        		with open(file, 'r') as fum:
        		    for line in fum:
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
def countBUSCOs(): #extract the BUSCOs present in all transcriptomes, or pre-selected number of
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
			if IDdict.get(entry) == !{params.transcriptomes}: #if value for each key is the same as target
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
			for file in glob('!{params.protseqs}/*.faa'): #PROBLEM - re-write
				fie = file.split("/")
				proteingoop = fie[2] #pull contig IDs from file name
				srcint = fie[0]
				src = srcint.split("_")[2]
				with open(file, 'r') as f:
					for line in f:
						for protbusc in protlist:
							if protbusc in proteingoop:
								lined = line.replace('>', '>' + src + '_')
								linedup = lined.upper() #needs to be written in  upper case to not confuse w uncertain alignment in cleanaln()
								fasta.write(linedup.strip()) 
								fasta.write("\n")

def hmmaln(): #use hmmer to extract correct ORF for fastafiles and align
	for file in glob('EP*.fasta'): #fasta files w all 6 ORFs of protein files
		buscoID = file.split(".")[0] #get busco ID
		with open(file, 'r'):
#	for buscoID in buscscore:
			search_cmd = "'!{params.hmmerbin}'/hmmsearch --tblout " + buscoID + ".tbl '!{params.hmmerlib}'" + buscoID + ".hmm " + buscoID + ".fasta"
			index_cmd = "'!{params.hmmerbin}'/esl-sfetch --index " + buscoID + ".fasta"
			extr_cmd = "grep -v \"^#\" " + buscoID + ".tbl | gawk \'{print $1}\' | '!{params.hmmerbin}'/esl-sfetch -f " + buscoID + ".fasta -> " + buscoID + "-seq.fa"""
			align_cmd = "'!{params.hmmerbin}'/hmmalign --outformat afa '!{params.hmmerlib}'" + buscoID + ".hmm " + buscoID + "-seq.fa > " + buscoID + ".aln.fa"
			os.system(search_cmd)
			os.system(index_cmd) # make index for input file
			os.system(extr_cmd) # use table to extract sequences with hits
			os.system(align_cmd) # align extracted seqs to library file

def cleanaln(): #uses whole seqs but only parts align to the refference hmmer lib. removing uncertain alignment (lowercase) and noise (*)
	for file in glob('EP*.aln.fa'):
		buscID = file.split(".")[0] #use just ID
		with open(buscID + '.clean.aln.fa' , 'w') as wut: #new file designation
			with open(file, 'r') as reading: #old file
				for line in reading:
					linclean = sub("[a-z]" , '-' , line) #replace lowercase with -
					linrepl = sub("\*" , '-' , linclean) #replace * with -
					wut.write(linrepl.strip()) #write it
					wut.write("\n")
def sanitycheck(): #sometimes hmmer extracts seq with low affinity to ref lib
	for file in glob('EP*.clean.aln.fa'): # all new clean alignments
		with open(file , 'r') as query:
			total = 0 #reset counter for every file
			for line in query: 
				check = line.find('>') # check by line for > which designates start of fasta
				if check != -1 and query != 0:
					total += 1 # if > present, +1 to total
			if total > !{params.transcriptomes}: #insert number of transcriptomes here
				print('\n\n    %%%%%%%%%%%%%%%%%%%%%%\n    %%\n    %% WARNING\n    %%\n    %% Hissy fit alignment\n    %%\n    %% ' + file + '    \n    %%\n    %%%%%%%%%%%%%%%%%%%%%\n\n') # if there is too many 

completequery()
countBUSCOs()
IDfasta()
hmmaln()
cleanaln()
sanitycheck()
"""

}


/*
 *file conversion via readseq.jar
 */
process convertnexus {
    publishDir 'align_output', mode: 'copy', overwrite: 'true'
input:
file cleaned from clnalin

output:
file("*.nexus") into voila

"""
java -jar '!{params.reaseq}'/readseq.jar -f17 ${cleaned}
"""
}
