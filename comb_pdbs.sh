#!/bin/bash

# directory where diffdock predictions live
pred_dir=$1
parent_dir=$2

cd $pred_dir
cd rank1_cube_preds

cp $pred_dir/*clean.pdb .

cat *.pdb > prepared_struct.pdb 

mv prepared_struct.pdb ../

cd $parent_dir
