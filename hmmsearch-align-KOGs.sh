#!/bin/bash

KOGID=$1


# search and output names of hits into table
/panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmsearch --tblout KOG$KOGID.tbl KOG$KOGID.hmm all-KOG.fasta

# make index for input file
/panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch --index all-KOG.fasta

# use table to extract sequences with hits
grep -v "^#" KOG$KOGID.tbl | gawk '{print $1}' | /panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/esl-sfetch -f all-KOG.fasta - > KOG$KOGID-seq.fa

# align extracted seqs to library file
/panfs/panspermia/125155/programs/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmalign --outformat afa KOG$KOGID.hmm KOG$KOGID-seq.fa > KOG$KOGID-seq.aln.fa


