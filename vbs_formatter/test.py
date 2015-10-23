from csv_util import *
from vbs_formatter import *

print(to_num('c')) # 3
print(to_num('AB')) # 28

#print(read_csv('data/music-sales.csv'), False)
#write_csv(read_csv('data/music-sales.csv'), 'data/copy.csv')
print(col_indices(1,3,'AB','C-h'))

data = 'abcdefghijklmnopqrstuvwxyz'
f = to_multilinef(['D-G', 'K'], *[['P-S', 'U-V'], ['x-z']])
print(f(data))

bad_data = [['A', 'B,C,D'],['X','Y']]
write_csv(bad_data, 'bad_data.csv')
