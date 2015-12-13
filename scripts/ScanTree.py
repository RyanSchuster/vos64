#!/usr/bin/python

# This is the top level script for source scanners and doc generators.
# I am obviously not a Python programmer.

import SourceScanner
import AutoDox


# Make the root level source tree scanner
sourceScanner = SourceScanner.SourceScanner()

# Make the sub-scanners that the root scanner calls back
#testScanner = TestScanner.TestScanner(sourceScanner)
docScanner = AutoDox.DocScanner(sourceScanner)
treeScanner = AutoDox.TreeScanner(sourceScanner)

# Scan some garbage
sourceScanner.ScanDir('./inc')
sourceScanner.ScanDir('./src')

# Dump the dox
AutoDox.OutputDocs('./scripts/doc/vos64.wiki')
#AutoDox.OutputFuncCallgraph('doc/funcCallgraph.dot')
#AutoDox.OutputModCallgraph('doc/modCallgraph.dot')
