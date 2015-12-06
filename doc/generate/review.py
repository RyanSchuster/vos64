import os

class Function:
	"""Describes a function"""

	def __init__(self, funcName, module):
		self.name = funcName
		self.module = module
		self.depNames = Set()

	def addDep(self, funcName):
		self.depNames.add(funcName)

	def getDepNames(self):
		return self.depNames

class Module:
	"""Describes a module (source/header pair)"""

	def __init__(self, modName):
		self.funcNames = List()
		self.depNames = Set()
		self.name = modName

	def addFunc(self, funcName):
		self.funcs[name] = Function(functionName, self)

	def addDep(self, modName):
		self.depNames.add(modName)

	def getDepNames(self):
		return self.depNames

	def getFuncNames(self):
		return self.funcNames
		



def wut(message):
	#print 'WUT: ' + message
	pass


def parseSource(fileName):
	# TODO: run through YASM preassembler to expand macros first
	funcName = ''
	codeSection = False
	print fileName
	with open(fileName, 'r') as sourceFile:
		for line in sourceFile:
			# separate comments
			commentStart = line.find(';')
			code = line[:commentStart].lstrip().rstrip()
			comment = line[commentStart:]

			# ignore blank lines
			if len(code) == 0:
				continue

			# ignore preassembler macros
			if code[0] == '%':
				continue

			# check for section headers
			if 'section ' in code:
				if (' .text' in code) or (' exec' in code):
					codeSection = True
				else:
					codeSection = False

			if codeSection:
				# check for labels
				if code[-1:] == ':':
					# check for global labels
					if code[0] != '.':
						funcName = code[:-1]

				# not a label, check for call instruction
				keywords = code.split()
				if keywords[0] == 'call':
					print '"%s" calls "%s"' % (funcName, keywords[1])


# dicts of funcs and mods

funcs = Dict()
mods = Dict()


# begin scanning source tree

for dirName, subdirList, fileList in os.walk('.'):
	for fileName in fileList:
		# warn about gedit temp files
		if fileName[-1:] == '~':
			wut('file possibly open in gedit: "%s"' % (dirName + '/' + fileName[:-1]))
			continue

		# warn about vim swap files
		if fileName[-4:] == '.swp':
			wut('file currently open in vim: "%s"' % (dirName + '/' + fileName[1:-4]))
			continue

		# warn about non-include files in /inc
		if dirName[0:5] == './inc/':
			if fileName[-2:] != '.h':
				wut('non-include file in /inc: "%s"' % (dirName + '/' + fileName))

		# warn about non-source files in /src
		if dirName[0:5] == './src/':
			if fileName[-4:] != '.asm':
				wut('non-source file in /src: "%s"' % (dirName + '/' + fileName))

		# check for include files
		if fileName[-2:] == '.h':
			if dirName[0:5] != './inc':
				wut('include file not in /inc: "%s"' % (dirName + '/' + fileName))

		# check for source files
		if fileName[-4:] == '.asm':
			if dirName[0:5] != './src':
				wut('source file not in /src: "%s"' % (dirName + '/' + fileName))
			parseSource((dirName + '/' + fileName))
