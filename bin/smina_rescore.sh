#!/bin/bash

# written by Jose Miguel Limcaoco limcaoco@umich.edu

SCRIPT_NAME=$(basename "$0")
###########################################################
#input handeling
while  getopts d FLAG
do
    case "${FLAG}" in
	d) prediction_dir=${OPTARG};;
    esac
done


if [ -z ${prediction_dir} ]; then
    echo "${SCRIPT_NAME}: ERROR: no prediction directory given exiting..."
    exit
fi


###########################################################


SMINA_DIR=${WIZARD_PATH}/smina

echo "original_name, smina_affinity" > smina_relax_affinities.csv

echo "${prediction_dir}"
for POSE in ${prediction_dir}/*.sdf; do

    echo "${POSE}"
    
    ${SMINA_DIR}/smina --receptor ${prediction_dir}/receptor.pdb \
		    --ligand ${POSE} \
		    --minimize \
		    --log smina_relax.log

   
    AFFINITY=$(grep "^Affinity: " smina_relax.log)
    REAL_AFFINITY=$(echo ${AFFINITY} | awk '{print $2}' )

    echo "${POSE},${REAL_AFFINITY}" >> smina_relax_affinities.csv
done

#find new order...
sort -t',' -k2 -n smina_relax_affinities.csv > resort_temp.csv

#now resorting files...
mkdir -p ${prediction_dir}/SMINA_rerank
cp ${prediction_dir}/*.pdb ${prediction_dir}/SMINA_rerank/. 

read header < resort_temp.csv

RANK=1
while IFS=',' read -r FILE_NAME AFFINITY; do

    PID_TEMP="${FILE_NAME##*_}"
    PID="${PID_TEMP%.sdf}"
    
    NEW_FILE="rank${RANK}_confidence${AFFINITY}_${PID}.sdf"
    echo "${NEW_FILE}"
    cp ${FILE_NAME} ${prediction_dir}/SMINA_rerank/${NEW_FILE}

    ((RANK++))
done < resort_temp.csv 

#cleaning everything up...
rm *.csv
