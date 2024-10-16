#!/usr/bin/env python

import sys

starting_pdb = sys.argv[1]

with open(starting_pdb, 'r') as in_pdb:
    lines = in_pdb.readlines()

out_lines = []

for line in lines:
    if line.startswith('HETATM'):
        continue

    elif line.startswith('ANISOU'):
        continue

    else:
        out_lines.append(line)

out_pdb_name = starting_pdb[:-4] + '_clean.pdb'

with open(out_pdb_name, 'w') as out_pdb:
    out_pdb.writelines(out_lines)


