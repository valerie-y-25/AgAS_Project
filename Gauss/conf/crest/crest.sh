#!/bin/bash
#SBATCH --job-name=crest
#SBATCH --output=crest.log
#SBACTH --cpus-per-task=32
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-24:00:00
#SBATCH --partition=nova

#Run this script in an empty directory with the .log file output of a gaussian run
# to generate conformers; Generates a lot of other files as well so put it on its own
#
# EXPECTED FILE STRUCTURE
# conf/
# --crest/
# --conf-opt/

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/work/LAS/rjpeters-lab/tools/bin/openbabel-install/lib
export BABEL_LIBDIR=/work/LAS/rjpeters-lab/tools/bin/openbabel-install/lib/openbabel/3.1.0
export BABEL_DATADIR=/work/LAS/rjpeters-lab/tools/bin/openbabel-install/share/openbabel/3.1.0
/work/LAS/rjpeters-lab/tools/bin/openbabel-install/bin/obabel -ig16 ${filename}.log -oxyz -O ${filename}.xyz

/work/LAS/rjpeters-lab/tools/bin/crest ${filename}.xyz -T 32
 
cp crest_conformers.xyz ../conf-opt

cd ../conf-opt

bash ${tools}/Gaussian_conf_tools/conf_to_g16.sh ${filename}.com crest_conformers.xyz
