#!/bin/bash
#SBATCH -A project_XXXXXXXXX
#SBATCH -p dev-g
#SBATCH --time 2:00:00
#SBATCH --tasks-per-node 1
#SBATCH --cpus-per-task=14
#SBATCH --gpus-per-node 2
#SBATCH --nodes 1
#SBATCH --mem 120G

# Set MIOPEN temp folder
MIOPEN_DIR=$(mktemp -d)
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_DIR/cache
export MIOPEN_USER_DB=$MIOPEN_DIR/config

# We use the PyTorch container provided by the LUMI AI Factory Services, which contains vLLM.
export CONTAINER_IMAGE=/appl/local/laifs/containers/lumi-multitorch-u24r70f21m50t210-20260415_130625/lumi-multitorch-full-u24r70f21m50t210-20260415_130625.sif
module use /appl/local/laifs/modules
module load lumi-aif-singularity-bindings

# Where to store the huge models. Point this to your project's scratch directory.
export HF_HOME=/scratch/$SLURM_JOB_ACCOUNT/hf-cache/

# Make sure vLLM only sees available GPU(s)
export HIP_VISIBLE_DEVICES=$ROCR_VISIBLE_DEVICES

# Generate the API key
export API_KEY=$(openssl rand -hex 16)

echo "================================================================="
echo "🔑 YOUR SUPER SECRET API KEY FOR THIS SESSION IS:"
echo $API_KEY
echo "================================================================="

# Start vLLM
srun singularity run $CONTAINER_IMAGE ./run-vllm-process.sh Qwen/Qwen3-Coder-30B-A3B-Instruct \
 --api-key $API_KEY \
 --enable-auto-tool-choice \
 --tool-call-parser qwen3_coder
