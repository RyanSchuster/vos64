# I am obviously not a Python programmer.

from SourceScanner import SourceScanner
from TestScanner import TestScanner


# Make the root level source tree scanner
sourceScanner = SourceScanner()

# Make the sub-scanners that the root scanner calls back
testScanner = TestScanner(sourceScanner)

# Scan some garbage
sourceScanner.ScanDir('./testsource')
