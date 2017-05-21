#!/usr/bin/env python

import sys
import os

buscin = 'EP*.fasta'
buscscore = buscin.split(".")[0]

for buscoID in buscscore:
	search_cmd = "/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/hmmsearch --tblout " + buscoID + ".tbl /home/nurgling/Programs/busco/protists_ensembl/hmms/" + buscoID + ".hmm " + buscoID + "-collect.fasta"
	index_cmd = "/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/esl-sfetch --index " + buscoID + "-collect.fasta"
	extr_cmd = "grep -v \"^#\" " + buscoID + ".tbl | gawk \'{print $1}\' | /home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/esl-sfetch -f " + buscoID + "-collect.fasta -> " + buscoID + "-seq.fa"
	align_cmd = "/home/nurgling/Programs/hmmer-3.1b2-linux-intel-x86_64/hmmalign --outformat afa /home/nurgling/Programs/busco/protists_ensembl/hmms/" + buscoID + ".hmm " + buscoID + "seq.fa > " + buscoID + ".aln.fa"
	print search_cmd
	print index_cmd
	print extr_cmd
	print align_cmd


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
