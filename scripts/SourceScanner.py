# This is a really quick and dirty scanner - no attempt was made (or likely ever
# will be made) to make this code pretty.  For now, it just needs to work for
# the sake of making the *rest* of the code (and its documentation) pretty.
# Gotta start somewhere.


import os
import re

class SourceScanner:
	CALLBACK_NEWFILE = 'newfile'	# started scanning a new file
	CALLBACK_LABEL = 'label'	# label is scanned
	CALLBACK_PREASM = 'preasm'	# preassembler macro
	CALLBACK_SECTION = 'section'	# section name is scanned
	CALLBACK_GLOBAL = 'global'	# label was marked as global
	CALLBACK_CODE = 'code'		# a line of code is scanned
	CALLBACK_COMMENT = 'comment'	# a comment is scanned

	# callbacks take two arguments: line number, some text string

	# newfile callback:	0, filepath
	# label callback:	line, labelname
	# section callback:	line, [sectionname, attr, attr, ...]
	# code callback:	line, codeline
	# comment callback:	line, commenttext

	def __init__(self):
		self.callbacks = dict()

	def SetCallback(self, name, function):
		callbackList = self.callbacks.get(name)
		if callbackList == None:
			self.callbacks[name] = list()
		self.callbacks[name].append(function)

	def CallCallback(self, name, linenum, line):
		callbackList = self.callbacks.get(name)
		if callbackList == None:
			return
		for callback in callbackList:
			callback(linenum, line)

	def ScanLine(self, linenum, line):
		# separate labels, code, preassembler directives, and comments
		commentStart = line.find(';')
		if commentStart < 0:
			commentStart = len(line)
			isComment = False
		else:
			isComment = True
		labelEnd = line.find(':')
		if labelEnd < 0:
			labelEnd = 0
		if labelEnd >= commentStart:
			labelEnd = 0

		label = line[:labelEnd].lstrip().rstrip()
		# Try to rule out any accidental code
		if ('"' in label) or ("'" in label) or ('\t' in label) or (' ' in label):
			label = ''
		code = line[labelEnd:commentStart].lstrip().rstrip()
		comment = line[commentStart + 1:].lstrip().rstrip()
		preassembler = ''
		if line[0] == '%':
			code = ''
			preassembler = line

		# TODO: sections?
		section = ''
		extern = ''
		words = re.findall(r"[\w']+", code)
		if len(words) > 0:
			if words[0] == 'section':
				code = ''
				section = words[1:]
			if words[0] == 'extern':
				code = ''
				extern = words[1]

		# call appropriate callbacks
		if label:
			self.CallCallback(self.CALLBACK_LABEL, linenum, label)
		if preassembler:
			self.CallCallback(self.CALLBACK_PREASM, linenum, preassembler)
		if section:
			self.CallCallback(self.CALLBACK_SECTION, linenum, section)
		if extern:
			self.CallCallback(self.CALLBACK_GLOBAL, linenum, extern)
		if code:
			self.CallCallback(self.CALLBACK_CODE, linenum, code)
		if isComment:
			self.CallCallback(self.CALLBACK_COMMENT, linenum, comment)

	def ScanFile(self, path):
		self.CallCallback(self.CALLBACK_NEWFILE, 0, path)
		with open(path) as f:
			for linenum, line in enumerate(f):
				self.ScanLine(linenum, line)

	def ScanDir(self, rootpath):
		for dirname, subdirlist, filelist in os.walk(rootpath):
			for filename in filelist:
				if filename[-4:] != '.asm' and filename[-4:] != '.inc':
					continue
				path = dirname + '/' + filename
				self.ScanFile(path)
