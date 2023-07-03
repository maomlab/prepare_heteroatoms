#!/bin/bash

# convert sdf files in to_convert.txt to pdb format

# set dir where all sdf predictions live
pred_dir=$1
parent_dir=$2

cd $pred_dir
cd rank1_cube_preds

cat to_convert.txt | while read line 
do
	out=${line::-3}pdb
   	obabel $line -O $out
done

cd $parent_dir
