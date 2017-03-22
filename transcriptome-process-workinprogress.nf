#!/usr/bin/env nextflow
/*
 * Usage: ./transcriptome-process.nf --forward=read1.fastq --revwerse=read2.fastq
 */


params.forward = ""
params.revwerse = ""

/*
 *forward = file(params.forward)
 *reverse = file(params.revwerse)
 */

forwardtrim = file(params.forward)
reversetrim = file(params.revwerse)

process fastqcfor {

input:
file freads from forward

"""
java -jar /usr/bin/fastqc $freads
"""

}

process fastqcrev {
--> not working. java version?
input:
file rreads from reverse

"""
java -jar /usr/bin/fastqc $rreads
"""

}

 
process trimmomaticfor {

input:
file freads from forwardtrim
file rreads from reversetrim

output: 
// should be the par end thing for next process.. also can I change output file names?
// $splitname  as part of naming output?
// own seq change to -phred33 and MINLEN: depending on insert size
set file('*.forward_paired.fq.gz'),file('*.reverse_paired.fq.gz') into trimmedfq


"""
java -jar /mnt/transient_nfs/programs/trimmomatic-0.36.jar \
	PE -phred64 \
	${freads} ${rreads} \
	${freads}.forward_paired.fq.gz ${freads}.forward_unpaired.fq.gz \
	${rreads}.reverse_paired.fq.gz ${rreads}.reverse_unpaired.fq.gz \
	LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25
"""

}


process trinity {

input:
set file(r1),file(r2) from trimmedfq
// if multiple libraries, need to combine in single left.fq and right.fq files

output:
file('${r1}-assembly.fasta') into asm

"""
/mnt/transient_nfs/programs/trinityrnaseq-Trinity-v2.4.0/Trinity --seqType fq --left ${r1} --right ${r2} --max_memory 50G --CPU 10 --output ./${r1}-out-fuckoff-trinity
mv ${r1}-out-fuckoff-trinity/Trinity.fasta ${r1}-assembly.fasta
"""
}


process busco {

input:
file('assembly') from asm

"""
python /mnt/transient_nfs/programs/busco/BUSCO.py -i ${assembly} -o ${assembly}_BUSCO -l /mnt/transient_nfs/programs/busco/alveolata_stramenophiles_ensembl -m tran -c 10
"""

}

process finsihscript {
--> not working
  afterScript '/mnt/transient_nfs/transciptomes/afterasm.sh'

  """
  echo donesky
  """

}
