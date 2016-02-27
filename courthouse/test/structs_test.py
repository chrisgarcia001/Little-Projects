from os import sys
sys.path.insert(0, '../lib/')
from readers import *
from util import *

params = read_params('../app_info.txt', '=')
point_sheet_path = params['point_sheet_input_path']
level = 'leaves'

#fr = FolderReader(point_sheet_path, PointSheetReader, level)
#print(fr.get_data_points())

attendance_sheet_path = params['attendance_sheet_input_path']
fr = FolderReader(attendance_sheet_path, AttendanceSheetReader, level)
print(fr.get_data_points())