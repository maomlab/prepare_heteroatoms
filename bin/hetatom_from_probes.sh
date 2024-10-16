#!/bin/bash
SCRIPT_NAME=$(basename "$0")
parent_dir=$(readlink -f $0 | xargs dirname)
while getopts p:r: FLAG
do
    case "${FLAG}" in
	p) prediction_dir=${OPTARG};;
	r) receptor=${OPTARG};;
    esac
done

if [ -z ${prediction_dir} ]; then
    echo "${SCRIPT_NAME}: ERROR: no prediction directory given exiting..."
    exit
fi
echo "${SCRIPT_NAME}: LOG: prediction_dir = ${prediction_dir}"
echo "${SCRIPT_NAME}: LOG: receptor = ${receptor}"
echo "${SCRIPT_NAME}: LOG: now merging probe directories for ${receptor}"
PROBE_FILE=$(cat "${parent_dir}/probes.csv") 


mkdir -p  ${prediction_dir}/probe_predictions/${receptor}_probe_predictions

for PROBE_DIR in ${prediction_dir}/index*;
do
    DD_DIR_NAME=$(basename ${PROBE_DIR})        

    if [[ "${DD_DIR_NAME}" != *"${receptor}"* ]]; then
	continue
    fi
    
    for PROBE in ${PROBE_FILE};
    do	
	if [[ "$DD_DIR_NAME" ==  *"${PROBE}"* ]]; then
	    if [ "${PROBE}" == "OC1=CC=CC=C1" ]; then
		PROBE_TAG="PHE"
	    elif [ "${PROBE}" == "C1=CC=CC=C1" ]; then
		PROBE_TAG="BEN"
	    elif [ "${PROBE}" == "C1CCCCC1" ]; then
		PROBE_TAG="CHX"
	    elif [ "${PROBE}" == "CC(NC)=O" ]; then
		PROBE_TAG="NMA"
	    elif [ "${PROBE}" == "CC([O-])=O" ]; then
		PROBE_TAG="ACE"
	    elif [ "${PROBE}" == "CC(O)C" ]; then
		PROBE_TAG="IPA"
	    elif [ "${PROBE}" == "C1=CC=NC=N1" ]; then
		PROBE_TAG="PYR"
	    elif [ "${PROBE}" == "C1=CN=CN1" ]; then
		PROBE_TAG="IDZ"
	    else
		PROBE_TAG="UNK"
	    fi
	fi
    done

    for FILE in "${PROBE_DIR}"/*.sdf;
    do
	BASE_FILE=$(basename $FILE)
	cp "${FILE}" "${prediction_dir}/probe_predictions/${receptor}_probe_predictions/${BASE_FILE%.sdf}_${PROBE_TAG}.sdf"
    done
    
done
