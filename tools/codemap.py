#!/usr/bin/env python3


import scanner


# ------------------------------------------------------------------------------
# Classes for holding source code entities


class Module(object):
	def __init__(self):
		self.brief = ''
		self.detail = ''
		self.functions = set()
		self.calls = set()


class Function(object):
	def __init__(self):
		self.order = 0
		self.brief = ''
		self.detail = ''
		self.inputs = []
		self.outputs = []
		self.sideeffects = []
		self.module = ''
		self.private = True
		self.calls = set()


# ------------------------------------------------------------------------------
# Factories for module and function filters


def hasname(name):
	return lambda kv : kv[0] == name


def iscalledby(obj):
	return lambda kv : kv[0] in obj.calls


def calls(name):
	return lambda kv : name in kv[1].calls


def inmodule(mod_name):
	return lambda kv : kv[1].module == mod_name


def ispublic():
	return lambda kv : not kv[1].private


# ------------------------------------------------------------------------------
# Class for holding and and querying source code maps


class CodeMap(object):
	def __init__(self):
		self.mods = dict()
		self.funcs = dict()

	def mod(self, mod_name):
		if mod_name not in self.mods:
			self.mods[mod_name] = Module()
		return self.mods[mod_name]

	def func(self, func_name):
		if func_name not in self.funcs:
			self.funcs[func_name] = Function()
			self.funcs[func_name].order = len(self.funcs)
		return self.funcs[func_name]

	def funcs_sorted(self, func_filter = lambda x : True):
		filtered = list(filter(func_filter, self.funcs.items()))
		filtered.sort(key = lambda x : x[1].order)
		return filtered

	def mods_sorted(self, mod_filter = lambda x : True):
		filtered = list(filter(mod_filter, self.mods.items()))
		filtered.sort(key = lambda x : x[0])
		return filtered


# ------------------------------------------------------------------------------
# State machine to build a code map from scanned source


class MapBuilder(object):
	B_NONE = 0
	B_DETAIL = 1
	B_PASS = 2
	B_RETURN = 3
	B_SIDEEFFECTS = 4

	O_NONE = 0
	O_MOD = 1
	O_FUNC = 2

	def __init__(self, code_map):
		self.code_map = code_map
		self._reset_state()

	def _reset_state(self):
		self.cur_mod = ''
		self.cur_func = ''
		self.cur_block = self.B_NONE
		self.cur_obj = self.O_NONE
		self.in_code = False

	def absorb_token(self, token):
		token_type = token[0]

		if token_type == scanner.FILE_END:
			self._reset_state()

		elif token_type == scanner.SECTION:
			section = token[1][0]
			attrs = token[1][1:]
			if 'text' in section or 'Text' in section or 'exec' in attrs:
				self.in_code = True
			else:
				self.in_code = False

		elif token_type == scanner.GLOBAL:
			if self.in_code == True:
				func_name = token[1]
				self.code_map.func(func_name).private = False

		elif token_type == scanner.LABEL:
			label = token[1]
			if self.in_code and not label.startswith('.'):
				self.cur_func = label

		elif token_type == scanner.CODE:
			code = token[1]
			if code.startswith('call'):
				callee = code.split()[1]
				self.code_map.func(self.cur_func).calls.add(callee)

		elif token_type == scanner.COMMENT:
			comment = token[1]

			if comment.startswith('module: '):
				self.cur_mod = comment.split(' ', 1)[1]
				self.cur_obj = self.O_MOD

			elif comment.startswith('function: '):
				self.cur_func = comment.split(' ', 1)[1]
				self.cur_obj = self.O_FUNC
				if self.cur_mod:
					self.code_map.func(self.cur_func).module = self.cur_mod
					self.code_map.mod(self.cur_mod).functions.add(self.cur_func)

			elif comment.startswith('brief: '):
				brief = comment.split(' ', 1)[1]
				if self.cur_obj == self.O_MOD:
					self.code_map.mod(self.cur_mod).brief = brief
				elif self.cur_obj == self.O_FUNC:
					self.code_map.func(self.cur_func).brief = brief

			elif comment.startswith('calls: '):
				callee = comment.split(' ', 1)[1]
				self.code_map.func(self.cur_func).calls.add(callee)

			elif comment.startswith('detail:'):
				if self.cur_block == self.B_NONE:
					self.cur_block = self.B_DETAIL

			elif comment.startswith('pass:'):
				if self.cur_block == self.B_NONE:
					self.cur_block = self.B_PASS

			elif comment.startswith('return:'):
				if self.cur_block == self.B_NONE:
					self.cur_block = self.B_RETURN

			elif comment.startswith('sideeffects:'): # TODO: check for "side effects"
				if self.cur_block == self.B_NONE:
					self.cur_block = self.B_SIDEEFFECTS

			elif comment == '/' and self.cur_block != self.B_NONE:
				self.cur_block = self.B_NONE

			elif self.cur_block != self.B_NONE:
				if self.cur_obj == self.O_MOD:
					obj = self.code_map.mod(self.cur_mod)
				elif self.cur_obj == self.O_FUNC:
					obj = self.code_map.func(self.cur_func)
				if self.cur_block == self.B_DETAIL:
					obj.detail += comment + '\n'
				elif self.cur_block == self.B_PASS:
					obj.inputs.append(comment)
				elif self.cur_block == self.B_RETURN:
					obj.outputs.append(comment)
				elif self.cur_block == self.B_SIDEEFFECTS:
					obj.sideeffects.append(comment)

			else:
				pass
				#print('{}:{}:\t{}'.format(cur_file, cur_line, token[1]))

		elif token_type == scanner.FINISH:
			for func_name, func in self.code_map.funcs_sorted():
				for callee_name in func.calls:
					callee = self.code_map.func(callee_name)
					mod = self.code_map.mod(func.module)
					callee_mod_name = callee.module
					mod.calls.add(callee_mod_name)
			for mod_name, mod in self.code_map.mods_sorted():
				mod.calls -= set([mod_name])


# ------------------------------------------------------------------------------


def test():
	pass


def main():
	code_map = CodeMap()
	builder = MapBuilder(code_map)

	for token in scanner.scan_project('./src'):
		builder.absorb_token(token)

	#code_map.report_calls()
	#print(code_map.make_callgraph_dotfile(lambda x:True, lambda x:True))
	#print(code_map.make_module_callgraph_dotfile('Debug'))
	#print(code_map.make_function_callgraph_dotfile('DebugPutChar'))


if __name__ == '__main__':
	main()

