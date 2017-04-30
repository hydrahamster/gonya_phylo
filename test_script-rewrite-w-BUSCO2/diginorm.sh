
#!/bin/bash

# to run change organism variable and with khmer env active:
#	source khmerEnv/bin/activate

organism=strain_source

#make working and file directories, link data
mkdir trimming_temp
mkdir trimmed
cd trimming_temp
ln -fs ../*.fastq.gz .

# run trimmomatic
java -jar /mnt/transient_nfs/programs/trimmomatic-0.36.jar PE -phred64 *_L001_R1_* *_L001_R2_* s1_pe s1_se s2_pe s2_se LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25

# interleave the remaining paired-end files
interleave-reads.py s1_pe s2_pe | gzip -9c > ../trimmed/$organism_L001.pe.fq.gz

# combine the single-ended files
cat s1_se s2_se | gzip -9c > ../trimmed/$organism_L001.se.fq.gz

# clear the temporary files
rm s*

# run trimmomatic
java -jar /mnt/transient_nfs/programs/trimmomatic-0.36.jar PE -phred64 *_L002_R1_* *_L002_R2_* s1_pe s1_se s2_pe s2_se LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25

# interleave the remaining paired-end files
interleave-reads.py s1_pe s2_pe | gzip -9c > ../trimmed/$organism_L002.pe.fq.gz

# combine the single-ended files
cat s1_se s2_se | gzip -9c > ../trimmed/$organism_L002.se.fq.gz

# clear the temporary files
rm s*


# run trimmomatic
java -jar /mnt/transient_nfs/programs/trimmomatic-0.36.jar PE -phred64 *_L003_R1_* *_L003_R2_* s1_pe s1_se s2_pe s2_se LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25

# interleave the remaining paired-end files
interleave-reads.py s1_pe s2_pe | gzip -9c > ../trimmed/$organism_L003.pe.fq.gz

# combine the single-ended files
cat s1_se s2_se | gzip -9c > ../trimmed/$organism_L003.se.fq.gz

# clear the temporary files
rm s*

# run trimmomatic
java -jar /mnt/transient_nfs/programs/trimmomatic-0.36.jar PE -phred64 *_L004_R1_* *_L004_R2_* s1_pe s1_se s2_pe s2_se LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25

# interleave the remaining paired-end files
interleave-reads.py s1_pe s2_pe | gzip -9c > ../trimmed/$organism_L004.pe.fq.gz

# combine the single-ended files
cat s1_se s2_se | gzip -9c > ../trimmed/$organism_L004.se.fq.gz

# clear the temporary files
rm s*

# make it hard to delete the files you just created
cd ../trimmed
chmod u-w *

#
#cd ..
#mkdir diginorm
#cd diginorm

normalize-by-median.py -k 20 -M 6e9 -C 20 -p *.pe.fq.gz

for file in *.keep
do
   newfile=${file%%.fq.gz.keep}.keep.fq
   mv ${file} ${newfile}
   gzip ${newfile}
done


for file in *.pe.keep.fq.gz
do
   split-paired-reads.py ${file}
done

cat *.1 > $organism_left.fq
cat *.2 > $organism_right.fq

sudo/mnt/transient_nfs/programs/trinityrnaseq-Trinity-v2.4.0/Trinity --seqType fq --left $organism_left.fq --right $organism_right.fq --max_memory 50G --CPU 10 --output ./$organism_out-fuckoff-trinity

mv $organism_out-fuckoff-trinity/Trinity.fasta $organism_assembly.fasta

python /mnt/transient_nfs/programs/busco/BUSCO.py -i $organism_assembly.fasta -o $organism_BUSCO -l /mnt/transient_nfs/programs/busco/protists_ensembl -m tran -c 10

python /mnt/transient_nfs/programs/busco/BUSCO.py -i CG15_G-polynesiensis_assembly.fasta -o CG15_G-polynesiensis_BUSCO -l /mnt/transient_nfs/programs/busco/protists_ensembl -m tran -c 10
