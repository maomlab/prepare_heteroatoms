#!/bin/bash
#


mkdir -p ${PROJ_PATH}/bin

FILE="diffdock_output"
IN_PATH=${PROJ_PATH}/diffdock_inputs
OUT_PATH=${PROJ_PATH}/outputs
PATH_TO_DIFFDOCK=${DIFFDOCK_PATH}

cat > ${PROJ_PATH}/bin/diffdock_probe.sbatch <<EOF
#!/bin/bash
#
#SBATCH --job-name=DiffDOCK-probe
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=0-2:00:00
#SBATCH --account=sigbio_project20
#SBATCH --partition=sigbio_gpu
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-gpu=24000m
#SBATCH --output=diffdock_l_slurm.log


mkdir -p ${OUT_PATH}/${FILE}

    
cd ${PATH_TO_DIFFDOCK}
pwd

#now running diffdock
python -m inference --config ${WIZARD_PATH}/bin/probe_inference_args.yaml --protein_ligand_csv ${IN_PATH}/probe_sphere_gen.csv --out_dir ${OUT_PATH}/
cd - 

EOF
