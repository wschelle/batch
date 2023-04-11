#!/bin/bash

#################################
## Fill out subject specs here ##
#################################
module load afni

rdir='/home/control/wousch/Pilot/'
sub='Pilot002'
sdir=$rdir$sub'/'

t1nr='T1'
apnr='topup'

declare -a fnr=("wm1" "wm2" "wm3" "loc") 
declare -a refscan=("402" "450" "450" "162")

## Give here the number of AP scans
multap=10
## if deoblique images then deobl = 1, else deobl = 0
deobl=0

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
ffile0[i]=${fdir[$i]}${fnr[$i]}'-nd.nii'
ffile[i]=${fdir[$i]}${fnr[$i]}'-nd.nii.gz'
done

for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${ffile[$i]} ] ); then
gzip ${ffile0[$i]} --best
fi
done

## ap names
apdir=$sdir'func/'$apnr'/'
apfile=$apdir$apnr'.nii.gz'

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
rapfile=()
AWARP=()
BWARP=()
CWARP=()
ffile1=()
ffile2=()
ffile3=()
for (( i=0; i<nses; i++ ));
do
ffile1[i]=${fdir[$i]}${fnr[$i]}'-st.nii.gz'
ffile2[i]=${fdir[$i]}${fnr[$i]}'-mc.nii.gz'
ffile3[i]=${fdir[$i]}${fnr[$i]}'-prep.nii.gz'
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

if (( deobl == 1 )); then
## Deoblique the header data
3drefit -deoblique \
-oblique_origin \
$apfile

for (( i=0; i<nses; i++ ));
do
3drefit -deoblique \
-oblique_origin \
${ffile[$i]}
done
fi

## Motion correction AP files
apfile2=$apdir$apnr'-mc.nii.gz'
apfile3=$apdir$apnr'-mc-mean.nii.gz'
if ( [ ! -f $apfile3 ] ); then
3dvolreg -prefix $apfile2 \
$apfile
## Calculate mean AP files
3dTstat -mean \
-prefix $apfile3 \
$apfile2
fi

## Slice timing
for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${ffile1[$i]} ] ); then
3dTshift -verbose \
-TR 1.0 \
-tzero 0.5 \
-tpattern "@${fdir[$i]}${fnr[$i]}-slicetiming.txt" \
-prefix ${ffile1[$i]} \
${ffile[$i]}
fi
done

## Motion correction
for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${ffile2[$i]} ] ); then
3dvolreg -prefix ${ffile2[$i]} \
-1Dfile ${fdir[$i]}${fnr[$i]}'-mp' \
-maxdisp1D ${fdir[$i]}${fnr[$i]}'-mp-maxdisp' \
-1Dmatrix_save ${AWARP[$i]} \
-base ${refscan[$i]} \
${ffile1[$i]}
fi
done

## Calculate mean timeseries
for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${fbase[$i]} ] ); then
3dTstat -mean \
-prefix ${fbase[$i]} \
${ffile2[$i]}
fi
done

## Align funcs with AP
for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${rapfile[$i]} ] ); then
3dAllineate -base ${fbase[$i]} \
-source $apfile3 \
-prefix ${rapfile[$i]} \
-hel \
-onepass \
-master BASE \
-warp shift_rotate
fi
done

## Calculating EPI phase acquisition distortion warp (or EPAD warp, because that's less letters)
for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${fdir[$i]}${fnr[$i]}'-wf_pa.nii.gz' ] ); then
3dQwarp -base ${fbase[$i]} \
-source ${rapfile[$i]} \
-prefix ${fdir[$i]}${fnr[$i]}'-wf.nii.gz' \
-plusminus \
-pmNAMES ap pa
fi
done

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
-master BASE \
-newgrid 2.0 \
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
-source ${ffile1[$i]} \
-master ${fbase3[$i]} \
-prefix ${ffile3[$i]}
else
echo "+++ Warped volume already exits for "${fnr[$i]}
fi
done

## Clean up a bit. It's a mess out there.
rm -f ${ffile1[@]}
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
