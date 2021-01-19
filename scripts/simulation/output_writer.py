
import csv
import os
import copy
import pandas as pd

from pathlib import Path

import datetime
strptime = datetime.datetime.strptime

class writer:
	'''
	Class containing input and output information, reading and writing functions.
	'''

	def __init__(self, outputpath, file_prefix, init_date="2020-01-01"):
		self.fasta_path = outputpath + "/fasta"
		self.table_path = outputpath + "/table"
		self.init_date = init_date
		self.file_prefix = file_prefix

		try:
			os.mkdir(self.fasta_path)
		except OSError:
			print("Creation of the directory %s failed" % self.fasta_path)
			exit()
		try:
			os.mkdir(self.table_path)
		except OSError:
			print("Creation of the directory %s failed" % self.fasta_path)
			exit()


	def _write_fasta(self, header_prefix, species_dict, sub_abs = None, file_suffix = None):
		'''
		Write the simulated sequences into one fasta file.
		Returns a table with dates and counts.
		'''

		rows_list = []

		start_time = strptime(self.init_date, "%Y-%m-%d").date()
		t = 0

		outputfile = self.fasta_path + "/" + self.file_prefix + file_suffix + ".fasta"
		try:
			file = open(outputfile, "w+")

			print("--- Write sequences into file " + outputfile + "---")

			for spec_dict in species_dict:
				date = start_time + datetime.timedelta(days=t)

				header = header_prefix + str(date.strftime("%Y-%m-%d"))

				sampled_N = 0
				for seq, num in spec_dict.items():
					if sub_abs is not None:
						# take abolsute subsample or N(t) if less
						num = min(sub_abs, num)
					sampled_N += num
					# print( (header+"\n"+seq+"\n") * num )
					file.write((header + "\n" + seq + "\n") * num)

				# faster way to add rows to a df
				dict1 = {"t": t, "date": date, "sampled_N": sampled_N}
				rows_list.append(dict1)

				t += 1
		except OSError:
			print("Writing of fasta file %s failed" % outputfile)
			exit()
		return pd.DataFrame(rows_list)



 #def _write_true_cases(self, foldername, species_dict_per_t):