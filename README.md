# AgAS_Project
## WORKFLOW

This document describes the computational methods we used to replicate the analyses from *Peeking behind the carbocation: identification of (alternative) catalytic bases in the class II active site of conifer resin acid diterpene synthases*.

We focused on the computational aspects of this paper. We did not replicate the mutation or wet-lab portions.

The computational pipeline summarized:

1.  Protein Modeling
2.  Conformer Library Preparation
3.  TerDockin Preparation and Batch Jobs
4.  Filtering Results
5.  Analyze Results

------------------------------------------------------------------------

### 1. Protein Modeling

**This step uses the `alphafold` folder in our repository.**

The protein structure can be obtained from the RCSB Protein Data Bank (Midwest Center for Structural Genomics).

Link: <https://www.rcsb.org/structure/3S9V>

It can also be generated using AlphaFold3. We used the `afold3.json` and `afold3.sh` template. In `afold3.json`, we replaced the sequence with the NIH protein sequence for abietadiene cyclase [Abies grandis]. In `afold3.sh`, we updated the template so that the output would go to our **output/agas** folder.

Output from AlphaFold3 returns several folders and files. Most importantly, `agas_ranking_scores.csv` and `seed-x-sample-x` folders. There were 6 seeds and 5 samples each.

`agas_ranking_scores.csv` shows seed, sample, and ranking score for each. The highest score is best. This Unix command returned seed 5, sample 3 as the highest score. Looking into that folder, we downloaded `agas_seed-5_sample-3_model.cif` (renamed to `AgAS.pdb`. The .cif file was converted into .pdb format and viewed using PyMOL.

``` bash
$ sort -t, -k3,3nr agas_ranking_scores.csv | head
$ cd seed-5_sample-3
$ ls
```

### 2. Conformer Library Preparation

Here, we create a conformer library for the reactive intermediate labled **A** in the paper, labda-13E-en-15-PP-8-yl carbocation.

**This step uses the `Gauss` folder in our repository.**

#### 2A: GaussView – Creating the substrate of interest

Using GaussView software, we built the carbon skeleton of intermediate **A**. This carbocation intermediate formed during the cyclization reaction before the final deprotonation step, shown in *Figure 1* in the original paper. This is also shown in our slideshow.

After building the structure, we saved it as a Gaussian input file: `AgAS_A1.com`

#### 2B: Optimization – Preparing the structure for conformer generation

We edited `run_g16.sh` using nano and changed the file to the output file from GaussView, `AgAS_A1.com`.

``` bash
$ cp Gaussian_conf_tools/run_g16.sh
$ nano run_g16.sh
$ sbatch run_g16.sh
$ squeue --m
```

This submitted the Gaussian optimization job and produced a log file, `AgAS_A1.log`.

#### 2C: Generate conformers — Generate and optimize conformer structures

Here we make the directory `conf` in `Gauss` folder and `conf/crest` and `conf/conf-opt`. We copy the `AgAS_A1.log` file into both folders and run the shell script `crest.sh`. This also requires the `Gaussian_conf_tools` folder.

`AgAS_A1.log` is provided by **Stage 2B**

``` bash
$ export filename="AgAS_A1"

$ mkdir conf
$ mkdir conf/crest
$ mkdir conf/conf-opt

$ cp ${filename}.log conf/crest
$ cp ${filename}.com conf/conf-opt

$ cd conf/crest
$ cp $tools/Gaussian_conf_tools/crest.sh .
$ sbatch crest.sh
```

The `crest.sh` job generates possible conformers of the intermediate. After it finishes, the conformer files will be placed in conf/conf-opt folder.

Next, the conformers need to be optimized with Gaussian.

``` bash
$ sbatch --array=1-<n> run_g16.sh 
```

n = number of conformer `.com` files Now the Gaussian output files will be combined and filtered.

``` bash
$ obabel -ig16 *.log -omol2 -O confs.xyz --align
$ $tools/conf_filt confs.xyz
$ obabel -ixyz filtConfs.xyz -omol2 -O filtConfs.mol2 --recharge
```

Lastly, we generate Rosetta parameter files from the filtered conformers. This step prepares the ligand so that Rosetta can recognize it during docking.

### 3. TerDockin Preparation and Batch Jobs

**We are here: `terdockin/docking_template`**

This is the TerDockin setup. Each docking run required a template folder containing the protein structure, ligand parameter files, constraint files, Rosetta control files, and the submission script used to launch the docking jobs on Nova.

Here is the general folder structure.

``` bash
docking_template/
  AgAS.pdb
  dock.resfile
  dock.cst
  dock.xml
  TerDockin.sh
  flags 
  params/
      X00.params
      Y00.params
      Y00_conformers.pdb 
      Z00.params
```

-   `AgAS.pdb`: protein structure file from Midwest Center for Structural Genomics

-   `dock.resfile`: specifies which amino acid chains Rosetta can modify during docking

-   `dock.cst`: defines mechanistic/geometric constraints during docking

-   `dock.xml`: specifies the Rosetta protocol, including docking setup and starting coordinates

-   `TerDockin_nova.sh`:used to submit docking jobs as a SLURM array

-   `X00.params`: pyrophosphate ligand parameter file

-   `Y00.params`: carbocation ligand parameter file from Gaussian, `Y00_conformers.pdb` is the associated conformer PDB

-   `Z00.params`: water ligand parameter file

Here is the command used after the template folder is created. We submitted the docking jobs as a SLURM array. The SLURM array generated many docking structures which were then scored and filtered.

``` bash
sbatch –array=1-100 template/TerDockin_nova.sh
squeue --m
```

### 4. Filtering Results

After TerDockin finishes, the docking outputs have to be filtered to keep the best docking poses that satisfied the constraints and have best energy scores. Following the TerDockin workflow, score files from the docking sub-directories are converted into .csv file format and examined using filtering scripts.

We retained structures that satisfied the geometric constraints and showed favorable docking and interface interaction scores.

### 5. Analyze Results

The filtered docking results were inspected structurally in molecular visualization software (ChimeraX and PyMOL). We unfortunately had inconsistencies in our docked carbocation with positions varying from the paper's results. This was most likely due to adjusting constraint files in `dock.cst` differently from the original paper.

### Note on our workflow and paper's documentation

[Discussed in our presentation]

The public Figshare repository provided the intermediate computational files and workflow materials necessary to understand and reproduce the docking analyses. Their README explained the directory structure clearly, which made the workflow easier to reproduce.

-   `Intermediate_A_conformers.zip` contained the Gaussian-optimized carbocation intermediates and conformer library used for docking.

-   `Rosetta_Docking.zip` contained the TerDockin/Rosetta docking workflows, constraint files, docking templates, and the final results for docked structure outputs.

There were two issues with their workflow that we ran into.

1.  The information they published was clear, but it would require high computational experience to recreate the scripts. Instead, we had access to the TerDockin Manual with the scripts needed from Dr. Peters’ lab through Nesreen.

2.  A lot of the software required a license to use. We used Nesreen’s license for PyMol and Gaussian. AlphaFold we could acquire through ISU. Also, TerDockin needs a lot of computing space and lab-level HPC resources.

