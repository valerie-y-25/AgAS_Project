#!/bin/bash
# RUN THIS SCRIPT ONLY ONCE - MORE WILL ADD EXTRA LINES TO BASHRC
# Once this script has been run, you will need to run "source ~/.bashrc" in the terminal

#ADD PATH TO BASHRC
echo "" >> ~/.bashrc
echo "# Add tools folder bin to PATH" >> ~/.bashrc
echo "" >> ~/.bashrc

echo "export PATH=\"/lustre/hdd/LAS/rjpeters-lab/tools/bin/:$PATH\"" >> ~/.bashrc

#ADD USEFUL SHORTCUTS TO BASHRC
echo "" >> ~/.bashrc
echo "# Useful Shortcuts" >> ~/.bashrc
echo "" >> ~/.bashrc

echo "export lss=\"/lss/research/rjpeters-lab\"" >> ~/.bashrc
echo "export work=\"/lustre/hdd/LAS/rjpeters-lab/\"" >> ~/.bashrc
echo "export tools=\"/lustre/hdd/LAS/rjpeters-lab/tools\"" >> ~/.bashrc
echo "export conftools=\"/lustre/hdd/LAS/rjpeters-lab/tools/Gaussian_conf_tools\"" >>~/.bashrc
echo "export rosbin=\"/lustre/hdd/LAS/rjpeters-lab/tools/Rosetta/rosetta.binary.linux.release-356/main/source/bin\"" >> ~/.bashrc
echo "export rostools=\"/lustre/hdd/LAS/rjpeters-lab/tools/rosetta.binary.linux.release-356/main/tools/\"" >>~/.bashrc

#ADD SHORTCUT TO molfile_to_params.py SCRIPT TO BASHRC
echo "alias mol_to_params=\"python /lustre/hdd/LAS/rjpeters-lab/tools/Rosetta/rosetta.binary.linux.release-356/main/source/scripts/python/public/molfile_to_params.py\"" >> ~/.bashrc

#MAKE SURE USER FOLDER HAS BEEN CREATED
mkdir /lustre/hdd/LAS/rjpeters-lab/$USER

#ADD CDW COMMAND TO BASHRC
echo "alias cdw=\"cd /lustre/hdd/LAS/rjpeters-lab/$USER/\"" >> ~/.bashrc
echo "Before the changes will take effect run the command \"source ~/.bashrc\""