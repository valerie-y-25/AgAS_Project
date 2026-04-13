#!/bin/bash

#SBATCH --nodes=1   # Number of nodes to use
#SBATCH --ntasks-per-node=8   # Use 8 processor cores per node 
#SBATCH --time=1-0:0:0   # Walltime limit (DD-HH:MM:SS)
#SBATCH --mem=120G   # Maximum memory per node
#SBATCH --gres=gpu:a100:1   # Required GPU hardware

module load alphafold3/3.0.1

time alphafold3 --json_path=$PWD/afold3.json --output_dir=$PWD/output

