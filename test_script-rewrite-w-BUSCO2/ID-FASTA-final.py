#!/usr/bin/env python
import os,sys,pandas, glob, pandas, re, shutil
from glob import glob

#argv[2] is 555_BUSCO_unique-single-count.txt // make into list to cycle though
uniqueids = open('BUSCOs-unique-single.tsv', 'r')
colnames = ['a']
df = pandas.read_csv(uniqueids, sep='\t', names=colnames) #turning column into dataframe with single column
goodids = df.a.tolist() #dataframe to list of common BUSCO IDs
masterfile = open('BUSCOs-complete-frag.tsv', 'r')
mornames = ['buscoid', 'contigid', 'sourcetrans']
masterdata = pandas.read_csv(masterfile, sep='\t', names=mornames) #dataframe of BUSCOIDs, contig IDs and organsim
for thing in goodids: #for each entry in list of common BUSCO IDs
	mast = masterdata[masterdata.buscoid == thing ]
	with open(thing + '_info.csv', 'w') as infom: #making info file with data for each common busco ID
		print >> infom , mast 
	with open(thing + '.fasta', 'w') as fasta:
		protlist = mast.contigid.tolist()
		for file in glob('run_*/translated_proteins/*.faa'): #looking through all sub directories 
			proteingoop = file.split("/")[2] #pull contig IDs from file name
			with open(file, 'r') as f:
				for line in f:
					for protbusc  in protlist:
						if protbusc in proteingoop:
							fasta.write(line.strip())
							fasta.write("\n")
	













#					print >> fasta,
#		print protlist	
		


#need to get the damn 
#				print >> fasta 
#				intprot = shutil.proteingoop(fasta, sys.stdout)
#				fasta.write(intprot)
#				fasta.write("\n")



#		mast = masterdata.loc[masterdata['buscoid'] == thing ]
#		fasta.write(masterdata.loc[masterdata['buscoid'] == thing])
#		print mast

#		print(masterdata.loc[masterdata['buscoid'] == thing])
#		fasta.write(line)
#buscoid = df.a.tolist()
#contigid = df.c.tolist()
#sourcetrans = df.f.tolist() #source of contig
#buscodict = zip(contigid , buscoid) #turns into list for some reason not dict
#for thing in goodids: #CAUSING REPEAT LOOP
#			for entry in buscodict:
#				if buscodict.get(entry) == thing:
#					ergh = buscodict.keys() #get key
#			if thing in buscodict:
#				get key and match to proteingoop

#				append proteingoop to fasta
#important for file search:
#for file in glob('run_*/translated_proteins/*.faa'): #looking through all sub directories //also CAUSING REPEAT LOOP
#	proteingoop = file.split("/")[2] #^all trnaslated contig files kk
#	print len(proteingoop)

	#if goodid in buscodict value, find associated key
	#use key to get associated proteingoop file
	#append file contents to goodid.fasta

#for file in glob('run_*/translated_proteins/*.faa'): #looking through all sub directories 
#	proteingoop = file #^all trnaslated contig files
#	if goodids in buscodict: #if common BUSCO in value then
#maybe need for loop here to make it work
#		thing = buscodict.get(goodids) #get the associated key to 

#		print buscodict
#make dictionary with contigs as key, buscoids as values (use zip of 2 lists)
#scan good ids through dict values, if hit use key to extract relevant proteingoop (.faa)
#append .faa file to new file w/ good id name
#also make master file with all info ie. file w/ goodid, contifid, sourcetrans

#for line in masterfile:
#	l = line.split("\t")
#	buscoid = l[0] #BUSCO
#	contigid = l[3] #transcript
#	sourcetrans = l[5] #transcriptome source
#for file in glob('run_*/translated_proteins/*.faa'):
#	contigfile = file
#	for thing in goodids:
#		with open(thing + '.fasta', 'w') as fasta:
#			with open(thing + '_master.csv', 'w') as master:
#				if thing in buscoid:
#					master.write(line.strip())
#					master.write("\n")
						



#			if goodids in buscoid:
#			        if not os.path.isfile(contigfile):
#			        	continue
#			        cat_cmd = "cat " + contigfile + " >> " + buscoid + ".fasta"
#			cat_cmd2 = "print" + buscoid + "\t" + sourcetrans + contigid #pretty sure this is all forms of messed up. Better in python than pseudo-bash
#				print cat_cmd
#				os.system(cat_cmd)
#		        print cat_cmd2
#		        os.system(cat_cmd2)
#buscoid + "\t" + sourcetrans + "t" + contigid	
