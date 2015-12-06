class AsmScanner:
	CALLBACK_NEWFILE = "newfile"	# started scanning a new file
	CALLBACK_LABEL = "label"	# label is scanned
	CALLBACK_SECTION = "section"	# section name is scanned
	CALLBACK_CODE = "code"		# a line of code is scanned
	CALLBACK_COMMENT = "comment"	# a comment is scanned

	# callbacks take two arguments: line number, text string

	def __init__(self):
		callbacks = dict()

	def SetCallback(self, name, function):
		callbackList = self.callbacks.get(name)
		if callbackList == None:
			self.callbackList[name] = list()
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
		labelEnd = line.find(':')
		if labelEnd >= commentStart
			labelEnd = 0

		label = line[:labelEnd].lstrip().rstrip()
		code = line[labelEnd:commentStart].lstrip().rstrip()
		comment = line[commentStart:].lstrip().rstrip()
		preassembler = ""
		if line[0] == '%':
			code = ""
			preassembler = line

		# call appropriate callbacks
		if label:
			self.CallCallback(CALLBACK_LABEL, linenum, label)
		if preassmbler:
			self.CallCallback(CALLBACK_PREASM, linenum, preassembler)
		if section:
			self.CallCallback(CALLBACK_SECTION, linenum, section)
		if code:
			self.CallCallback(CALLBACK_CODE, linenum, code)
		if comment:
			self.CallCallback(CALLBACK_COMMENT, linenum, comment)

	def ScanFile(self, path):
		self.CallCallback(CALLBACK_NEWFILE, 0, path)
		with open(source) as f:
			for linenum, line in enumerate(f):
				self.ScanLine(linenum, line)

	def ScanDir(self, rootpath):
		for dirname, subdirlist, filelist in os.walk(rootpath):
			for filename in filelist:
				if filename[-4:] != '.asm' && filename[-2:] != '.h':
					continue
				path = dirname + '/' + filename
				self.ScanFile(path)


class CallParser:
	def __init__(self):
		pass


class DocParser:
	def __init__(self):
		pass


class StyleParser:
	def __init__(self):
		pass


class DebugParser:
	def __init__(self, scanner):
		scanner.SetCallback(scanner.CALLBACK_NEWFILE, self.Newfile)
		scanner.SetCallback(scanner.CALLBACK_LABEL, self.Label)
		scanner.SetCallback(scanner.CALLBACK_SECTION, self.Section)
		scanner.SetCallback(scanner.CALLBACK_CODE, self.Code)
		scanner.SetCallback(scanner.CALLBACK_COMMENT, self.Comment)

	def Newfile(self, linenum, line):
		pass

	def Label(self, linenum, line):
		pass

	def Section(self, linenum, line):
		pass

	def Code(self, linenum, line):
		pass

	def Comment(self, linenum, line):
		pass
