#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=12
#SBATCH --ntasks-per-node=1
#SBATCH --partition=gpu
#SBATCH --gres=gpu:v100-sxm2:1
#SBATCH --mem=40G
#SBATCH --time=08:00:00
#SBATCH --output=logs/tau_final_%j.out
#SBATCH --error=logs/tau_final_%j.err
#SBATCH --job-name=tau_af2

# Set CORRECT paths - using /scratch not /home
PROJECT_DIR=/scratch/murugan.g/tau_alphafold_project
OUTPUT_DIR=${PROJECT_DIR}/output
INPUT_DIR=${PROJECT_DIR}/input
FASTA_NAME=tau_sequence.fasta
CONTAINER_PATH=/shared/container_repository/Alphafold-2.3.1
CONTAINER_NAME=alphafold-2.3.1.sif

export SINGULARITYENV_TF_FORCE_UNIFIED_MEMORY=1
export SINGULARITYENV_XLA_PYTHON_CLIENT_MEM_FRACTION=4.0
export ALPHAFOLD_DATA_PATH="/shared/container_repository/Alphafold-2.3.1/2.3.1"

echo "Starting AlphaFold prediction for Tau protein"
echo "Project directory: ${PROJECT_DIR}"
echo "Input directory: ${INPUT_DIR}"
echo "FASTA file: ${INPUT_DIR}/${FASTA_NAME}"
echo "Output directory: ${OUTPUT_DIR}"
echo "Start time: $(date)"

# Verify files exist
if [ ! -f "${INPUT_DIR}/${FASTA_NAME}" ]; then
    echo "ERROR: FASTA file not found at ${INPUT_DIR}/${FASTA_NAME}"
    exit 1
else
    echo "FASTA file found successfully!"
fi

# Create output directory if it doesn't exist
mkdir -p ${OUTPUT_DIR}

# Run AlphaFold with proper path binding
singularity exec --nv \
    --bind /scratch:/scratch \
    --bind /shared:/shared \
    --bind ${ALPHAFOLD_DATA_PATH}:/data \
    ${CONTAINER_PATH}/${CONTAINER_NAME} \
    /app/run_alphafold.sh \
    --fasta_paths=${INPUT_DIR}/${FASTA_NAME} \
    --max_template_date=2022-01-01 \
    --output_dir=${OUTPUT_DIR} \
    --data_dir=/data \
    --uniref90_database_path=/data/uniref90/uniref90.fasta \
    --uniref30_database_path=/data/uniref30/UniRef30_2021_03 \
    --pdb70_database_path=/data/pdb70/pdb70 \
    --mgnify_database_path=/data/mgnify/mgy_clusters_2022_05.fa \
    --template_mmcif_dir=/data/pdb_mmcif/mmcif_files \
    --obsolete_pdbs_path=/data/pdb_mmcif/obsolete.dat \
    --bfd_database_path=/data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
    --use_gpu_relax \
    --db_preset=full_dbs \
    --model_preset=monomer

echo "AlphaFold completed at: $(date)"
