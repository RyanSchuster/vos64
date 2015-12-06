class ReviewScanner:
	# scanner states
	S_NONE = 0

	def __init__(self):
		self.state = S_NONE
		self.currentFile = ''

	def scanLine(self, fileName, lineNum, line):
		if fileName != self.currentFile:
			self.state = S_NONE
			self.currentFile = fileName

		# perform code style/formatting review
		pass
