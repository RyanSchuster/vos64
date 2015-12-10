import collections


# Represents a code module
class Module:
	def __init__(self):
		pass

	def AddCaller(self, callerMod, callerFunc):
		pass

	def AddCallee(self, calleeMod, calleeFunc):
		pass

	def AddBrief(self, brief):
		pass

	def AddDetail(self, detail):
		pass


# Represents a function
class Function:
	def __init__(self):
		pass

	def AddCaller(self, callerMod, callerFunc):
		pass

	def AddCallee(self, calleeMod, calleeFunc):
		pass

	def AddBrief(self, brief):
		pass

	def AddDetail(self, detail):
		pass

	def AddInputs(self, inputs):
		pass

	def AddOutputs(self, outputs):
		pass

	def AddSideEffects(self, sideEffects):
		pass


# For containing modules and functions while scanning
modules = collections.defaultdict(Module)
functions = collections.defaultdict(Function)


# Scans comments to gather documentation information
class DocScanner:
	STATE_NONE = 0
	STATE_MOD = 1
	STATE_FUNC = 2

	def __init__(self, sourceScanner):
		sourceScanner.SetCallback('newfile', self.CBNewFile)
		sourceScanner.SetCallback('comment', self.CBComment)

		self.state = self.STATE_NONE

	def CBNewFile(self, dummy, pathname):
		if self.state != self.STATE_NONE:
			print('Error: DocScanner not in STATE_NONE at beginning of new file.')
		self.state = self.STATE_NONE

	def CBComment(self, linenum, commenttext):
		pass


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
def OutputDocs(filename):
	pass


# Generates a .dot file for generating a callgraph with graphviz
def OutputCallgraph(filename):
	pass
