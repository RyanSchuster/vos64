import collections


# Represents a code module
class Module:
	def __init__(self):
		self.name = 'No Module'
		self.brief = ''
		self.detail = ''
		self.callees = set()
		self.callers = set()
		self.functions = set()


	def SetName(self, modName):
		self.name = modName

	def GetName(self):
		return self.name


	def SetBrief(self, brief):
		self.brief = brief

	def GetBrief(self):
		return self.brief


	def AddDetail(self, detail):
		self.detail = self.detail + detail + '\n'

	def GetDetail(self):
		return self.detail


	def AddCallee(self, calleeName):
		self.callees.add(calleeName)

	def GetCallees(self):
		return self.callees


	def AddCaller(self, callerName):
		self.callers.add(callerName)

	def GetCallers(self):
		return self.callers


	def AddFunction(self, funcName):
		self.functions.add(funcName)

	def GetFunctions(self):
		return self.functions


# Represents a function
class Function:
	def __init__(self):
		self.name = ''
		self.module = 'No Module'
		self.brief = ''
		self.detail = ''
		self.inputs = ''
		self.outputs = ''
		self.sideEffects = ''
		self.callees = set()
		self.callers = set()


	def SetName(self, funcName):
		self.name = funcName

	def GetName(self):
		return self.name


	def SetModule(self, modName):
		self.module = modName

	def GetModule(self):
		return self.module


	def SetBrief(self, brief):
		self.brief = brief

	def GetBrief(self):
		return self.brief


	def AddDetail(self, detail):
		self.detail = self.detail + detail + '\n'

	def GetDetail(self):
		return self.detail


	def AddInput(self, inputText):
		self.inputs = self.inputs + '\n' + inputText

	def AddOutput(self, outputText):
		self.outputs = self.outputs + '\n' + outputText

	def AddSideEffect(self, sideEffectText):
		self.sideEffects = self.sideEffects + '\n' + sideEffectText


	def AddCallee(self, calleeName):
		self.callees.add(calleeName)

	def GetCallees(self):
		return self.callees


	def AddCaller(self, callerName):
		self.callers.add(callerName)

	def GetCallers(self):
		return self.callers


# For containing modules and functions while scanning
modules = collections.defaultdict(Module)
functions = collections.defaultdict(Function)


# For building the markdown wiki pages

def MakeLink(toMod, toFunc, text = ''):
	ret = ''

	if toFunc != '':
		# Link to function page
		if text == '':
			text = toFunc
		ret = '[[' + text + '|function-index#function-' + toFunc.lower() + ']]'
	elif toFunc == '':
		# Link to module page
		if text == '':
			text = toMod
		ret = '[[' + text + '|module-index#module-' + toMod.lower() + ']]'

	return ret

def MakeModulePage():
	text = ''

	# Make table of contents
	text = text + '# Contents\n\n'
	for modName, module in modules.items():
		text = text + '* ' + MakeLink(module.GetName(), '')
		text = text + ' - ' + module.GetBrief() + '\n'
	text = text + '\n'
	text = text + '---\n\n'

	# Make contents
	for modName, module in modules.items():
		text = text + '# Module ' + module.GetName() + '\n\n'
		text = text + module.GetBrief() + '\n\n'
		text = text + '## Detail\n\n'
		text = text + module.GetDetail() + '\n\n'
		text = text + '## Functions\n\n'
		for funcName in module.GetFunctions():
			text = text + '* ' + MakeLink(module.GetName(), funcName)
			text = text + ' - ' + functions[funcName].GetBrief() + '\n'
		text = text + '\n'
		text = text + '## Calls\n\n'
		for calleeName in module.GetCallees():
			text = text + '* ' + MakeLink(calleeName, '')
			text = text + ' - ' + modules[calleeName].GetBrief() + '\n'
		text = text + '\n'
		text = text + '## Called By\n\n'
		for callerName in module.GetCallers():
			text = text + '* ' + MakeLink(callerName, '')
			text = text + ' - ' + modules[callerName].GetBrief() + '\n'
		text = text + '\n'
		text = text + '---\n\n'

	return text

def MakeFunctionPage():
	text = ''

	# Make table of contents
	text = text + '# Contents\n\n'
	for modName, module in modules.items():
		text = text + '* ' + MakeLink(module.GetName(), '')
		text = text + ' - ' + module.GetBrief() + '\n'
		for funcName in module.GetFunctions():
			text = text + '  * ' + MakeLink(module.GetName(), funcName)
			text = text + ' - ' + functions[funcName].GetBrief() + '\n'
		text = text + '\n'
	text = text + '---\n\n'

	# Make contents
	for modName, module in modules.items():
		for funcName in module.GetFunctions():
			function = functions[funcName]
			text = text + '# Function ' + function.GetName() + '\n\n'
			text = text + 'Part of Module '
			text = text + MakeLink(module.GetName(), '') + '\n\n'
			text = text + function.GetBrief() + '\n\n'
			text = text + '## Pass\n\n'
			text = text + '## Return\n\n'
			text = text + '## Side Effects\n\n'
			text = text + '## Detail\n\n'
			text = text + function.GetDetail() + '\n\n'
			text = text + '## Calls\n\n'
			for calleeName in function.GetCallees():
				text = text + '* ' + MakeLink(functions[calleeName].GetModule, calleeName)
				text = text + ' - ' + functions[calleeName].GetBrief() + '\n'
			text = text + '\n'
			text = text + '## Called By\n\n'
			for callerName in function.GetCallers():
				text = text + '* ' + MakeLink(functions[callerName].GetModule, callerName)
				text = text + ' - ' + functions[callerName].GetBrief() + '\n'
			text = text + '\n'
			text = text + '---\n\n'

	return text


