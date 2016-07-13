# -----------------------------------------------------------------------------
# Author: cgarcia
# About: This is a small program to transform spreadsheets from Google Forms
#        NLICC Vacation Bible School registration into more organized format.
# -----------------------------------------------------------------------------

from csv_util import *
import sys

if __name__ == "__main__":
	text_clean = lambda t: t.replace("2nd\n", "2nd ").replace("3rd\n", "3rd ").replace("4th\n", "4th ").upper()
	clean_f = lambda t: within_quote_fix(text_clean(t))
	
	data_path = './data'
	if len(sys.argv) > 1:
		data_path = sys.argv[1]
	
	params = read_csv(data_path + "/params.csv")
	input_csv = read_csv(data_path + "/input.csv", True, ',', clean_f)
	const_cols = []
	variable_cols = []
	
	for param in params:
		if param[0].lower().startswith('const'):
			const_cols += param[1:]
		elif not(param[0].startswith('#')) and len(param) > 1:
			variable_cols.append(param[1:])
	transformed_data = []
	transform = to_multilinef(const_cols, *variable_cols)
	seen = set([])
	for row in input_csv:
		try:
			next_rows = transform(row)
			#print(next_rows)
			#print("\n\n")
			for nr in next_rows:
				# NOTE FOR USE IN FUTURE YEARS - This may need modification based on which columns contain blanks.
				if len(filter(lambda x: not(x in ['', ' ']), nr[to_num('A'):to_num('G')])) > 0 and not(str(nr) in seen):
					transformed_data.append(nr)
					seen = seen.union([str(nr)])
		except:
			print(row)
	sorted_data = [transformed_data[0]] + sorted(transformed_data[1:], key=lambda x: x[0])
	write_csv(sorted_data, data_path + '/output.csv')
			
	
