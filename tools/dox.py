#!/usr/bin/env python3

import os
import sys
import scanner
import codemap


# ------------------------------------------------------------------------------
# Parameterized output filenames


def func_index_name():
	return 'Function-Index.md'


def func_index_graph_name():
	return 'func_index_graph.dot'


def mod_index_name():
	return 'Module-Index.md'


def mod_index_graph_name():
	return 'mod_index_graph.dot'


def func_page_name(func_name):
	return os.path.join('funcs', '{}.md'.format(func_name))


def func_graph_name(func_name):
	return os.path.join('funcs', '{}.dot'.format(func_name))


def mod_page_name(mod_name):
	return os.path.join('mods', '{}.md'.format(mod_name))


def mod_graph_name(mod_name):
	return os.path.join('mods', '{}.dot'.format(mod_name))


# ------------------------------------------------------------------------------
# Helpful builder functions


def link(text, filename):
	return '[{}]({})'.format(text, text)


def table_list(f, line_list):
	has_table = False
	has_lines = False
	table = '|location||description|\n'
	table += '|:---|:---:|:---|\n'
	lines = ''
	for line in line_list:
		findPtr = line.find('->')
		findEq = line.find('=')
		if findPtr > 0:
			has_table = True
			name = line[:findPtr].lstrip().rstrip()
			desc = line[findPtr + 2:].lstrip().rstrip()
			table += '|`{}`|->|{}|\n'.format(name, desc)
		elif findEq > 0:
			has_table = True
			name = line[:findEq].lstrip().rstrip()
			desc = line[findEq + 2:].lstrip().rstrip()
			table += '|`{}`|=|{}|\n'.format(name, desc)
		elif line != '':
			has_lines = True
			lines += '* {}\n'.format(line)

	if (not has_table) and (not has_lines):
		f.write('None\n\n')
	elif has_table:
		f.write('{}\n'.format(table))
	elif has_lines:
		f.write('{}\n'.format(lines))


def callgraph(f, code_map, mod_filter, func_filter, mark_mod=None, mark_func=None):
	f.write('digraph Callgraph {\n')

	for mod_name, mod in code_map.mods_sorted(mod_filter):
		f.write('\tsubgraph cluster_{} {{\n'.format(mod_name))
		f.write('\t\tnode [style=filled, color=white];\n')
		f.write('\t\tstyle = filled;\n')
		if mod_name == mark_mod:
			f.write('\t\tcolor = lightblue;\n')
		else:
			f.write('\t\tcolor = grey;\n')
		f.write('\t\tlabel = "Module {}";\n'.format(mod_name))
		for func_name in mod.functions:
			func = code_map.funcs[func_name]
			if func_filter((func_name, func)):
				f.write('\t\t{};\n'.format(func_name))
		f.write('\t}\n')

	for func_name, func in code_map.funcs_sorted(func_filter):
		if func_name == mark_func:
			f.write('{} [color=lightblue];\n'.format(func_name))
		elif func.private:
			f.write('{} [color=lightgrey];\n'.format(func_name))
		for callee_name in func.calls:
			callee = code_map.funcs[callee_name]
			if not func_filter((callee_name, callee)):
				continue
			f.write('\t{} -> {};\n'.format(func_name, callee_name))

	f.write('}\n')


# ------------------------------------------------------------------------------
# Output file builders


def graph_mod_index(f, code_map):
	f.write('digraph Callgraph {\n')

	for mod_name, mod in code_map.mods_sorted():
		for callee_name in mod.calls:
			f.write('\t{} -> {};\n'.format(mod_name, callee_name))

	f.write('}\n')


def page_mod_index(f, code_map):
	f.write('# Module Index\n\n')
	f.write('![Module Callgraph]({}.png)\n\n'.format(mod_index_graph_name()))
	for mod_name, mod in code_map.mods_sorted():
		mod_link = link(mod_name, mod_page_name(mod_name))
		f.write('* {} - {}\n'.format(mod_link, mod.brief))


def graph_func_index(f, code_map):
	def all_mods(kv):
		return True

	def public_funcs(kv):
		return not kv[1].private

	callgraph(f, code_map, all_mods, public_funcs)


def page_func_index(f, code_map):
	f.write('# Function Index\n\n')
	f.write('![Full Callgraph]({}.png)\n\n'.format(func_index_graph_name()))
	for mod_name, mod in code_map.mods_sorted():
		mod_link = link(mod_name, mod_page_name(mod_name))
		f.write('* Module {} - {}:\n'.format(mod_link, mod.brief))

		inmod = codemap.inmodule(mod_name)
		ispub = codemap.ispublic()
		filt = lambda f : inmod(f) and ispub(f)

		for func_name, func in code_map.funcs_sorted(filt):
			func_link = link(func_name, func_page_name(func_name))
			f.write('  * {} - {}\n'.format(func_link, func.brief))


def graph_module(f, code_map, mod_name, mod):
	# Filter for functions that are in, are called by, or call a module
	def func_touches_mod(kv):
		test_name = kv[0]
		test = kv[1]
		if test_name in mod.functions:
			return True
		for func_name in mod.functions:
			func = code_map.funcs[func_name]
			if func_name in test.calls:
				return True
			if test_name in func.calls:
				return True
		return False

	# Filter for modules that are, are called by, or call a module
	def mod_touches_mod(kv):
		test_name = kv[0]
		test = kv[1]
		if test_name == mod_name:
			return True
		if test_name in mod.calls:
			return True
		if mod_name in code_map.mods[test_name].calls:
			return True
		return False

	callgraph(f, code_map, mod_touches_mod, func_touches_mod, mark_mod=mod_name)


