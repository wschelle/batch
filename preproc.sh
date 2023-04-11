#!/bin/bash

#################################
## Fill out subject specs here ##
#################################
rdir='/home/control/wousch/Pilot/'
sub='Pilot002'
sdir=$rdir$sub'/'

t1nr='T1'
apnr='topup'

declare -a fnr=("wm1" "wm2" "wm3" "loc") 
declare -a refscan=("402" "450" "450" "180")

## Give here the number of AP scans
multap=10
## if deoblique images then deobl = 1, else deobl = 0
deobl=1

#####################################################
## You can stop filling out specs now. Save & run. ##
#####################################################

#######################################################################
## This block defines some stuff, makes some folders, blah blah blah ##
#######################################################################

## Functionals
ffile=()
ffileph=()
fdir=()
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
fdir[i]=$sdir'func/'${fnr[$i]}'/'
ffile[i]=${fdir[$i]}${fnr[$i]}'.nii.gz'
ffileph[i]=$sdir'func/'${fnr[$i]}'_ph/'${fnr[$i]}'_ph_ph.nii.gz'
done

## ap names
apdir=$sdir'func/'$apnr'/'
apfile=$apdir$apnr'.nii.gz'
apfileph=$sdir'func/'$apnr'_ph/'$apnr'_ph_ph.nii.gz'

## t1 names
t1dir=$sdir'anat/'$t1nr'/'
t1file=$t1dir$t1nr'.nii.gz'
t1file2=$t1dir$'brainmask.nii.gz'
if ( [ ! -f $t1file2 ] ); then
mri_convert $sdir'derivatives/fs/'$sub'/mri/brainmask.mgz' $sdir'derivatives/fs/'$sub'/mri/brainmask.nii.gz'
cp $sdir'derivatives/fs/'$sub'/mri/brainmask.nii.gz' $t1dir
fi

## Declare a bunch of upcoming variables
fbase=()
fbase2=()
fbase3=()
fbase3ph=()
rapfile=()
AWARP=()
BWARP=()
CWARP=()
ffile2=()
ffile3=()
for (( i=0; i<nses; i++ ));
do
ffile2[i]=${fdir[$i]}${fnr[$i]}'-mc.nii.gz'
ffile3[i]=${fdir[$i]}${fnr[$i]}'-rwm.nii.gz'
ffile3ph[i]=$sdir'func/'${fnr[$i]}'_ph/'${fnr[$i]}'_ph-rwm.nii.gz'
fbase[i]=${fdir[$i]}${fnr[$i]}'-mc-mean.nii.gz'
fbase2[i]=${fdir[$i]}${fnr[$i]}'-wf_pa.nii.gz'
fbase3[i]=${fdir[$i]}${fnr[$i]}'-t1w.nii.gz'
rapfile[i]=${fdir[$i]}$apnr'-r'$i'.nii.gz'
AWARP[i]=${fdir[$i]}${fnr[$i]}'-mp.1D'
BWARP[i]=${fdir[$i]}${fnr[$i]}'-wf_pa_WARP.nii.gz'
CWARP[i]=${fdir[$i]}${fnr[$i]}'-t1w.1D'
done

#########################################
## Preprocessing of functional volumes ##
#########################################
if ( [ ! -f ${fbase2[0]} ] ); then

if (( deobl == 1 )); then
## Deoblique the header data & nudge towards 7T space
3drefit -deoblique \
-oblique_origin \
$apfile

#3drefit -deoblique \
#-oblique_origin \
#$t1file

for (( i=0; i<nses; i++ ));
do
3drefit -deoblique \
-oblique_origin \
${ffile[$i]}
done

3drefit -deoblique \
-oblique_origin \
$apfileph

for (( i=0; i<nses; i++ ));
do
3drefit -deoblique \
-oblique_origin \
${ffileph[$i]}
done
fi

## Motion correction AP files
if (( multap > 1 )); then
apfile2=$apdir$apnr'-mc.nii.gz'
3dvolreg -prefix $apfile2 \
$apfile
## Calculate mean AP files
apfile3=$apdir$apnr'-mc-mean.nii.gz'
3dTstat -mean \
-prefix $apfile3 \
$apfile2
else
apfile3=$apfile
fi

## Motion correction
for (( i=0; i<nses; i++ ));
do
3dvolreg -prefix ${ffile2[$i]} \
-1Dfile ${fdir[$i]}${fnr[$i]}'-mp' \
-maxdisp1D ${fdir[$i]}${fnr[$i]}'-mp-maxdisp' \
-1Dmatrix_save ${AWARP[$i]} \
-base ${refscan[$i]} \
${ffile[$i]}
done

## Calculate mean timeseries
for (( i=0; i<nses; i++ ));
do
3dTstat -mean \
-prefix ${fbase[$i]} \
${ffile2[$i]} 
done

## Align funcs with AP
for (( i=0; i<nses; i++ ));
do
3dAllineate -base ${fbase[$i]} \
-source $apfile3 \
-prefix ${rapfile[$i]} \
-hel \
-onepass \
-master BASE \
-warp shift_rotate
done

## Calculating EPI phase acquisition distortion warp (or EPAD warp, because that's less letters)
for (( i=0; i<nses; i++ ));
do
3dQwarp -base ${fbase[$i]} \
-source ${rapfile[$i]} \
-prefix ${fdir[$i]}${fnr[$i]}'-wf.nii.gz' \
-plusminus \
-pmNAMES ap pa
done

else
echo "+++ I've already done deobliqueing, motion correction and phase correction."
echo "+++ Not doing this stuff again."
fi


#########################
## Align T1 with funcs ##
#########################
for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${fbase3[$i]} ] ); then
3dAllineate -base $t1file2 \
-source ${fbase2[$i]} \
-prefix ${fbase3[$i]} \
-1Dmatrix_save ${CWARP[$i]} \
-nmi \
-onepass \
-master SOURCE \
-warp affine_general
else
echo "T1 to funcs registration already exits for "${fnr[$i]}
fi
done

###########################################################################################
## Apply transformations to original dataset (like Rihanna ft. Drake - "warp warp warp") ##
###########################################################################################
for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${ffile3[$i]} ] ); then
3dNwarpApply -nwarp "${CWARP[$i]} ${BWARP[$i]} ${AWARP[$i]}" \
-source ${ffile[$i]} \
-master ${fbase3[$i]} \
-prefix ${ffile3[$i]}
else
echo "+++ Warped volume already exits for "${fnr[$i]}
fi
done

for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${ffile3ph[$i]} ] ); then
3dNwarpApply -nwarp "${CWARP[$i]} ${BWARP[$i]} ${AWARP[$i]}" \
-source ${ffileph[$i]} \
-master ${fbase3[$i]} \
-prefix ${ffile3ph[$i]}
else
echo "+++ Warped volume already exits for "${ffileph[$i]}
fi
done


## Clean up a bit. It's a mess out there.
rm -f ${ffile2[@]}
rm -f ${rapfile[@]}
for (( i=0; i<nses; i++ ));
do
rm -f ${fdir[$i]}${fnr[$i]}'-wf_ap.nii.gz'
rm -f ${fdir[$i]}${fnr[$i]}'-wf_ap_WARP.nii.gz'
done

echo '---------------------------------------'
echo '------Im done. Thats it. Im off.-------'
echo '---------------------------------------'