# Scans comments to gather documentation information
class DocScanner:
	STATE_NONE = 0
	STATE_MOD = 1
	STATE_FUNC = 2

	SUBSTATE_NONE = 0
	SUBSTATE_DETAIL = 1
	SUBSTATE_INPUTS = 2
	SUBSTATE_OUTPUTS = 3
	SUBSTATE_SIDEEFFECTS = 4

	def __init__(self, sourceScanner):
		sourceScanner.SetCallback('newfile', self.CBNewFile)
		sourceScanner.SetCallback('comment', self.CBComment)

		self.state = self.STATE_NONE
		self.substate = self.SUBSTATE_NONE
		self.filename = ''
		self.modname = 'No Module'
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
			modules[self.modname] = Module()
			modules[self.modname].SetName(self.modname)
		elif words[0] == 'function:':
			self.funcname = words[1]
			self.state = self.STATE_FUNC
			self.substate = self.SUBSTATE_NONE
			modules[self.modname].AddFunction(self.funcname)
			functions[self.funcname].SetModule(self.modname)
			functions[self.funcname].SetName(self.funcname)

		# Handle switching between microstates
		if self.state == self.STATE_MOD:
			if self.substate == self.SUBSTATE_NONE:
				# check for brief or detail headers
				if words[0] == 'brief:':
					modules[self.modname].SetBrief(commenttext[6:])
				elif words[0] == 'detail:':
					self.substate = self.SUBSTATE_DETAIL
			elif self.substate == self.SUBSTATE_DETAIL:
				modules[self.modname].AddDetail(commenttext)
		elif self.state == self.STATE_FUNC:
			if self.substate == self.SUBSTATE_NONE:
				# check for any headers
				if words[0] == 'brief:':
					functions[self.funcname].SetBrief(commenttext[6:])
				elif words[0] == 'detail:':
					self.substate = self.SUBSTATE_DETAIL
				elif words[0] == 'pass:':
					self.substate = self.SUBSTATE_INPUTS
				elif words[0] == 'return:':
					self.substate = self.SUBSTATE_OUTPUTS
				elif words[0] == 'sideeffects:':
					self.substate = self.SUBSTATE_SIDEEFFECTS
			elif self.substate == self.SUBSTATE_DETAIL:
				functions[self.funcname].AddDetail(commenttext)
			elif self.substate == self.SUBSTATE_INPUTS:
				functions[self.funcname].AddInput(commenttext)
			elif self.substate == self.SUBSTATE_OUTPUTS:
				functions[self.funcname].AddOutput(commenttext)
			elif self.substate == self.SUBSTATE_SIDEEFFECTS:
				functions[self.funcname].AddSideEffect(commenttext)


# Scans labels and call instructions to gather dependency information
class TreeScanner:
	STATE_NONE = 0
	STATE_CODE = 1

	def __init__(self, sourceScanner):
		sourceScanner.SetCallback('newfile', self.CBNewFile)
		sourceScanner.SetCallback('label', self.CBLabel)
		sourceScanner.SetCallback('section', self.CBSection)
		sourceScanner.SetCallback('code', self.CBCode)

		self.state = self.STATE_NONE
		self.funcname = ''

	def CBNewFile(self, dummy, pathname):
		if self.state != self.STATE_NONE:
			print('Error: TreeScanner not in STATE_NONE at beginning of new file.')
		self.state = self.STATE_NONE

	def CBLabel(self, linenum, label):
		if self.state == self.STATE_CODE and label[0] != '.':
			self.funcname = label
			functions[self.funcname].SetName(self.funcname)

	def CBSection(self, linenum, section):
		if section[0] == '.text' or section[0] == 'text' or 'exec' in section[1:]:
			self.state = self.STATE_CODE
		else:
			self.state = self.STATE_NONE

	def CBCode(self, linenum, codeline):
		if self.state == self.STATE_CODE:
			words = codeline.split()
			if len(words) >= 2 and words[0] == 'call':
				functions[self.funcname].AddCallee(words[1])
				functions[words[1]].AddCaller(self.funcname)


# Generates .md (Github flavored markdown) files with function/module docs
def OutputDocs(path):
	# Connect module dependencies
	for funcName in functions.keys():
		modName = functions[funcName].module
		for calleeFunc in functions[funcName].callees:
			calleeModName = functions[calleeFunc].module
			modules[modName].AddCallee(calleeModName)
			modules[calleeModName].AddCaller(modName)

	# Write module index wiki page
	with open(path + '/Module-Index.md', 'w+') as f:
		f.write(MakeModulePage())

	# Write function index wiki page
	with open(path + '/Function-Index.md', 'w+') as f:
		f.write(MakeFunctionPage())


# Generates a .dot file for generating a callgraph with graphviz
def OutputModCallgraph(filename):
	pass

def OutputFuncCallgraph(filename):
	pass