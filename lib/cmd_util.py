# -----------------------------------------------------------------------------
# Author: cgarcia
# About: This is a small set of functions for working with command line args.
# -----------------------------------------------------------------------------

import csv_util as cv

# Reads in a set of params from the command line (passed in as a list).
# The arguments are as follows:
#    cmd_args: A list of command line input (can come directly from sys.argv)
#    mainfile_suffix: The name of the main python file (optional - if it is not the first argument)
#    key_prefix: The prefix designating parameter keys (e.g. -param means the '-' is the key prefix)
#    input_evaluator_f: A function that parses a string input parameter into its appropriate value
# Finally, this assumes each param key specified has exactly one corresponding value.
# Example: cmd_args = ['test.py', '-param1', 'xyz', '-param2', '64', '-param3', '5:10'] will give the following 
#          output, assuming the default input_evaluator_f: {'param1': 'xyz', 'param2':64, 'param3':[5,10]}
def read_cmd_params(cmd_args, mainfile_suffix=None, key_prefix='-', input_evaluator_f=cv.standard_eval_input):
	ref = 0
	if mainfile_suffix != None:
		while ref < len(cmd_args) and not(cmd_args[ref].endswith(mainfile_suffix)):
			ref += 1
	inds = range(ref, len(cmd_args))
	key_inds = filter(lambda i: cmd_args[i].startswith(key_prefix), inds)
	keys = map(lambda x: x[len(key_prefix):], map(lambda y: cmd_args[y], key_inds))
	vals = map(lambda x: input_evaluator_f(cmd_args[x + 1]), key_inds)
	return dict(zip(keys, vals))