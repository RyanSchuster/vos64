import collections


# Represents a code module
class Module:
	def __init__(self):
		self.callees = set()
		self.callers = set()
		self.functions = set()
		self.brief = ''
		self.detail = ''

	def AddCaller(self, callerName):
		self.callers.add(callerName)

	def AddCallee(self, calleeName):
		self.callees.add(calleeName)

	def AddFunction(self, funcName):
		self.functions.add(funcName)

	def AddBrief(self, brief):
		self.brief = self.brief + brief

	def AddDetail(self, detail):
		self.detail = self.detail + detail


# Represents a function
class Function:
	def __init__(self):
		self.callees = set()
		self.callers = set()
		self.module = '<Null Module>'
		self.brief = ''
		self.detail = ''
		self.inputs = ''
		self.outputs = ''
		self.sideEffects = ''

	def SetModule(self, modName):
		self.module = modName

	def AddCaller(self, callerName):
		self.callers.add(callerName)

	def AddCallee(self, calleeName):
		self.callees.add(calleeName)

	def AddBrief(self, brief):
		self.brief = self.brief + '\n' + brief

	def AddDetail(self, detail):
		self.detail = self.detail + '\n' + detail

	def AddInputs(self, inputs):
		self.inputs = self.inputs + '\n' + inputs

	def AddOutputs(self, outputs):
		self.outputs = self.outputs + '\n' + outputs

	def AddSideEffects(self, sideEffects):
		self.sideEffects = self.sideEffects + '\n' + sideEffects


# For containing modules and functions while scanning
modules = collections.defaultdict(Module)
functions = collections.defaultdict(Function)


# Scans comments to gather documentation information
class DocScanner:
	STATE_NONE = 0
	STATE_MOD = 1
	STATE_FUNC = 2

	SUBSTATE_NONE = 0
	SUBSTATE_BRIEF = 1
	SUBSTATE_DETAIL = 2
	SUBSTATE_INPUTS = 3
	SUBSTATE_OUTPUTS = 4
	SUBSTATE_SIDEEFFECTS = 5

	def __init__(self, sourceScanner):
		sourceScanner.SetCallback('newfile', self.CBNewFile)
		sourceScanner.SetCallback('comment', self.CBComment)

		self.state = self.STATE_NONE
		self.substate = self.SUBSTATE_NONE
		self.filename = ''
		self.modname = ''
		self.funcname = ''

	def CBNewFile(self, dummy, pathname):
		if self.state != self.STATE_NONE:
			print('Error: DocScanner not in STATE_NONE at beginning of new file.')
		self.state = self.STATE_NONE
		self.substate = self.SUBSTATE_NONE
		self.filename = pathname
		self.modname = ''
		self.funcname = ''

	def CBComment(self, linenum, commenttext):
		if commenttext.rstrip()[-1:] == '/':
			self.substate = self.SUBSTATE_NONE

		words = commenttext.split()
		if len(words) == 0:
			return

		# Handle switching between macrostates
		if words[0] == 'module:':
			self.modname = words[1]
			self.state = self.STATE_MOD
			self.substate = self.SUBSTATE_NONE
		elif words[0] == 'function:':
			self.funcname = words[1]
			self.state = self.STATE_FUNC
			self.substate = self.SUBSTATE_NONE
			modules[self.modname].AddFunction(self.funcname)

		# Handle switching between microstates
		if self.state == self.STATE_MOD:
			if self.substate == self.SUBSTATE_NONE:
				# check for brief or detail headers
				if words[0] == 'brief:':
					self.substate = self.SUBSTATE_BRIEF
				elif words[0] == 'detail:':
					self.substate = self.SUBSTATE_DETAIL
			elif self.substate == self.SUBSTATE_BRIEF:
				modules[self.modname].AddBrief(commenttext)
			elif self.substate == self.SUBSTATE_DETAIL:
				modules[self.modname].AddDetail(commenttext)
		elif self.state == self.STATE_FUNC:
			if self.substate == self.SUBSTATE_NONE:
				# check for any headers
				if words[0] == 'brief:':
					self.substate = self.SUBSTATE_BRIEF
				elif words[0] == 'detail:':
					self.substate = self.SUBSTATE_DETAIL
				elif words[0] == 'pass:':
					self.substate = self.SUBSTATE_INPUTS
				elif words[0] == 'return:':
					self.substate = self.SUBSTATE_OUTPUTS
				elif words[0] == 'sideeffects:':
					self.substate = self.SUBSTATE_SIDEEFFECTS
			elif self.substate == self.SUBSTATE_BRIEF:
				functions[self.funcname].AddBrief(commenttext)
			elif self.substate == self.SUBSTATE_DETAIL:
				functions[self.funcname].AddDetail(commenttext)
			elif self.substate == self.SUBSTATE_INPUTS:
				functions[self.funcname].AddInputs(commenttext)
			elif self.substate == self.SUBSTATE_OUTPUTS:
				functions[self.funcname].AddOutputs(commenttext)
			elif self.substate == self.SUBSTATE_SIDEEFFECTS:
				functions[self.funcname].AddSideEffects(commenttext)


# Scans labels and call instructions to gather dependency information
class TreeScanner:
	STATE_NONE = 0

	def __init__(self, sourceScanner):
		sourceScanner.SetCallback('newfile', self.CBNewFile)
		sourceScanner.SetCallback('label', self.CBLabel)
		sourceScanner.SetCallback('section', self.CBSection)
		sourceScanner.SetCallback('code', self.CBCode)

		self.state = self.STATE_NONE

	def CBNewFile(self, dummy, pathname):
		if self.state != self.STATE_NONE:
			print('Error: TreeScanner not in STATE_NONE at beginning of new file.')
		self.state = self.STATE_NONE

	def CBLabel(self, linenum, label):
		pass

	def CBSection(self, linenum, section):
		pass

	def CBCode(self, linenum, codeline):
		pass


# Generates .md (Github flavored markdown) files with function/module docs
def OutputDocs(path):
	for modName in modules.keys():
		prettyName = modName[0].upper() + modName[1:]
		with open(path + '/Module ' + prettyName + '.md', 'w+') as f:
			f.write('#Module ' + prettyName + '\n')
			f.write(modules[modName].brief + '\n')
			f.write('##Detail\n')
			f.write(modules[modName].detail + '\n')
			f.write('##Calls\n')
			f.write('##Called By\n')
			f.write('##Functions\n')
			for funcName in modules[modName].functions:
				f.write('###' + funcName + '\n')
				f.write(functions[funcName].brief + '\n')
				f.write('####Pass\n')
				f.write(functions[funcName].inputs + '\n')
				f.write('####Return\n')
				f.write(functions[funcName].outputs + '\n')
				f.write('####Side Effects\n')
				f.write(functions[funcName].sideEffects + '\n')
				f.write('####Detail\n')
				f.write(functions[funcName].detail + '\n')
				f.write('####Calls\n')
				f.write('####Called By\n')
				f.write('---\n')


# Generates a .dot file for generating a callgraph with graphviz
def OutputModCallgraph(filename):
	pass

def OutputFuncCallgraph(filename):
	pass
