#!/bin/bash
#SBATCH --job-name=alphafold3
#SBATCH --account=s2026.bcb.5460.01
#SBATCH --partition=instruction
#SBATCH --qos=instruction
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=1
#SBATCH --time=1-0:00:00
#SBATCH --mem=48G
#SBATCH --gres=gpu:1
#SBATCH --output=afold3-%j.out
#SBATCH --error=afold3-%j.err

module load alphafold3/3.0.1
time alphafold3 --json_path=$PWD/afold3.json --output_dir=$PWD/output
