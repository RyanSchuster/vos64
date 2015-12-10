# This is the top level script for source scanners and doc generators.
# I am obviously not a Python programmer.

import SourceScanner
import DocScanner
import TestScanner


# Make the root level source tree scanner
sourceScanner = SourceScanner.SourceScanner()

# Make the sub-scanners that the root scanner calls back
testScanner = TestScanner.TestScanner(sourceScanner)
docScanner = DocScanner.DocScanner(sourceScanner)
treeScanner = DocScanner.TreeScanner(sourceScanner)

# Scan some garbage
sourceScanner.ScanDir('./testsource')

# Dump the dox
DocScanner.OutputDocs('doc/vos64.wiki/Modules/')
DocScanner.OutputFuncCallgraph('doc/funcCallgraph.dot')
DocScanner.OutputModCallgraph('doc/modCallgraph.dot')
