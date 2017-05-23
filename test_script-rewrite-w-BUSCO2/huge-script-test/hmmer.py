#!/usr/bin/env python

import os, sys, glob, pandas, re, shutil, collections
from glob import glob

for file in glob('EP*.fasta'):
	buscoID = file.split(".")[0]
	with open(file, 'r'):
#	for buscoID in buscscore:
		search_cmd = "/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmsearch --tblout " + buscoID + ".tbl /home/nurgling/Programs/busco/protists_ensembl/hmms/" + buscoID + ".hmm " + buscoID + ".fasta"
		index_cmd = "/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch --index " + buscoID + ".fasta"
		extr_cmd = "grep -v \"^#\" " + buscoID + ".tbl | gawk \'{print $1}\' | /home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch -f " + buscoID + ".fasta -> " + buscoID + "-seq.fa"""
		align_cmd = "/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmalign --outformat afa /home/nurgling/Programs/busco/protists_ensembl/hmms/" + buscoID + ".hmm " + buscoID + "-seq.fa > " + buscoID + ".aln.fa"
		os.system(search_cmd)
		os.system(index_cmd)
		os.system(extr_cmd)
		os.system(align_cmd)
#problem: uses all 6 ORFs to align


#BUSCOID=$(basename ${buschmm} .hmm) #fuck let's hope this works
#for BUSCOID in ${fastas}; do 
#	/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/hmmsearch --tblout $BUSCOID.tbl ${buschmm} $BUSCOID.fasta
#
# make index for input file
#	/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/esl-sfetch --index $BUSCOID.fasta

# use table to extract sequences with hits
#	grep -v "^#" $BUSCOID.tbl | gawk '{print $1}' | /home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/esl-sfetch -f $BUSCOID.fasta - > $BUSCOID-seq.fa

# align extracted seqs to library file
#	/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/hmmalign --outformat afa ${buschmm} $BUSCOID-seq.fa > $BUSCOID.aln.fa

#done
