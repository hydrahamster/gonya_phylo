#!/usr/bin/env nextflow

process completequery {

input

output

}

process countBUSCO {

input

output

}

process verifyunique {

input

output

}

process IDtofasta {

input

output

}

process hmmsearchalign {

input

output

}

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

process convertnexus {
// may need to find a better way to make readseq work, wildcard may not work

input

output

"""
java -jar readseq.jar -f17 *.aln.fa
"""
}
