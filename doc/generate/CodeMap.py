class CodeMap:
	def __init__(self):
		pass

	def addModFunc(self, moduleName, funcName):
		print 'module: ' + moduleName + ' owns: ' + funcName

	def addModBrief(self, moduleName, brief):
		print 'module: ' + moduleName + ' brief: ' + brief

	def addModDetail(self, moduleName, detail):
		print 'module: ' + moduleName + ' detail: ' + detail

	def addFuncBrief(self, funcName, brief):
		print 'function: ' + funcName + ' brief: ' + brief

	def addFuncDetail(self, funcName, detail):
		print 'function: ' + funcName + ' detail: ' + detail

	def addFuncInput(self, funcName, inputs):
		print 'function: ' + funcName + ' input: ' + inputs

	def addFuncOutput(self, funcName, outputs):
		print 'function: ' + funcName + ' output: ' + outputs

	def addFuncDep(self, callerFuncName, calleeFuncName):
		print 'function: ' + callerFuncName + ' calls: ' + calleeFuncName
