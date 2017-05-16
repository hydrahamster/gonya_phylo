#!/usr/bin/env python
import os,sys,pandas, glob, pandas, re, shutil
from glob import glob

for file in glob('run_*/translated_proteins/*.faa'): #looking through all sub directories 
	fie = file.split("/")[0]
	name = file.split("/")[2]
	nup = name.upper()
	sourcey = fie.split("_")[2] #pull contig IDs from file name
	upsourcey = sourcey.upper()
	with open(file, 'r') as inni:
		with open(upsourcey + '_' + nup, 'w') as outy:
#		with open(sourcey + '_' + file, 'w') as p:
			for line in inni:
				if '>' in line:
#			f.write(line.replace('>', '>' + sourcey + '_'))
					lined = line.replace('>', '>' + upsourcey + '_')
					linedup = lined.upper()
					outy.write(linedup.strip())
					outy.write("\n")
				else:
					outy.write(line)
#					outy.write("\n")
#			print line
