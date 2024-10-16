#!/bin/bash

# prepare pdb with rec atoms and lig hetatoms for docking pdb ready for docking called 'prepared_struct.pdb' in prediction_dir

# FILL IN prediction_dir, cube_dist, and n_clust

# set directory where the diffdock predictions and receptor pdb live
prediction_dir=$PWD/testdir

# set size of cube (distance in either direction from center of cube)
cube_dist=10

# set number of clusters for clustering (and thus the number of predictions in final pdb for docking)
n_clust=3

parent_dir=$PWD

rec_pdb=$prediction_dir/*.pdb

# remove hetatms from rec pdb
python $parent_dir/rmv_hetatms.py $rec_pdb

# build cube around rank1 prediction to get predictions to cluster
python $parent_dir/make_cube.py $prediction_dir $cube_dist

# hierarchical clustering to get 3 similar but distinct sdfs (highest ranking predictions)
python $parent_dir/new_cluster_preds.py $prediction_dir $n_clust

# convert the n_clust sdf predictions to pdbs
source $parent_dir/obabel_to_pdb.sh $prediction_dir $parent_dir

# obabel to combine lig pdbs with rec pdb
source $parent_dir/comb_pdbs.sh $prediction_dir $parent_dir
