import os
import re


FILE_BEGIN = 0
FILE_END = 1
LINE = 2
LABEL = 3
CODE = 4
COMMENT = 5
PREPROC = 6
SECTION = 7
GLOBAL = 8
FINISH = 9


# Yield tuples as files in a project are scanned:
# (FILE_BEGIN, full_path)
# (FILE_END,   full_path)
# (LINE,       line_num, line)
# (LABEL,      label)
# (CODE,       code)
# (COMMENT,    comment)
# (PREPROC,    preproc)
# (SECTION,    [sect_name, sect_attr, ...])
# (GLOBAL,     func_name)
# (FINISH)
def scan_project(rootpath):
	for dirname, subdirlist, filelist in os.walk(rootpath):
		for filename in filelist:
			full_path = os.path.join(dirname, filename)
			yield (FILE_BEGIN, full_path)
			with open(full_path, 'r') as f:
				for line_num, line in enumerate(f):
					# Report the current line
					line_num += 1
					line = line.rstrip('\r\n')
					yield (LINE, line_num, line)

					# separate labels, code, preassembler directives, and comments
					commentStart = line.find(';')
					if commentStart < 0:
						commentStart = len(line)

					labelEnd = line.find(':')
					if labelEnd < 0:
						labelEnd = 0
					if labelEnd >= commentStart:
						labelEnd = 0

					label = line[:labelEnd].lstrip().rstrip()
					# Try to rule out any accidental code
					if ('"' in label) or ("'" in label) or ('\t' in label) or (' ' in label) or label == '':
						label = None
					code = line[labelEnd:commentStart].lstrip().rstrip()
					comment = line[commentStart + 1:].lstrip().rstrip()
					preproc = None
					if line.startswith('%'):
						preproc = line[:commentStart].lstrip().rstrip()
						code = None
						label = None

					section = None
					glob = None
					if code != None and code.startswith('[') and code.endswith(']'):
						words = re.findall(r"[\w']+", code)
						if len(words) > 0:
							if words[0] == 'section':
								code = None
								section = words[1:]
								yield (SECTION, section)
							if words[0] == 'global':
								code = None
								glob = words[1]

					if label != None:
						yield (LABEL, label)
					if code != None:
						yield (CODE, code)
					if preproc != None:
						yield (PREPROC, preproc)
					if section != None:
						yield (SECTION, section)
					if glob != None:
						yield (GLOBAL, glob)
					if commentStart < len(line):
						yield (COMMENT, comment)
			yield (FILE_END, full_path)
	yield (FINISH,)

