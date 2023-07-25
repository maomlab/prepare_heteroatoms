#!/bin/bash

# run this script on all sdf prediction files generated from diffdock to fix formatting for files with negative coordinates

sdf=$1

sed -i 's/-/ -/g' $sdf
