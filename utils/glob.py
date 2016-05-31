#!/usr/bin/env python

from __future__ import print_function

import fnmatch
import os
import sys
import argparse

parser = argparse.ArgumentParser(add_help=True)
parser.add_argument('-d', dest='dir', nargs=1)
parser.add_argument('-i', dest='include_patterns', nargs='*', default='*.*')
parser.add_argument('-e', dest='exclude_patterns', nargs='*', default='')

args = parser.parse_args()

root_dir = args.dir[0]

for (dirpath, dirnames, files) in os.walk(root_dir):
    for f in files:
        include_match = False
        exclude_match = False
        for include_pattern in args.include_patterns:
            include_match = include_match or fnmatch.fnmatch(f, include_pattern)
        for exclude_pattern in args.exclude_patterns:
            exclude_match = exclude_match or fnmatch.fnmatch(f, exclude_pattern)
        if include_match and not exclude_match:
            print(os.path.join(dirpath, f))
