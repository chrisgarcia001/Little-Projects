# This contains some basic readers for different courthouse data spreadsheets.

import xlrd
import os
from datetime import datetime

# --------------------- UTILITY FUNCTIONS -------------------------------------------------

# Get (row, column) indices of all cells matching the specified criteria function
# sheet: A worksheet within a spreadsheet
# criteria_f: val -> True | False
def find_cells(sheet, match_val):#critera_f):
	cells = []
	#print("-------DIM: " + str((sheet.nrows, sheet .ncols)))
	for row in range(sheet.nrows):
		for col in range(sheet.ncols):
			try:
				# if not(str(sheet.cell(row, col).value) in ['', ' ', None]):
					# print(str((row, col)) + str(sheet.cell(row, col).value))
				#if(criteria_f(sheet.cell(row, col).value)):
				if str(sheet.cell(row, col).value).lower() == str(match_val).lower():
					#print((row, col))
					cells.append((row, col))
			except:
				pass
	return cells

# --------------------- READERS -----------------------------------------------------------
# All FileReader classes implement these methods: 1) set_path(path), 2) get_data_points():[data points]
# Additionally, all FileReaders should take the file_path as the first constructor argument.

# This class reads a single point sheet data spreadsheet.
# class PointSheetReader(object):
	# def __init__(self, file_path=None):
		# if file_path != None:
			# self.set_path(file_path)
	
	# def row_index(self, sheet, column, text_value_prefix):
		# for row in range(sheet.nrows):
			# if str(sheet.cell(row, column).value).strip().lower().startswith(text_value_prefix.strip().lower()):
				# return row
		# return -1
	
	# def set_path(self, file_path):
		# self.file_path = file_path
		
	# def get_data_points(self):
		# ss = xlrd.open_workbook(self.file_path)
		# sheet_names = ss.sheet_names()
		# data_points = []
		# teacher = None
		# raw_date = None
		# day, month, year = -1, -1, -1
		# for student in sheet_names:
			# try:
				# sheet = ss.sheet_by_name(student)
				##teacher = sheet.cell(2,2).value
				##raw_date = sheet.cell(7,2).value
				# if teacher == None:
					# try:
						# teacher_row = self.row_index(sheet, 1, "Teacher")
						# teacher = sheet.cell(teacher_row, 2).value
					# except:
						# print("Error extracting teacher: " + str((student, file_path)))
				# if raw_date == None:
					# try:
						# date_row = self.row_index(sheet, 1, "Date")
						# raw_date = sheet.cell(date_row,2).value
						# py_date = xlrd.xldate.xldate_as_datetime(raw_date, ss.datemode)
						# day, month, year = py_date.day, py_date.month, py_date.year
					# except:
						# print("Error extracting raw date: " + str((student, file_path)))
				# academic_total = float(sheet.cell(32,7).value)
				# behavior_total = float(sheet.cell(32,8).value)
				# data_point = {'student':str(student), 'teacher':str(teacher), 
							  # 'academic_total':academic_total, 'behavior_total':behavior_total}
				# data_points.append(data_point)
			# except:
				# print("Error extracting student: " + str((student, self.file_path)))
		# for dp in data_points:
					# dp['day'] = int(day) 
					# dp['month'] = int(month)
					# dp['year'] = int(year)
					# dp['date'] = str(month) + '/' + str(day) + '/' + str(year)
		# return data_points

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
		#prefix_f = lambda x: lambda y: str(y).strip().lower().startswith(str(x).strip().lower())
		for student in sheet_names:
			try:
				sheet = ss.sheet_by_name(student)
				# if teacher == None:
					# try:
						# print(find_cells(sheet, "Teacher"))
						# #(row, col) = find_cells(sheet, prefix_f("Teacher"))[0]
						# #print(row, col)
						# #teacher_row = self.row_index(sheet, 1, "Teacher")
						# #teacher = sheet.cell(teacher_row, 2).value
						# teacher = sheet.cell(row, col + 1).value
					# except:
						# print("Error extracting teacher: " + str((student, file_path)))
				if raw_date == None:
					try:
						#date_row = self.row_index(sheet, 1, "Date")
						(row, col) = find_cells(sheet, "Date")[0]
						print(" ---- Date: " + str((row, col)))
						#raw_date = sheet.cell(date_row,2).value
						raw_date = sheet.cell(row, col + 1).value
						py_date = xlrd.xldate.xldate_as_datetime(raw_date, ss.datemode)
						day, month, year = py_date.day, py_date.month, py_date.year
					except:
						print("Error extracting raw date: " + str((student, file_path)))
				academic_total = 0
				behavior_total = 0
				try:
					totals = find_cells(sheet, "Total")	
					(a_row, a_col) = totals[0]
					(b_row, b_col) = totals[1]
					#academic_total = float(sheet.cell(32,7).value)
					#behavior_total = float(sheet.cell(32,8).value)
					academic_total = float(sheet.cell(a_row + 1, a_col).value)
					behavior_total = float(sheet.cell(b_row + 1, b_col).value)
					if academic_total in ['', ' ', None]:
						academic_total = 0
					if behavior_total in ['', ' ', None]:
						behavior_total = 0
				except:
					pass
				data_point = {'student':str(student), 'teacher':str(teacher), 
							  'academic_total':academic_total, 'behavior_total':behavior_total}
				data_points.append(data_point)
			except:
				print("Error extracting student: " + str((student, self.file_path)))
		for dp in data_points:
					dp['day'] = int(day) 
					dp['month'] = int(month)
					dp['year'] = int(year)
					dp['date'] = str(month) + '/' + str(day) + '/' + str(year)
		return data_points

		
