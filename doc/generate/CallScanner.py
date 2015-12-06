import CodeMap


class CallScanner:
	# scanner states
	S_NONE = 0
	S_CODESECTION = 1

	def __init__(self, codeMap):
		self.codeMap = codeMap
		self.reset()

	def reset():
		self.state = S_NONE
		self.currentFile = ''
		self.currentFunc = ''

	def scanLine(self, fileName, lineNum, line):
		# reset state machine on new file
		if fileName != self.currentFile:
			self.reset()
			self.currentFile = fileName

		# separate comments
		commentStart = line.find(';')
		code = line[:commentStart].lstrip().rstrip()
		comment = line[commentStart:]

		# ignore blank lines
		if len(code) == 0:
			return

		# ignore preassembler macros
		if code[0] == '%':
			return

		# check for section headers
		if 'section ' in code:
			if (' .text' in code) or (' exec' in code):
				self.state = S_CODESECTION
			else:
				self.state = S_NONE

		if self.state = S_CODESECTION:
			# check for labels
			if code[-1:] == ':':
				# check for global labels
				if code[0] != '.':
					self.currentFunc = code[:-1]

			# not a label, check for call instruction
			keywords = code.split()
			if keywords[0] == 'call':
				pass
				# add dependency
				
				#thisFunc.addDep(keywords[1])
