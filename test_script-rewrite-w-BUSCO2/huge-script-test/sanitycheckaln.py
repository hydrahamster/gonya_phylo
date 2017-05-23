#!/usr/bin/env python

import os, sys, glob, pandas, re, shutil, collections
from glob import glob

for file in glob('EP*.clean.aln.fa'):
	with open(file , 'r') as query:
		total = 0
		for line in query:
			check = line.find('>')
			if check != -1 and query != 0:
				total += 1
		if total > 2: #insert number of transcriptomes here
			print file
		
