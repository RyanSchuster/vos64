import os

import CodeMap
import DocScanner
import CallScanner
import ReviewScanner


# build code map

codeMap = CodeMap()


# build scanners

docScanner = DocScanner(codeMap)
callScanner = CallScanner(codeMap)
reviewScanner = ReviewScanner()


# scanning functions

def scanDir(path):
	for dirName, subdirList, fileList in os.walk(path):
		for fileName in fileList:
			if fileName[-4:] == '.asm' or fileName[-2:] == '.h':
				path = dirName + '/' + fileName
				with open(path) as f:
					for lineNum, line in enumerate(f):
						docScanner.scanLine(path, lineNum, line)
						#callScanner.scanLine(path, lineNum, line)
						#reviewScanner.scanLine(path, lineNum, line)


# begin scanning source tree

scanDir('./src/')
scanDir('./inc/')
