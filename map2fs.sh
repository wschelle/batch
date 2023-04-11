#!/bin/bash

###############################
#Needs at least 16gb of memory#
###############################
sub='Pilot002'
export SUBJECTS_DIR='/home/control/wousch/Pilot/'$sub'/derivatives/fs/'

fsdir='/home/control/wousch/Pilot/'$sub'/derivatives/fs/'$sub'/'
surfdir=$fsdir'surf/'
#mris_smooth -n 2 $surfdir'lh.pial' $surfdir'lh.smooth.pial'
#mris_smooth -n 2 $surfdir'rh.pial' $surfdir'rh.smooth.pial'
rdir='/home/control/wousch/Pilot/'
sdir=$rdir$sub'/'

declare -a fnr=("wm1" "wm2" "wm3" "loc")
#declare -a fnr=("wm2" "wm3")
ffile=()
fdir=()
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
fdir[i]=$sdir'func/'${fnr[$i]}'/'
ffile[i]=${fdir[$i]}${fnr[$i]}'-prep.nii.gz'
done


#additional for this subject only, maybe
for (( i=0; i<nses; i++ ));
do
tkregister2 --mov ${ffile[$i]} --s $sub --regheader --noedit --reg ${fdir[$i]}'fsreg.dat'
#mri_vol2surf --src ${ffile[$i]} --srcreg ${fdir[$i]}'fsreg.dat' --hemi lh --projfrac 0.15 --out ${fdir[$i]}${fnr[$i]}-wm-lh.mgz
#mri_vol2surf --src ${ffile[$i]} --srcreg ${fdir[$i]}'fsreg.dat' --hemi rh --projfrac 0.15 --out ${fdir[$i]}${fnr[$i]}-wm-rh.mgz
mri_vol2surf --src ${ffile[$i]} --srcreg ${fdir[$i]}'fsreg.dat' --hemi lh --projfrac-avg 0 1 0.25 --interp trilinear --out ${fdir[$i]}${fnr[$i]}-lh.mgz
mri_vol2surf --src ${ffile[$i]} --srcreg ${fdir[$i]}'fsreg.dat' --hemi rh --projfrac-avg 0 1 0.25 --interp trilinear --out ${fdir[$i]}${fnr[$i]}-rh.mgz
#mri_vol2surf --src ${ffile[$i]} --srcreg ${fdir[$i]}'fsreg.dat' --hemi lh --projfrac 0.85 --out ${fdir[$i]}${fnr[$i]}-pial-lh.mgz
#mri_vol2surf --src ${ffile[$i]} --srcreg ${fdir[$i]}'fsreg.dat' --hemi rh --projfrac 0.85 --out ${fdir[$i]}${fnr[$i]}-pial-rh.mgz
done


asegfile=$sdir'/derivatives/nii/aseg.nii.gz'
if ( [ ! -f $asegfile ] ); then
mri_convert $fsdir'mri/aseg.mgz' $asegfile
fi

module load afni

3dresample -master ${fdir[0]}${fnr[0]}'-t1w.nii.gz' \
-prefix $sdir'/derivatives/nii/aseg-func.nii.gz' \
-rmode NN \
-input $asegfile






