#!/bin/bash

# to run change organism variable and with khmer env active:
#	source /mnt/transient_nfs/programs/khmerEnv/bin/activate

organism='strain_source'
#THECA_Thecadinium-kofoidii

#make working and file directories, link data
mkdir trimming_temp
mkdir trimmed
cd trimming_temp
ln -fs ../*.fastq.gz .

#001.fastq.gz
# run trimmomatic
java -jar /mnt/transient_nfs/programs/trimmomatic-0.36.jar PE -phred64 *_L001_R1_001.fastq.gz *_L001_R2_001.fastq.gz s1_pe s1_se s2_pe s2_se LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25

# interleave the remaining paired-end files
interleave-reads.py s1_pe s2_pe | gzip -9c > ../trimmed/"$organism"_L001.pe.fq.gz

# combine the single-ended files
cat s1_se s2_se | gzip -9c > ../trimmed/"$organism"_L001.se.fq.gz

# clear the temporary files
#rm s*

# run trimmomatic
java -jar /mnt/transient_nfs/programs/trimmomatic-0.36.jar PE -phred64 *_L002_R1_* *_L002_R2_* s3_pe s3_se s4_pe s4_se LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25

# interleave the remaining paired-end files
interleave-reads.py s3_pe s4_pe | gzip -9c > ../trimmed/"$organism"_L002.pe.fq.gz

# combine the single-ended files
cat s3_se s4_se | gzip -9c > ../trimmed/"$organism"_L002.se.fq.gz

# clear the temporary files
#rm s*


# run trimmomatic
java -jar /mnt/transient_nfs/programs/trimmomatic-0.36.jar PE -phred64 *_L003_R1_* *_L003_R2_* s5_pe s5_se s6_pe s6_se LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25

# interleave the remaining paired-end files
interleave-reads.py s5_pe s6_pe | gzip -9c > ../trimmed/"$organism"_L003.pe.fq.gz

# combine the single-ended files
cat s5_se s6_se | gzip -9c > ../trimmed/"$organism"_L003.se.fq.gz

# clear the temporary files
#rm s*

# run trimmomatic
java -jar /mnt/transient_nfs/programs/trimmomatic-0.36.jar PE -phred64 *_L004_R1_* *_L004_R2_* s7_pe s7_se s8_pe s8_se LEADING:3 TRAILING:3 SLIDINGWINDOW:4:5 MINLEN:25

# interleave the remaining paired-end files
interleave-reads.py s7_pe s8_pe | gzip -9c > ../trimmed/"$organism"_L004.pe.fq.gz

# combine the single-ended files
cat s7_se s8_se | gzip -9c > ../trimmed/"$organism"_L004.se.fq.gz

# clear the temporary files
#rm s*

# make it hard to delete the files you just created
cd ../trimmed
chmod u-w *

#digital normalisation
cd ..
mkdir diginorm
cd diginorm

normalize-by-median.py --paired --ksize 20 --cutoff 20 --n_tables 4 --max-tablesize 6e9 -s normC20k20.ct *.pe.fq.gz

normalize-by-median.py --cutoff 20 -l normC20k20.ct -s normC20k20.ct *.se.fq.gz

#low abundance filter
cd ..
mkdir abundfilt
cd abundfilt

filter-abund.py --variable-coverage ../diginorm/normC20k20.ct --threads ${THREADS:-1} ../diginorm/*.keep

#extract good pe files for use
cd ..
mkdir digiresult
cd digiresult

for file in ../abundfilt/*pe.fq.gz.keep.abundfilt
do
   extract-paired-reads.py ${file}
done

#grab se from previous steps
cd ../abundfilt
for file in *.se.fq.gz.keep.abundfilt
do
   pe_orphans=${file%%.se.fq.gz.keep.abundfilt}.pe.fq.gz.keep.abundfilt.se
   newfile=${file%%.se.fq.gz.keep.abundfilt}.se.keep.abundfilt.fq.gz
   cat ${file} ../digiresult/${pe_orphans} | gzip -c > ../digiresult/${newfile}
   rm ${pe_orphans}
done

cd ../digiresult
for file in *.abundfilt.pe
do
   newfile=${file%%.fq.gz.keep.abundfilt.pe}.keep.abundfilt.fq
   mv ${file} ${newfile}
   gzip ${newfile}
done


for file in *.pe.keep.abundfilt.fq.gz
do
   split-paired-reads.py ${file}
done

cat *.1 > "$organism"_left.fq
cat *.2 > "$organism"_right.fq


gunzip -c *.se.keep.abundfilt.fq.gz >> "$organism"_left.fq

sudo /mnt/transient_nfs/programs/trinityrnaseq-Trinity-v2.4.0/Trinity --seqType fq --left "$organism"_left.fq --right "$organism"_right.fq --max_memory 50G --CPU 10 --output ./"$organism"_out-fuckoff-trinity

sudo mv "$organism"_out-fuckoff-trinity/Trinity.fasta "$organism"_assembly.fasta

sudo python /mnt/transient_nfs/programs/busco/BUSCO.py -i "$organism"_assembly.fasta -o "$organism"_BUSCO -l /mnt/transient_nfs/programs/busco/protists_ensembl -m tran -c 10
