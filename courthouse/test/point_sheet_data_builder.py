from os import sys
sys.path.insert(0, '../src/')
from readers import *
from util import *

path = read_data_path('../app_info.txt')
level = 2

fr = FolderReader(path, PointSheetReader, level)
points = fr.get_data_points()
to_csv(points, 'point-sheet-data.csv')