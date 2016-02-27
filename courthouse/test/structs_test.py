from os import sys
sys.path.insert(0, '../src/')
from readers import *
from util import *

params = read_params('../app_info.txt', '=')
path = params['point_sheet_path']
level = 'leaves'

fr = FolderReader(path, PointSheetReader, level)
print(fr.get_data_points())