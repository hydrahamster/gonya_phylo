#!/usr/bin/env nextflow
/*
 * Usage: ./transcriptome-process.nf --forward=read1.fastq --revwerse=read2.fastq
 */


params.forward = ""
params.revwerse = ""


forward = file(params.forward)
reverse = file(params.revwerse)


forwardtrim = file(params.forward)
reversetrim = file(params.revwerse)


process fastqcfor {
    publishDir 'output', mode: 'copy', overwrite: 'true'
input:
file freads from forward

output:
file("${freads}_fastqc.html") into freadsfstcq 

"""
/mnt/wonderworld/programs/FastQC/fastqc ${freads}
mv *_fastqc/fastqc_report.html ${freads}_fastqc.html
"""

}

//freadsfstcq.subscribe { println $it }

process fastqcrev {
    publishDir 'output', mode: 'copy', overwrite: 'true'
input:
file rreads from reverse

output:
file("${rreads}_fastqc.html") into rreadsfstcq 

"""
/mnt/wonderworld/programs/FastQC/fastqc ${rreads}
mv *_fastqc/fastqc_report.html ${rreads}_fastqc.html
"""

}

//rreadsfstcq.subscribe { println $it }
 
process trimmomaticfor {

input:
file freads from forwardtrim
file rreads from reversetrim

output: 
// own seq change to -phred33 and MINLEN: depending on insert size
set file('*.forward_paired.fq.gz'),file('*.reverse_paired.fq.gz') into trimmedfq


"""
java -jar /mnt/wonderworld/programs/trimmomatic-0.36.jar \
	PE -phred64 \
	${freads} ${rreads} \
	${freads}.forward_paired.fq.gz ${freads}.forward_unpaired.fq.gz \
	${rreads}.reverse_paired.fq.gz ${rreads}.reverse_unpaired.fq.gz \
	LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25
"""

}


process trinity {
    publishDir 'output', mode: 'copy', overwrite: 'true'
input:
set file(r1),file(r2) from trimmedfq
// if multiple libraries, need to combine in single left.fq and right.fq files

output:
file("${r1}-assembly.fasta") into asm

"""
/mnt/wonderworld/programs/trinityrnaseq-Trinity-v2.4.0/Trinity --seqType fq --left ${r1} --right ${r2} --max_memory 50G --CPU 10 --output ./${r1}-out-fuckoff-trinity
mv ${r1}-out-fuckoff-trinity/Trinity.fasta ${r1}-assembly.fasta
"""
// is this move fucking up the asm channel?

}

//asm.subscribe { println $it }

process busco {
    publishDir 'output', mode: 'copy', overwrite: 'true'
input:
file assembly from asm

output:
file("full_table_*")
file("short_summary_*")
//since asm was put into output, is it going toscrew the directory that BUSCO is looking in?
"""
python /mnt/wonderworld/programs/busco/BUSCO.py -i ${assembly} -o ${assembly}_BUSCO -l /mnt/wonderworld/programs/busco/protists_ensembl -m tran -c 10
"""

}
