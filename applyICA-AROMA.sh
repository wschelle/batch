#!/bin/bash

##Run like so:
##qsub -l 'nodes=1:ppn=2,walltime=06:00:00,mem=64gb' applyICA-AROMA.sh

#################################
## Fill out subject specs here ##
#################################

module load afni
module load anaconda3
source activate venv2

rdir='/home/control/wousch/Pilot/'
sub='sub-P003'
sdir=$rdir$sub'/'

#declare -a fnr=("task-wmg_run-01" "task-wmg_run-02" "task-wmg_run-03" "task-loc_run-01")
declare -a fnr=("task-wmg_run-01" "task-wmg_run-02" "task-wmg_run-03")
#declare -a fnr=("task-loc_run-01")
ffile=()
ffile0=()
fdirraw=$sdir'raw/func/'
fdir=$sdir'pipeline1/func/'
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
ffile[i]=$fdir$sub'_'${fnr[$i]}'_prep.nii.gz'
done

for (( i=0; i<nses; i++ ));
do
ffile2[i]=$fdir$sub'_'${fnr[$i]}'_prepavg.nii.gz'
ffile3[i]=$fdir$sub'_'${fnr[$i]}'_prepavgbet.nii.gz'
if ( [ ! -f ${ffile3[$i]} ] ); then
3dTstat -mean \
-prefix ${ffile2[$i]} \
 ${ffile[$i]}

bet ${ffile2[$i]} ${ffile3[$i]} -f 0.3 -n -m -R
fi
done

for (( i=0; i<nses; i++ ));
do
python3 /home/control/wousch/Python/ICA-AROMA-master/ICA_AROMA.py -in ${ffile[$i]} -out $fdir'ICA_AROMA_'${fnr[$i]} -mc $fdir$sub'_'${fnr[$i]}'_mp' -m $fdir$sub'_'${fnr[$i]}'_prepavgbet_mask.nii.gz'
done

