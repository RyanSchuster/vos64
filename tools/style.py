#!/usr/bin/python3


import sys
import os
import re


# ------------------------------------------------------------------------------
# Common


errors = 0
def style_error(location, message):
	if location:
		print('{}: {}'.format(location, message))
	else:
		print(message)
	global errors
	errors += 1


def true_len(string):
	length = 0
	for character in string:
		if character == '\t':
			length = ((length + 8) // 8) * 8
		else:
			length += 1
	return length


# ------------------------------------------------------------------------------
# Style checks


def comment_check(location, comment, line):
	a = r'\A--*\Z'
	b = r'\A [^ ].*\Z'

	if len(comment) > 0 and comment[0] == ' ' and not re.match(b, comment):
		style_error(location, 'Comment begins with too many spaces')
	if len(comment) > 0 and comment[0] != ' ' and not re.match(a, comment):
		style_error(location, 'Non-line comment must begin with space')
	if re.match(a, comment) and true_len(line) < 80:
		style_error(location, 'Line comment must extend to 80 chars')


def line_check(location, line):
	if true_len(line) > 80:
		style_error(location, 'Line longer than 80 characters.')
	if len(line) > 0 and line[-1].isspace():
		style_error(location, 'Line has trailing whitespace.')
	if len(line) > 0 and line[0] == ' ':
		style_error(location, 'Line begins with a space.')


def file_check(filename):
	if not (filename.endswith('.asm') or filename.endswith('.inc')):
		print('Style check: unknown extension: ' + filename)
		return

	print('File: ' + filename)
	with open(filename, 'r') as f:
		blank_lines = 0
		for line_num, line in enumerate(f):
			location = line_num + 1

			# Remove trailing newline
			line = line.rstrip('\r\n')

			# Check style on this line
			line_check(location, line)

			# Check comments on this line
			com_split = line.split(';', 1)
			if len(com_split) > 1:
				comment_check(location, com_split[-1], line)

			# Count running blank lines
			if line == '':
				blank_lines += 1
			else:
				blank_lines = 0


def project_check(rootpath):
	files = dict()
	for dirname, subdirlist, filelist in os.walk(rootpath):
		for filename in filelist:
			full_path = os.path.join(dirname, filename)

			# Check style within a file
			file_check(full_path)

			# Check for duplicate file names
			if filename in files:
				m = 'Duplicate filenames:\n  {}\n  {}'
				m = m.format(files[filename], full_path)
				style_error(None, m)
			else:
				files[filename] = full_path


# ------------------------------------------------------------------------------
# Top level and unit tests


def test():
	# Test true_len function, which assumes tab stops are at 8 characters
	a = '\t'
	b = 'AAAA\t'
	c = 'AA\tAA'
	d = '\tAAAA'
	assert true_len(a) == 8
	assert true_len(b) == 8
	assert true_len(c) == 10
	assert true_len(d) == 12


def main():
	run_tests = False

	if len(sys.argv) == 0:
		scan_dir = './src'
	if '--test' in sys.argv:
		run_tests = True

	if run_tests:
		test()
		print('Unit tests pass!')
		exit(0)

	global errors
	errors = 0
	print('Style check')
	project_check('./src')
	print('\n{} style error(s)'.format(errors))


if __name__ == '__main__':
	main()

