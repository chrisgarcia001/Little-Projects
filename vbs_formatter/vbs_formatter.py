# -----------------------------------------------------------------------------
# Author: cgarcia
# About: This is a small program to transform spreadsheets from Google Forms
#        NLICC Vacation Bible School registration into more organized format.
# -----------------------------------------------------------------------------

from csv_util import *

if __name__ == "__main__":
	text_clean = lambda t: t.replace("2nd\n", "2nd ").replace("3rd\n", "3rd ").replace("4th\n", "4th ").upper()

	params = read_csv("./data/params.csv")
	input_csv = read_csv("input.csv", True, ',', text_clean)
	const_cols = []
	variable_cols = []
	
	for param in params:
		if param[0].lower().startswith('const'):
			const_cols += param[1:]
		elif not(param[0].startswith('#')) and len(param) > 1:
			variable_cols.append(param[1:])
	print(const_cols)
	print(variable_cols)
	transformed_data = []
	transform = to_multilinef(const_cols, *variable_cols)
	seen = set([])
	for row in input_csv:
		try:
			next_rows = transform(row)
			for nr in next_rows:
				if len(filter(lambda x: not(x in ['', ' ']), nr[to_num('A'):to_num('H')])) > 0 and not(str(nr) in seen):
					transformed_data.append(nr)
					seen = seen.union([str(nr)])
		except:
			print(row)
	sorted_data = [transformed_data[0]] + sorted(transformed_data[1:], key=lambda x: x[0])
	write_csv(sorted_data, 'output.csv')
			
	
