import CodeMap


class DocScanner:
	# scanner states
	S_NONE = 0
	S_MOD = 1
	S_FUNC = 2

	# substates
	S_BRIEF = 3
	S_DETAIL = 4
	S_INPUTS = 5
	S_OUTPUTS = 6

	# more substates
	S_TEXT = 7

	def __init__(self, codeMap):
		self.codeMap = codeMap
		self.reset()

	def reset(self):
		self.state = S_NONE
		self.subState = S_NONE
		self.subSubState = S_NONE
		self.currentFile = ''	# here to reset state on new file
		self.currentMod = ''
		self.currentFunc = ''
		self.currentText = ''

	def scannerText(self, docLine):
		if self.subSubState == S_TEXT:
			if len(docLine) == 0:
				self.subSubState = S_NONE
			else:
				self.currentText = self.currentText + docLine
		else:
			self.currentText = ''

	def scannerBlock(self, line):
		commentStart = line.find(';;')

		if commentStart == -1:
			self.subState = S_NONE
			docLine = ''
		else:
			docLine = line[commentStart + 1].lstrip().rstrip()

		scannerText(docLine)
		if self.subSubState = S_NONE
		pass

	def scannerFile(self, docLine):
		pass

	def scanLine(self, fileName, lineNum, line):
		# only scan source and header files
		if fileName[-4:] != '.asm' and fileName[-2:] != '.h':
			self.reset()
			return

		# reset state machine on new file
		if fileName != self.currentFile:
			self.reset()
			self.currentFile = fileName

		# reset state machine when not in a double commented block
		commentStart = line.find(';;')
		if commentStart == -1:
			self.reset()
			return

		# get the line from the docblock
		docLine = line[commentStart + 1:].lstrip().rstrip()
		#if len(docLine) == 0:
		#	continue

		# scanner state machine
		keywords = docLine.split()
		if self.state == S_NONE:
			if keywords[0] == 'module:':
				# scanning a module doc
				self.state = S_MOD
				self.subState = S_NONE
				self.currentMod = keywords[1]
				print 'DocScanner: modblock "' + keywords[1] + '"'
			elif keywords[0] == 'function:':
				# scanning a function doc
				state = S_FUNC
				self.subState = S_NONE
				self.currentFunc = keywords[1]
				print 'DocScanner: funcblock "' + keywords[1] + '"'
			else
				print 'DocScanner: unrecognized keyword "' + keywords[0] + '"'
		elif state == S_MOD:
			if keywords[0] == 'brief:':
				# brief (single-line) description of a module
				self.codeMap.addModBrief(self.currentMod, )
		elif state == S_FUNC:
			pass
