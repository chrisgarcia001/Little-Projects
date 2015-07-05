# -----------------------------------------------------------------------------
# Author: cgarcia
# About: This is a small set of functions for working with CSV's
# -----------------------------------------------------------------------------

# Convert an excel-style column to an int (e.g. "C" = 3, "AB" = 28)
def to_num(alpha_str):
	try:
		return int(alpha_str) - 1
	except:
		pass
	alpha_str = alpha_str.lower()
	pow = 0
	total = 0
	alpha = 'abcdefghijklmnopqrstuvwxyz'
	inds = range(len(alpha_str))
	inds.reverse()
	for i in inds:
		total += (alpha.index(alpha_str[i]) + 1) * (26 ** pow)
		pow += 1
	return total - 1 # Adjust to 0-based index

# For a list of column numbers (in 1-index numeric or alphabetical format), get
# a corresponding set of a python array indices.
def col_indices(*columns):
	inds = []
	for c in columns:
		cols = filter(lambda x: len(x) > 0, filter(lambda y: y != ' ', str(c)).split('-'))
		if len(cols) == 1:
			inds.append(to_num(cols[0]))
		elif len(cols) > 1:
			inds += range(to_num(cols[0]), to_num(cols[1]) + 1)
	return inds
	
# Write a text file	
def write_file(text, filename):
	f = open(filename, "w")
	f.write(text)
	f.close()
	
# Reads a CSV as a list of rows	
def read_csv(filename, include_headers = True, sep = ',', cleanf = lambda x: x):
	fl = open(filename)
	txt = cleanf(fl.read())
	lines = fl.readlines()
	lines = []
	start_pos = 0 if include_headers else 1
	lines = map(lambda y: y.strip(), txt.split("\n"))[start_pos:]
	return map(lambda x: x.split(sep), lines)
	
# Writes a matrix (2D list) to a CSV file.
def write_csv(matrix, filename, sep = ','):
	text = reduce(lambda x,y: x + "\n" + y, map(lambda row: sep.join(row), matrix))
	write_file(text, filename)
	
# Constructs a function which will extract values in a single array
# into multiple arrays. Constant columns will appear in every output array,
# paired with a separate column set in each output. Used to transform lines.
# Example: data = 'abcdefghijklmnopqrstuvwxyz'
#                 f = to_multilinef(['D-G', 'K'], ['P-S', 'U-V'], ['m-o'])
#                 f(data)
#  -->    [['p', 'q', 'r', 's', 'u', 'v', 'd', 'e', 'f', 'g', 'k'], 
#          ['m', 'n', 'o', 'd', 'e', 'f', 'g', 'k']]
def to_multilinef(constant_cols, *col_sets):
	fixed = col_indices(*constant_cols)
	lines = map(lambda cs: col_indices(*cs) + fixed, col_sets)
	return lambda data: map(lambda line: [data[i] for i in line], lines)
	

