#!/bin/bash
#this script initalizes the job directories for a DiffDock Probe setup.
#takes in one variable which is the path to the project
#you will need posebusters to run this
#input path of your project here
export WIZARD_PATH="/home/limcaoco/opt/prepare_heteroatoms/"
export PROJ_PATH="/home/limcaoco/opt/prepare_heteroatoms/testdir"
export DIFFDOCK_PATH="/home/limcaoco/opt/DiffDock-L/Diffdock"
##CURRENTLY ONLY WORKS WITH DIFFDOCK-L
echo "PROJ_PATH is ${PROJ_PATH}"


DATE=$(date + '%m%d%Y')
export W_N='DIFFDOCK_PROBE_WIZARD' #wizard name


Innit_Job() {
    mkdir -p ${PROJ_PATH}/bin
    mkdir -p ${PROJ_PATH}/diffdock_inputs
    mkdir -p ${PROJ_PATH}/input_receptors
    mkdir -p ${PROJ_PATH}/outputs
}


Create_DD_Input_Csv() {
    echo "complex_name,protein_path,ligand_description,protein_sequence" > ${PROJ_PATH}/diffdock_inputs/probe_sphere_gen.csv
    DATABASE_DIR=${PROJ_PATH}/input_receptors
    #standardizing input pdb
    #cp ${DATABASE_DIR}/*.pdb ${DATABASE_DIR}/receptor.pdb

    for NAME in ACE BEN CHX IDZ IPA NMA PYR; do
	echo "${NAME},${DATABASE_DIR}/receptor.pdb,${WIZARD_PATH}/probe_structures/${NAME}.sdf," >> ${PROJ_PATH}/diffdock_inputs/probe_sphere_gen.csv 
    done

echo "${W_N}: "
}

Prep_DD_results() {
    for NAME in ACE BEN CHX IDZ IPA NMA PYR; do
	for FILE in ${PROJ_PATH}/outputs/${NAME}/rank*.sdf; do
	    FILE_NAME=$(basename ${FILE})
	    cp ${FILE} ${PROJ_PATH}/outputs/diffdock_output/${FILE_NAME::-4}_${NAME}.sdf
	done
    done
}
PoseBusters() {
    mkdir -p ${PROJ_PATH}/posebuster_inputs
    mkdir -p ${PROJ_PATH}/posebuster_results
    IN_CSV="${PROJ_PATH}/posebuster_inputs/posebuster_input.csv"
    OUT_CSV="posebust_results.csv"
    PRED_PATH=${PROJ_PATH}/outputs/diffdock_output/
    if ! [ -e "${IN_CSV}" ]; then
	echo "creating PB input file..."
	echo "mol_cond,mol_pred"> ${IN_CSV}
	for FILE in ${PRED_PATH}/*.sdf; do
	    echo "${PROJ_PATH}/input_receptors/receptor.pdb,${FILE}" >> ${IN_CSV}
	done
    fi

    #running PB
    bust -t ${IN_CSV} --outfmt csv > ${PROJ_PATH}/posebuster_results/${OUT_CSV}
    PB_RESULTS_PATH=${PROJ_PATH}/posebuster_results/
    OUT_DIR=${PB_RESULTS_PATH}/applied_filters
    mkdir -p $OUT_DIR
    PROBE_DIR=${PROJ_PATH}/outputs/diffdock_output/cleaned_probes
    mkdir -p $PROBE_DIR
    
    python apply_pb_filter.py -i ${PB_RESULTS_PATH}/posebust_results.csv -o ${OUT_DIR}/PB_file.csv -f all -d ${PROBE_DIR}
}


Run_clustering() {
    cp ${PROJ_PATH}/input_receptors/receptor.pdb ${PROJ_PATH}/outputs/diffdock_output/cleaned_probes
    bash ${WIZARD_PATH}/bin/prepare_hetatms.sh -p ${PROJ_PATH}/outputs/diffdock_output/cleaned_probes -c 10 -s "SMINA" -n 4
    mkdir -p ${PROJ_PATH}/docked_probes/
    cp ${PROJ_PATH}/outputs/diffdock_output/cleaned_probes/SMINA_rescore/prepared_structure.pdb ${PROJ_PATH}/docked_probes/prepared_structure.pdb
}
    
#first prompt
echo "For any bugs please contact: Jose Miguel Limcaoco @ limcaoco@umich.edu"

PS3='${W_N}: What would you like to do?'
options=("Initialize Job" "Setup DiffDock job" "Run Probe Clustering" "Quit")
select opt in "${options[@]}"; do
    case $opt in
	"Initialize Job")
	    echo "${W_N}: Initializing diffdock-Probe Job at ${PROJ_PATH}...."
	    Innit_Job
	    echo "${W_N}: Done Initializing job, place receptor as 'receptor.pdb' in the input_receptors file"
	    echo "${W_N}: After doing so please Setup DiffDock Job..."
	    break
	    ;;
	"Setup DiffDock job")
	    echo "${W_N}: setting up DiffDock Job...."
	    echo "${W_N}: creating input_csv and sbatch file for DiffDock"
	    Create_DD_Input_Csv
	    source ${WIZARD_PATH}/bin/diffdock_probe_sbatch_template.sh
	    echo "${W_N}: Done setting up DiffDock Job to run diffdock see"
	    echo "${W_N}: ${PROJ_DIR}/bin/diffdock_probe.sbatch"
	    
	    break
	    ;;
	"Run Probe Clustering")
	    Prep_DD_results
	    echo "${W_N}: Done Prepping results..."
	    echo "${W_N}: PB calculations..."
	    PoseBusters
	    #echo "${W_N}: SMINA calculations..."
	    echo "${W_N}: SMINA Calculations and clustering..."
	    Run_clustering
	    echo "${W_N}: Done! selected probes are in /docked_probes"
	    break
	    ;;
	"Quit")
	    break
	    ;;
	*) echo "invalid option ${REPLY}";;
    esac
done
