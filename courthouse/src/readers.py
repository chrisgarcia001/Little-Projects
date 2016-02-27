# This contains some basic readers for different courthouse data spreadsheets.

import xlrd
import os
from datetime import datetime

# All FileReader classes implement these methods: 1) set_path(path), 2) get_data_points():[data points]
# Additionally, all FileReaders should take the file_path as the first constructor argument.

# This class reads a single point sheet data spreadsheet.
class PointSheetReader(object):
	def __init__(self, file_path=None):
		if file_path != None:
			self.set_path(file_path)
	
	def row_index(self, sheet, column, text_value_prefix):
		for row in range(sheet.nrows):
			if str(sheet.cell(row, column).value).strip().lower().startswith(text_value_prefix.strip().lower()):
				return row
		return -1
	
	def set_path(self, file_path):
		self.file_path = file_path
		
	def get_data_points(self):
		ss = xlrd.open_workbook(self.file_path)
		sheet_names = ss.sheet_names()
		data_points = []
		teacher = None
		raw_date = None
		day, month, year = -1, -1, -1
		for student in sheet_names:
			try:
				sheet = ss.sheet_by_name(student)
				#teacher = sheet.cell(2,2).value
				#raw_date = sheet.cell(7,2).value
				if teacher == None:
					try:
						teacher_row = self.row_index(sheet, 1, "Teacher")
						teacher = sheet.cell(teacher_row, 2).value
					except:
						print("Error extracting teacher: " + str((student, file_path)))
				if raw_date == None:
					try:
						date_row = self.row_index(sheet, 1, "Date")
						raw_date = sheet.cell(date_row,2).value
						py_date = xlrd.xldate.xldate_as_datetime(raw_date, ss.datemode)
						day, month, year = py_date.day, py_date.month, py_date.year
					except:
						print("Error extracting raw date: " + str((student, file_path)))
				academic_total = float(sheet.cell(32,7).value)
				behavior_total = float(sheet.cell(32,8).value)
				data_point = {'student':str(student), 'teacher':str(teacher), 
							  'academic_total':academic_total, 'behavior_total':behavior_total}
				data_points.append(data_point)
			except:
				print("Error extracting student: " + str((student, self.file_path)))
		for dp in data_points:
					dp['day'] = int(day) 
					dp['month'] = int(month)
					dp['year'] = int(year)
					dp['date'] = str(day) + '/' + str(month) + '/' + str(year)
		return data_points

# This class reads a single attendance data spreadsheet.
class AttendanceSheetReader(object):
	def __init__(self, file_path=None):
		if file_path != None:
			self.set_path(file_path)
	
	def set_path(self, file_path):
		self.file_path = file_path
	
	def parse_month(self, month):
		month_abvs = {"jan":1, "feb":2, "mar":3, "apr":4, "may":5, "jun":6,
		              "jul":7, "aug":8, "sep":9, "oct":10, "nov":11, "dec":12}
		for m in month_abvs.keys():
			if str(month).lower().startswith(m):
				return month_abvs[m]
		return int(month)
	
	def get_data_points(self):
		ss = xlrd.open_workbook(self.file_path)
		sheet_names = ss.sheet_names()
		data_points = []
		month, year = -1, -1
		for month in sheet_names:
			sheet = ss.sheet_by_name(month)
			try:
				month = self.parse_month(sheet.cell(1, 28).value)
				year = sheet.cell(2, 28).value
			except:
				month = self.parse_month(sheet.cell(1, 29).value)
				year = int(sheet.cell(2, 29).value)
			print((month, year))
			# TODO - Pick Up Here!!!
		return data_points
		
		
# This applies a FileReader class to individual files at a specified nested depth. 
# A depth of 0 is the same as the folder path specified, 1 is 1 level below, etc.
# The file_reader_class is the type of FileReader class. Additionally, file extensions
# may optionally be specified.		
class FolderReader:
	def __init__(self, folder_path, file_reader_class, level=0, file_ext=None):
		self.set_path(folder_path)
		self.file_reader = file_reader_class
		self.level = level
		self.file_ext = file_ext
	
	# Set the path
	def set_path(self, folder_path):
		self.path = folder_path
	
	# List all file names within this directory
	def get_file_names(self):
		onlyfiles = [f for f in os.listdir(self.path) if os.path.isfile(os.path.join(self.path, f))]
		if self.file_ext != None:
			onlyfiles = filter(lambda x: x.ends_with(self.file_ext), onlyfiles)
		return onlyfiles
	
	# List all subdirectory names within this directory
	def get_subdir_names(self):
		return [f for f in os.listdir(self.path) if os.path.isdir(os.path.join(self.path, f))]
	
	# Get the data points, using the specified file_reader_class
	def get_data_points(self):
		if self.level == 0:
			dp = lambda filename: self.file_reader(self.path + "/" + filename).get_data_points()
			def dps(filename):
				try:
					print(self.path + "/" + filename)
					return dp(filename)
				except: 
					return []
			return reduce(lambda x,y: x + y, map(dp, self.get_file_names()) + [])
		elif str(self.level).lower() == 'leaves':
			if len(self.get_subdir_names()) == 0:
				fr = FolderReader(self.path, self.file_reader, level=0, file_ext=self.file_ext)
				return fr.get_data_points()
			else:
				dp = lambda dirname: FolderReader(self.path + "/" + dirname, self.file_reader, level="leaves", file_ext=self.file_ext).get_data_points()
				return reduce(lambda x,y: x + y, map(dp, self.get_subdir_names()) + [])
		else:
			dp = lambda dirname: FolderReader(self.path + "/" + dirname, self.file_reader, level=self.level - 1, file_ext=self.file_ext).get_data_points()
			return reduce(lambda x,y: x + y, map(dp, self.get_subdir_names()) + [])
			
			
		
		
			
