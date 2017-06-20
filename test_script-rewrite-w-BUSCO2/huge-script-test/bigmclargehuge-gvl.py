#!/usr/bin/env python
import os, sys, glob, pandas, re, shutil, collections
from glob import glob
from collections import defaultdict
from re import sub

def completequery(): #find which BUSCOs are complete or fragmented in run
	with open('BUSCOs-complete-frag.tsv', 'w') as out:
#now this is input:
		for file in glob('run*/full_table_*'):
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
			if IDdict.get(entry) >= 15: #if value for each key is the same as target or higher
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
								linedup = lined.upper() #needs to be written in  upper case to not confuse w uncertain alignment in cleanaln()
								fasta.write(linedup.strip()) 
								fasta.write("\n")

def hmmaln(): #use hmmer to extract correct ORF for fastafiles and align
	for file in glob('EP*.fasta'): #fasta files w all 6 ORFs of protein files
		buscoID = file.split(".")[0] #get busco ID
		with open(file, 'r'):
#	for buscoID in buscscore:
			search_cmd = "/mnt/wonderworld/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmsearch --tblout " + buscoID + ".tbl /mnt/wonderworld/programs/busco/protists_ensembl/hmms/" + buscoID + ".hmm " + buscoID + ".fasta"
			index_cmd = "/mnt/wonderworld/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch --index " + buscoID + ".fasta"
			extr_cmd = "grep -v \"^#\" " + buscoID + ".tbl | gawk \'{print $1}\' | /mnt/wonderworld/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch -f " + buscoID + ".fasta -> " + buscoID + "-seq.fa"""
			align_cmd = "/mnt/wonderworld/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmalign --outformat afa /mnt/wonderworld/programs/busco/protists_ensembl/hmms/" + buscoID + ".hmm " + buscoID + "-seq.fa > " + buscoID + ".aln.fa"
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
def sanitycheck(): #sometimes hmmer extracts seq with low affinity to ref lib // rewrite as target being number of lines in info file for the BUSCO
	for file in glob('EP*.clean.aln.fa'): # all new clean alignments
		with open(file , 'r') as query:
			total = 0 #reset counter for every file
			nom = file.split(".")[0]
			ref = open(nom + '_info.tsv' , 'r')
			dataref = pandas.read_csv(ref, sep='\t')
			for line in query: 
				sane = dataref.shape[0]
				check = line.find('>') # check by line for > which designates start of fasta
				if check != -1 and query != 0:
					total += 1 # if > present, +1 to total
			if total > sane: #insert number of transcriptomes here
				print('\n\n    %%%%%%%%%%%%%%%%%%%%%%\n    %%\n    %% WARNING\n    %%\n    %% Hissy fit alignment\n    %%\n    %% ' + file + '    \n    %%\n    %%%%%%%%%%%%%%%%%%%%%\n\n') # if there is too many 
			else:
#				buscIDagain = file.split(".")[0]
				jar_cmd = "java -jar /mnt/wonderworld/programs/readseq.jar -f17 " + file
				os.system(jar_cmd)

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
hmmaln()
cleanaln()
sanitycheck()

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
