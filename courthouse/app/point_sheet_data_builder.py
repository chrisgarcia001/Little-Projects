from os import sys
sys.path.insert(0, '../lib/')
from readers import *
from util import *

params = read_params('../app_info.txt', '=')
input_path = params['point_sheet_input_path']
output_path = params['output_path']
level = 'leaves'

fr = FolderReader(input_path, PointSheetReader, level)
points = fr.get_data_points()
#print(points)
to_csv(points, output_path + '/' +'point-sheet-data.csv')