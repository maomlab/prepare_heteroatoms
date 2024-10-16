#!/bin/bash
###########################

#added some boring command line argument passing stuff -ml 
SCRIPT_NAME=$(basename "$0")
while  getopts p:c:s:n FLAG
do

    case "${FLAG}" in
	p) prediction_dir=${OPTARG};;
	c) cube_dist=${OPTARG};;
	s) score_type=${OPTARG};;
	n) n_clust=${OPTARG};;
    esac
done

if [ -z ${prediction_dir} ]; then
    echo "${SCRIPT_NAME}: ERROR: no prediction directory given exiting..."
    exit
fi

if [ -z ${cube_dist} ]; then
    echo "${SCRIPT_NAME}: WARNING: cube_dist variable is empty. defaulting to 5"
    cube_dist=5
fi

if [ -z ${n_clust} ]; then
    echo "${SCRIPT_NAME}: WARNING: n_clust variable is empty. defaulting to 3"
    n_clust=3
fi

if [ -z ${score_type} ]; then
    echo "${SCRIPT_NAME}: WARNING: score_type variable is empty. defaulting to DD_Con"
    score_type="DD_con"
fi
if [[ "${score_type}" == "DDcon" || "${score_type}" ==  "SMINA" ]]; then
    continue
else
    echo "${SCRIPT_NAME}: WARNING: score_type '${score_type}' invalid. defaulting to DD_con"
    score_type="DD_con"
fi

    

echo "${SCRIPT_NAME}: LOG: Preparing HetAtoms with the following parameters: "
echo "prediciton_dir: ${prediction_dir}"
echo "cube_dist: ${cube_dist}"
echo "n_clust: ${n_clust}"
echo "score_type: ${score_type}"
##########################
# prepare pdb with rec atoms and lig hetatoms for docking pdb ready for docking called 'prepared_struct.pdb' in prediction_dir

# FILL IN prediction_dir, cube_dist, and n_clust

# set directory where the diffdock predictions and receptor pdb live
#prediction_dir=$PWD/

# set size of cube (distance in either direction from center of cube)
#cube_dist=

# set number of clusters for clustering (and thus the number of predictions in final pdb for docking)
#n_clust=

parent_dir=$(readlink -f $0 | xargs dirname)

rec_pdb=$prediction_dir/*.pdb

#IF CHOSEN SMINA USE SMINA DIRECTORY OR CALCULATE SMINA SCORES...
if [ "${score_type}" == "SMINA" ]; then
    if [ -d "${prediction_dir}/SMINA_rerank" ]; then
	new_dir=${prediction_dir}/SMINA_rerank
	prediction_dir=${new_dir}
    else
	echo "${SCRIPT_NAME}: calculating binding affinity with smina... "
	source ${parent_dir}/smina_rescore.sh -d ${prediction_dir}
	new_dir=${prediction_dir}/SMINA_rerank
	prediction_dir=${new_dir}
    fi
elif [ "${score_type}" == "DDcon" ]; then
    prediction_dir=${prediction_dir}
fi

echo "Now using ${prediction_dir}"
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

echo "${SCRIPT_NAME}: LOG: Finished preparing HetAtoms!"
