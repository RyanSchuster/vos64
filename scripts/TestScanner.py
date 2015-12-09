class TestScanner:
	def __init__(self, sourceScanner):
		sourceScanner.SetCallback('newfile', self.CBNewFile)
		sourceScanner.SetCallback('preasm', self.CBPreasm)
		sourceScanner.SetCallback('label', self.CBLabel)
		sourceScanner.SetCallback('section', self.CBSection)
		sourceScanner.SetCallback('code', self.CBCode)
		sourceScanner.SetCallback('comment', self.CBComment)

	def CBNewFile(self, dummy, pathname):
		print('newfile: ' + pathname)
		pass

	def CBPreasm(self, linenum, preasmline):
		pass

	def CBLabel(self, linenum, labelname):
		print('label: ' + labelname)
		pass

	def CBSection(self, linenum, sectionname):
		print('section: ' + sectionname)
		pass

	def CBCode(self, linenum, codeline):
		pass

	def CBComment(self, linenum, commenttext):
		print('comment: ' + commenttext)
		pass
