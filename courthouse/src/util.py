# A list of utility functions.

def read_data_path(app_info_path):
	file = open(app_info_path, 'r')
	for line in file:
		clean_line = line.strip()
		if not(clean_line.startswith('#')):
			return clean_line
	return None