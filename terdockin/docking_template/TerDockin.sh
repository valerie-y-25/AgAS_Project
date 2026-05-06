#!/bin/bash
#SBATCH --job-name=TerDockin
#SBATCH --output=dock.log
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=0-02:00:00

mkdir $SLURM_ARRAY_TASK_ID
cp -r ./docking_template ./$SLURM_ARRAY_TASK_ID/template
cd $SLURM_ARRAY_TASK_ID/template
/work/LAS/rjpeters-lab/tools/rosettascripts @flags -out:prefix ${SLURM_ARRAY_TASK_ID}_ -out:path:all ../ -parser:protocol dock.xml -nstruct 10 -ignore_zero_occupancy F
cd ..
rm -r template