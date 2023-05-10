#!/bin/bash

##Run like so:
##qsub -l 'nodes=1:ppn=2,walltime=06:00:00,mem=32gb' preprocBIDS.sh

#################################
## Fill out subject specs here ##
#################################

module load afni

rdir='/home/control/wousch/Pilot/'
sub='sub-P003'
sdir=$rdir$sub'/'

t1nr='T1w'
apnr='acq-AP_magnitude'

declare -a fnr=("task-wmg_run-01" "task-wmg_run-02" "task-wmg_run-03" "task-loc_run-01")
declare -a refscan=("405" "405" "405" "172")

#just for now, becuase bullshit
#declare -a fnr=("task-wmg_run-02" "task-loc_run-01")
#declare -a refscan=("405" "172")

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
ffile0=()
fdirraw=$sdir'raw/func/'
fdir=$sdir'pipeline1/func/'
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
ffile0[i]=$fdirraw$sub'_'${fnr[$i]}'_nd.nii'
ffile[i]=$fdir$sub'_'${fnr[$i]}'_nd.nii.gz'
done

for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${ffile[$i]} ] ); then
gzip ${ffile0[$i]} --best
mv -f $fdirraw$sub'_'${fnr[$i]}'_nd.nii.gz' ${ffile[$i]}
fi
done

## ap names
apdirraw=$sdir'raw/fmap/'
apfileraw=$apdirraw$sub'_'$apnr'.nii.gz'
apdir=$sdir'pipeline1/fmap/'

## t1 names
t1dirraw=$sdir'raw/anat/'
t1fileraw=$t1dirraw$sub'_'$t1nr'.nii.gz'
t1dir=$sdir'pipeline1/anat/'
t1file2=$t1dir'brainmask.nii.gz'
if ( [ ! -f $t1file2 ] ); then
mri_convert $sdir'derivatives/fs/'$sub'/mri/brainmask.mgz' $sdir'derivatives/fs/'$sub'/mri/brainmask.nii.gz'
cp $sdir'derivatives/fs/'$sub'/mri/brainmask.nii.gz' $t1dir
fi

#########################################
## Preprocessing of functional volumes ##
#########################################

## Motion correction AP files
apfile2=$apdir$sub'_'$apnr'_mc.nii.gz'
apfile3=$apdir$sub'_'$apnr'_mc-mean.nii.gz'
if ( [ ! -f $apfile3 ] ); then
3dvolreg -prefix $apfile2 \
$apfileraw

## Deoblique the header data
if (( deobl == 1 )); then
3drefit -deoblique $apfile2
fi

## Calculate mean AP files
3dTstat -mean \
-prefix $apfile3 \
$apfile2
fi


## Slice timing
ffile1=()
for (( i=0; i<nses; i++ ));
do
ffile1[i]=$fdir$sub'_'${fnr[$i]}'_st.nii.gz'
if ( [ ! -f ${ffile1[$i]} ] ); then
3dTshift -verbose \
-TR 1.0 \
-tzero 0.5 \
-tpattern "@$fdir$sub_${fnr[$i]}_slicetiming.1D" \
-prefix ${ffile1[$i]} \
${ffile[$i]}
fi
done

## deoblique the header
if (( deobl == 1 )); then
for (( i=0; i<nses; i++ ));
do
3drefit -deoblique ${ffile1[$i]}
done
fi

## Motion correction
ffile2=()
AWARP=()
for (( i=0; i<nses; i++ ));
do
ffile2[i]=$fdir$sub'_'${fnr[$i]}'_mc.nii.gz'
AWARP[i]=$fdir$sub'_'${fnr[$i]}'_mp.1D'
if ( [ ! -f ${ffile2[$i]} ] ); then
3dvolreg -prefix ${ffile2[$i]} \
-1Dfile $fdir$sub'_'${fnr[$i]}'_mp' \
-maxdisp1D $fdir$sub'_'${fnr[$i]}'_mp-maxdisp' \
-1Dmatrix_save ${AWARP[$i]} \
-base ${refscan[$i]} \
${ffile1[$i]}
fi
done

## Calculate mean timeseries
fbase=()
for (( i=0; i<nses; i++ ));
do
fbase[i]=$fdir$sub'_'${fnr[$i]}'_mc-mean.nii.gz'
if ( [ ! -f ${fbase[$i]} ] ); then
3dTstat -mean \
-prefix ${fbase[$i]} \
${ffile2[$i]}
fi
done

## Align funcs with AP
rapfile=()
for (( i=0; i<nses; i++ ));
do
rapfile[i]=$fdir$sub'_'${fnr[$i]}'_AP.nii.gz'
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
fbase2=()
BWARP=()
for (( i=0; i<nses; i++ ));
do
fbase2[i]=$fdir$sub'_'${fnr[$i]}'_wf_pa.nii.gz'
BWARP[i]=$fdir$sub'_'${fnr[$i]}'_wf_pa_WARP.nii.gz'
if ( [ ! -f ${fbase2[$i]} ] ); then
3dQwarp -base ${fbase[$i]} \
-source ${rapfile[$i]} \
-prefix $fdir$sub'_'${fnr[$i]}'_wf.nii.gz' \
-plusminus \
-pmNAMES ap pa
fi
done

#########################
## Align T1 with funcs ##
#########################
fbase3=()
CWARP=()
for (( i=0; i<nses; i++ ));
do
fbase3[i]=$fdir$sub'_'${fnr[$i]}'_T1w.nii.gz'
CWARP[i]=$fdir$sub'_'${fnr[$i]}'_T1w.1D'
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

ffile3=()
for (( i=0; i<nses; i++ ));
do
ffile3[i]=$fdir$sub'_'${fnr[$i]}'_prep.nii.gz'
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
rm -f $fdir$sub'_'${fnr[$i]}'_wf_ap.nii.gz'
rm -f $fdir$sub'_'${fnr[$i]}'_wf_ap_WARP.nii.gz'
done

echo '---------------------------------------'
echo '------Im done. Thats it. Im off.-------'
echo '---------------------------------------'
