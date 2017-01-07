from csv_util import *
from cmd_util import *
import sys

print(sys.argv)

params = read_params("tmp.csv")
print(params)

a1 = ['test.py', '-a', '3', '-b', '5:10', '-c', 'True']
a2 = ['--abc', 'def' 'ghi', '.\\test.py', '-a', '3', '-b', '5:10', '-c', 'True']
print(read_cmd_params(a1))
print(read_cmd_params(a2, 'test.py'))