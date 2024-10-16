#!/bin/bash
#

RECEPTOR=${1}
LIGAND_DATABASE=${PROJ_DIR}/intermediate_files/prepared_ligand_libraries/${2}
OUT_DIR=${3}
IN_DIR=${4}
LIGAND_DOCK_JOB_NAME=${5}
DATE=${6}
for LIGAND in $(cat ${LIGAND_DATABASE}/ligand_list.txt);
do

mkdir ${OUT_DIR}/${LIGAND}
mkdir ${OUT_DIR}/${LIGAND}/out_files
mkdir ${OUT_DIR}/${LIGAND}/pdbs
mkdir ${OUT_DIR}/${LIGAND}/log_files

cat > ${PROJ_DIR}/rosetta_runs/ligand_docking_runs/${LIGAND_DOCK_JOB_NAME}_${DATE}/input_files/sbatch_files/${LIGAND}_dock_${RECEPTOR}.sbatch <<EOF
#!/bin/bash
#
#SBATCH --job-name=${LIGAND}_dock
#SBATCH --ntasks=1
#SBATCH --array=1-20
#SBATCH --account=maom0
#SBATCH --nodes=1
#SBATCH --output=docking_slrm.log
#SBATCH --mem-per-cpu=5g
#SBATCH --time=01-12:00:00
#SBATCH --partition=standard
#SBATCH --mail-user=limcaoco@med.umich.edu
#SBATCH --mail-type=END,FAIL
# more robust error handling
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
#load gcc vers 4.8.5
module load gcc/4.8.5
##
## Run ligand_docking
##
JOB_ID=\${SLURM_JOB_ID}
TASK_ID=\${SLURM_ARRAY_TASK_ID}
LIGAND=${LIGAND}
DATE=${DATE}

${PATH_TO_ROSETTA}/main/source/bin/rosetta_scripts.default.linuxgccrelease \
    -database ${PATH_TO_ROSETTA}/main/database \
    @ ${ROSETTA_DOCK}/scripts/options/docking.options \
    -parser:protocol ${ROSETTA_DOCK}/scripts/rosetta_xml_scripts/ligand_dock_pre_pos.xml \
    -in:file:s ${LIGAND_DATABASE}/receptor_ligand_structs/${RECEPTOR}_docking_${LIGAND}.pdb \
    -in:file:extra_res_fa ${LIGAND_DATABASE}/params/${LIGAND}.params \
    -run:jran \${JOB_ID} \
    -out:nstruct 5 \
    -out:level 300 \
    -out:prefix \${JOB_ID}_\${TASK_ID}_ \
    -out:file:silent ${OUT_DIR}/${LIGAND}/out_files/ldock_${DATE}_${LIGAND}_${RECEPTOR}_\${JOB_ID}_\${TASK_ID}.out \
    > ${OUT_DIR}/${LIGAND}/log_files/ldock_${LIGAND}_${RECEPTOR}_\${JOB_ID}_\${TASK_ID}.log

##
## creating .err file from STDERR
##
command 2> ${SCRATCH_DIR}/ldock_\${JOB_ID}_\${TASK_ID}.err
command 1> ${SCRATCH_DIR}/ldock_\${JOB_ID}_\${TASK_ID}.txt

EOF
done

cat > rosetta_runs/ligand_docking_runs/${LIGAND_DOCK_JOB_NAME}_${DATE}/1_run.sh <<EOF
#!/bin/bash
#

for LIGAND_SBATCH_FILE in ${IN_DIR}/sbatch_files/*;
do

sbatch \${LIGAND_SBATCH_FILE}
echo "Submitting \${LIGAND_SBATCH_FILE} job to the SLURM cluster"

done 

echo "Finished submitting SLURM jobs"
echo "Check status with squeue -u username"
echo "Possible errors will be found in docking_slurm.log"


EOF

cat > rosetta_runs/ligand_docking_runs/${LIGAND_DOCK_JOB_NAME}_${DATE}/2_collect.sh <<EOF
#!/bin/bash
#

for LIGAND_SBATCH in ${OUT_DIR}/*;
do

cd \${LIGAND_SBATCH}/pdbs
bash ${ROSETTA_DOCK}/scripts/get_pdbs_adv.sh -top -total_score  ${PROJ_DIR}/rosetta_runs/ligand_docking_runs/${LIGAND_DOCK_JOB_NAME}_${DATE}/ligand_params.options
cd ${PROJ_DIR}

done


EOF


#making ligand_params.options file

echo "" > ${PROJ_DIR}/rosetta_runs/ligand_docking_runs/${LIGAND_DOCK_JOB_NAME}_${DATE}/ligand_params.options 

for PARAMS in ${LIGAND_DATABASE}/params/*.params; do
echo "-in:file:extra_res_fa ${PARAMS}" >> ${PROJ_DIR}/rosetta_runs/ligand_docking_runs/${LIGAND_DOCK_JOB_NAME}_${DATE}/ligand_params.options
done


#need to write a script for clustering 

