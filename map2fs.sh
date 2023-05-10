#!/bin/bash

##################################################
# Needs at least 16gb of memory                  #
# qsub -l 'walltime=01:00:00,mem=32gb' map2fs.sh #
##################################################

sub='sub-P003'
export SUBJECTS_DIR='/home/control/wousch/Pilot/'$sub'/derivatives/fs/'

fsdir='/home/control/wousch/Pilot/'$sub'/derivatives/fs/'$sub'/'
surfdir=$fsdir'surf/'
if ( [ ! -f $surfdir'lh.smooth.pial' ] ); then
mris_smooth -n 2 $surfdir'lh.pial' $surfdir'lh.smooth.pial'
mris_smooth -n 2 $surfdir'rh.pial' $surfdir'rh.smooth.pial'
fi
rdir='/home/control/wousch/Pilot/'
sdir=$rdir$sub'/'
fdir=$sdir'pipeline1/func/'

declare -a fnr=("task-wmg_run-01" "task-wmg_run-02" "task-wmg_run-03" "task-loc_run-01")
ffile=()
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
ffile[i]=$fdir$sub'_'${fnr[$i]}'_prep.nii.gz'
done


#additional for this subject only, maybe
for (( i=0; i<nses; i++ ));
do
tkregister2 --mov ${ffile[$i]} --s $sub --regheader --noedit --reg $fdir$sub'_'${fnr[$i]}'_fsreg.dat'
#mri_vol2surf --src ${ffile[$i]} --srcreg $fdir$sub'_'${fnr[$i]}'_fsreg.dat' --hemi lh --projfrac 0.15 --out $fdir$sub'_'${fnr[$i]}_lh.wm.mgz
#mri_vol2surf --src ${ffile[$i]} --srcreg $fdir$sub'_'${fnr[$i]}'_fsreg.dat' --hemi rh --projfrac 0.15 --out $fdir$sub'_'${fnr[$i]}_rh.wm.mgz
mri_vol2surf --src ${ffile[$i]} --srcreg $fdir$sub'_'${fnr[$i]}'_fsreg.dat' --hemi lh --projfrac-avg 0 1 0.1 --out $fdir$sub'_'${fnr[$i]}_lh.mgz
mri_vol2surf --src ${ffile[$i]} --srcreg $fdir$sub'_'${fnr[$i]}'_fsreg.dat' --hemi rh --projfrac-avg 0 1 0.1 --out $fdir$sub'_'${fnr[$i]}_rh.mgz
#mri_vol2surf --src ${ffile[$i]} --srcreg $fdir$sub'_'${fnr[$i]}'_fsreg.dat' --hemi lh --projfrac 0.85 --out $fdir$sub'_'${fnr[$i]}_lh.pial.mgz
#mri_vol2surf --src ${ffile[$i]} --srcreg $fdir$sub'_'${fnr[$i]}'_fsreg.dat' --hemi rh --projfrac 0.85 --out $fdir$sub'_'${fnr[$i]}_rh.pial.mgz
done


asegfile=$sdir'/derivatives/nii/aseg.nii.gz'
if ( [ ! -f $asegfile ] ); then
mri_convert $fsdir'mri/aseg.mgz' $asegfile
fi

module load afni

3dresample -master $fdir$sub'_'${fnr[0]}'_T1w.nii.gz' \
-prefix $sdir'/derivatives/nii/aseg-func.nii.gz' \
-rmode NN \
-input $asegfile






