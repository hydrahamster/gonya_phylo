#!/usr/bin/env python

import os,sys,glob
from glob import glob
for file in glob('full_table_*'):
	sfile = file.split("_")[3]
	with open(sfile + '_query.tsv', 'w') as out:
		with open(file, 'r') as f:
			for line in f:
				if 'Complete' in line or 'Fragmented' in line:
					out.write(line.strip())
					out.write("\t")
					out.write(sfile)
					out.write("\n")
                    # same as out.write("%s, %s\n" % (line.strip(), sfile))