def page_module(f, code_map, mod_name, mod):
	f.write('# Module {}\n\n'.format(mod_name))
	f.write('{}\n\n'.format(mod.brief))

	f.write('## Detail:\n\n')
	f.write('{}\n\n'.format(mod.detail))

	f.write('## Callgraph:\n\n')
	f.write('![Callgraph]({}.png)\n\n'.format(mod_graph_name(mod_name)))

	f.write('## Public Functions:\n\n')
	inmod = codemap.inmodule(mod_name)
	ispub = codemap.ispublic()
	filt = lambda f : inmod(f) and ispub(f)
	for func_name, func in code_map.funcs_sorted(filt):
		func_link = link(func_name, func_page_name(func_name))
		f.write('* {} - {}\n'.format(func_link, func.brief))
	f.write('\n')

	f.write('## Modules called by {}\n\n'.format(mod_name))
	filt = codemap.iscalledby(mod)
	for callee_name, callee in code_map.mods_sorted(filt):
		callee_link = link(callee_name, mod_page_name(callee_name))
		f.write('* {} - {}\n'.format(callee_link, callee.brief))
	f.write('\n')

	f.write('## Modules that call {}\n\n'.format(mod_name))
	filt = codemap.calls(mod_name)
	for caller_name, caller in code_map.mods_sorted(filt):
		caller_link = link(caller_name, mod_page_name(caller_name))
		f.write('* {} - {}\n'.format(caller_name, caller.brief))
	f.write('\n')


def graph_function(f, code_map, func_name, func):
	# Filter for modules that contain or contain callers/callees of func
	def mod_touches_func(kv):
		test_name = kv[0]
		test = kv[1]

		if test_name == func.module:
			return True
		for f_name in test.functions:
			f = code_map.funcs[f_name]
			if func_name in f.calls:
				return True
			if f_name in func.calls:
				return True
		return False

	# Filter for functions that are or are callers/callees of func
	def func_touches_func(kv):
		test_name = kv[0]
		test = kv[1]

		if test_name == func_name:
			return True
		if test_name in func.calls:
			return True
		if func_name in test.calls:
			return True
		return False

	callgraph(f, code_map, mod_touches_func, func_touches_func, mark_func=func_name)


def page_function(f, code_map, func_name, func):
	mod_link = link(func.module, mod_page_name(func.module))
	f.write('# Function {}.{}\n\n'.format(mod_link, func_name))
	f.write('{}\n\n'.format(func.brief))

	f.write('## Detail:\n\n')
	f.write('{}\n\n'.format(func.detail))

	f.write('## Pass:\n\n')
	table_list(f, func.inputs)

	f.write('## Return:\n\n')
	table_list(f, func.outputs)

	f.write('## Side Effects:\n\n')
	table_list(f, func.sideeffects)

	f.write('## Callgraph:\n\n')
	f.write('![Callgraph]({}.png)\n\n'.format(func_graph_name(func_name)))

	f.write('## Functions called by {}\n\n'.format(func_name))
	filt = codemap.iscalledby(func)
	for callee_name, callee in code_map.funcs_sorted(filt):
		callee_link = link(callee_name, func_page_name(callee_name))
		f.write('* {} - {}\n'.format(callee_link, callee.brief))
	f.write('\n')

	f.write('## Functions that call {}\n\n'.format(func_name))
	filt = codemap.calls(func_name)
	for caller_name, caller in code_map.funcs_sorted(filt):
		caller_link = link(caller_name, func_page_name(caller_name))
		f.write('* {} - {}\n'.format(caller_link, caller.brief))
	f.write('\n')


# ------------------------------------------------------------------------------
# Top-level documentation builder


def build_dox(code_map, output_dir):
	f = sys.stdout

	# Module index page
	filename = os.path.join(output_dir, mod_index_name())
	with open(filename, 'w') as f:
		page_mod_index(f, code_map)
	filename = os.path.join(output_dir, mod_index_graph_name())
	with open(filename, 'w') as f:
		graph_mod_index(f, code_map)
	os.system('dot -Tpng -O {}'.format(filename))

	# Function index page
	filename = os.path.join(output_dir, func_index_name())
	with open(filename, 'w') as f:
		page_func_index(f, code_map)
	filename = os.path.join(output_dir, func_index_graph_name())
	with open(filename, 'w') as f:
		graph_func_index(f, code_map)
	os.system('dot -Tpng -O {}'.format(filename))

	# Module pages
	for mod_name, mod in code_map.mods_sorted():
		filename = os.path.join(output_dir, mod_page_name(mod_name))
		with open(filename, 'w') as f:
			page_module(f, code_map, mod_name, mod)
		filename = os.path.join(output_dir, mod_graph_name(mod_name))
		with open(filename, 'w') as f:
			graph_module(f, code_map, mod_name, mod)
		os.system('dot -Tpng -O {}'.format(filename))

	# Function pages
	def ispub(kv):
		return not kv[1].private
	for func_name, func in code_map.funcs_sorted(ispub):
		filename = os.path.join(output_dir, func_page_name(func_name))
		with open(filename, 'w') as f:
			page_function(f, code_map, func_name, func)
		filename = os.path.join(output_dir, func_graph_name(func_name))
		with open(filename, 'w') as f:
			graph_function(f, code_map, func_name, func)
		os.system('dot -Tpng -O {}'.format(filename))


# ------------------------------------------------------------------------------


def test():
	pass


def main():
	code_map = codemap.CodeMap()
	builder = codemap.MapBuilder(code_map)

	for token in scanner.scan_project('./src'):
		builder.absorb_token(token)

	build_dox(code_map, './doc/vos64.wiki')


if __name__ == '__main__':
	main()

