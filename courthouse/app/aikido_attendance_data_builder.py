from os import sys
sys.path.insert(0, '../lib/')
from readers import *
from util import *

params = read_params('../app_info.txt', '=')
aikido_attendance_path = params['aikido_attendence_data_path']
output_path = params['output_path']
level = 'leaves'

fr = FolderReader(aikido_attendance_path, AikidoAttendenceDataReader, level)
points = fr.get_data_points()
#print(points)
to_csv(points, output_path + '/' +'aikido-attendance-data.csv')