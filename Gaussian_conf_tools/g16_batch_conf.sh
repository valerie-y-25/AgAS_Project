#!/bin/bash

#SBATCH --partition=nova
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=40G
#SBATCH --time=2-00:00:00

module load gaussian/16-C.01-3yzt2xl

g16 conf$SLURM_ARRAY_TASK_ID.com
