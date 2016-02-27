# A list of utility functions.

# Read a single data path (if app info configures this way).
def read_data_path(app_info_path):
	file = open(app_info_path, 'r')
	for line in file:
		clean_line = line.strip()
		if not(clean_line.startswith('#')):
			return clean_line
	return None

# For a given app_info_path, get out the parameters	as a dict.
def read_params(app_info_path, sep = ':'):
	file = open(app_info_path, 'r')
	params = {}
	for line in file:
		parts = filter(lambda x: not(x in [None, '', ' ', "\t"]), 
								 map(lambda y: y.strip(), line.split(sep)))
		if len(parts) > 1 and not(parts[0].startswith('#')):
			params[parts[0]] = parts[1]
	return params

# Print a JSON/dict data set to CSV. Attributes = columns, default is all attributes.	
def to_csv(data_points, filename, columns=None):
	if columns == None:
		columns = list(set(reduce(lambda x,y: x + y, map(lambda z: z.keys(), data_points) + [])))
	data = [map(lambda x: str(x), columns)]
	for point in data_points:
		line = []
		for column in columns:
			val = str(point[column]) if column else ''
			line.append(val)
		data.append(line)
	text = "\n".join(map(lambda line: ','.join(line), data))
	print('Writing file: ' + filename + '...')
	out_file = open(filename, "w")
	out_file.write(text)
	out_file.close()
	print('Done!')