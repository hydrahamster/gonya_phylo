#!/usr/bin/env python

import os, sys, glob, pandas, re, shutil, collections
from glob import glob
from re import sub

for file in glob('EP*.aln.fa'):
	buscID = file.split(".")[0]
	with open(buscID + '.clean.aln.fa' , 'w') as wut:
		with open(file, 'r') as reading:
			for line in reading:
#				linrepl = line.replace('\*', '-')
				linclean = sub("[a-z]" , '-' , line)
				linrepl = sub("\*" , '-' , linclean)
				wut.write(linrepl.strip())
				wut.write("\n")
#				print linrepl