# This class reads a single (school) attendance data spreadsheet.
class AttendanceSheetReader(object):
	def __init__(self, file_path=None):
		if file_path != None:
			self.set_path(file_path)
	
	def set_path(self, file_path):
		self.file_path = file_path
	
	# Parse a month into integer format, whether starts in full, abbreviated, or integer format.
	def parse_month(self, month):
		month_abvs = {"jan":1, "feb":2, "mar":3, "apr":4, "may":5, "jun":6,
		              "jul":7, "aug":8, "sep":9, "oct":10, "nov":11, "dec":12}
		for m in month_abvs.keys():
			if str(month).lower().startswith(m):
				return month_abvs[m]
		return int(month)
	
	# Parse a name into first and last.
	def parse_name(self, name):
		name = name.strip()
		if name.lower().startswith('courthouse') or name.lower().startswith('student'):
			return None
		if ',' in name:
			names = map(lambda x: x.strip(), filter(lambda y: not(y in ['', None, ' ']), name.split(',')))
			return({'first':names[1], 'last':names[0]})
		else:
			names = map(lambda x: x.strip(), filter(lambda y: not(y in ['', None, ' ']), name.split(' ')))
			if len(names) == 2:
				return({'first':names[0], 'last':names[1]})
			return None
	
	def get_data_points(self):
		ss = xlrd.open_workbook(self.file_path)
		sheet_names = ss.sheet_names()
		data_points = []
		for sn in sheet_names:
			month, year = -1, -1
			sheet = ss.sheet_by_name(sn)
			try:
				month = self.parse_month(sheet.cell(1, 28).value)
				year = int(sheet.cell(2, 28).value)
			except:
				month = self.parse_month(sheet.cell(1, 29).value)
				year = int(sheet.cell(2, 29).value)
			for row in range(sheet.nrows):
				name = self.parse_name((str(sheet.cell(row, 1).value)))
				if name != None:
					tardy, absent, suspend = 0, 0, 0
					for col in range(2, sheet.ncols):
						try:
							val = str(sheet.cell(row, col).value).strip().lower()
							if val.startswith('t'):
								tardy += 1
							if val == 'a':
								absent += 1
							if val == 's':
								suspend += 1
						except:
							None
					data_points.append({'first_name':name['first'], 'last_name':name['last'], 'month':month,
										'year':year, 'tardy':tardy, 'absent':absent, 'suspend':suspend})
					
		return data_points

# This class reads a single Aikido attendance data spreadsheet.		
class AikidoAttendenceDataReader(object):
	def __init__(self, file_path=None):
		if file_path != None:
			self.set_path(file_path)
			self.ss = xlrd.open_workbook(self.file_path)
		self.sheet = self.ss.sheet_by_name("Cumulative Attendance")
	
	def set_path(self, file_path):
		self.file_path = file_path
	
	def get_col_key_dates(self):
		sheet = self.sheet
		dates = {} # column:date
		for col in range(1, sheet.ncols):
			try:
				raw_date = sheet.cell(0, col).value
				py_date = xlrd.xldate.xldate_as_datetime(raw_date, self.ss.datemode)
				day, month, year = py_date.day, py_date.month, py_date.year
				dates[col] = str(month) + "/" + str(day) + "/" + str(year)
			except:
				print("Non-date...")
		return dates
		
	def get_names_with_dates(self, start_at_row = 0, process_name_f = lambda x: x):
		sheet = self.sheet
		dates = self.get_col_key_dates()
		data_points = []
		for row in range(start_at_row, sheet.nrows):
			try:
				name = process_name_f(str(sheet.cell(row, 0).value).strip())
				for col in range(1, sheet.ncols):
					try:
						if sheet.cell(row, col).value in [1, 1.0, "1"]:
							data_points.append({"Name":name, "Date":dates[col]})
					except:
						print("Skipping (rw, col): " + str(row, col))
			except:
				print("Skipping row: " + str(row))
		return data_points
		
		
	def get_data_points(self):
		firstname_f = lambda x: filter(lambda y: not(y in ['', ' ', None]), x.strip().split(' '))[0]
		return self.get_names_with_dates(0, process_name_f = firstname_f)
		

		
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
			
			
		
		
			
