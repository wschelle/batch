#!/bin/bash

# Fill out subject specs here
sub='sub-x005'
sub2='Pilot002'
rdir='/home/control/wousch/Pilot/'
dicomdir='/project/3017000.01/raw/'$sub'/ses-mri01/'
niidir=$rdir$sub2'/'
mkdir $niidir

declare -a anat=("011-t1_mprage_sag_ipat2_1p0iso")
declare -a anatnew=("T1")
declare -a fnr=("008-cmrr_2p0iso_mb6_TR1000" "009-cmrr_2p0iso_mb6_TR1000" "014-cmrr_2p0iso_mb6_TR1000" "015-cmrr_2p0iso_mb6_TR1000" "017-cmrr_2p0iso_mb6_TR1000" "018-cmrr_2p0iso_mb6_TR1000" "021-cmrr_2p0iso_mb6_TR1000" "022-cmrr_2p0iso_mb6_TR1000" "025-cmrr_2p0iso_mb6_TR1000" "026-cmrr_2p0iso_mb6_TR1000")
declare -a fnrnew=("wm1" "wm1_ph" "topup" "topup_ph" "wm2" "wm2_ph" "loc" "loc_ph" "wm3" "wm3_ph" )

fdir=$niidir'func/'
adir=$niidir'anat/'
mkdir $fdir
mkdir $adir

fdirz=()
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
fdirz[i]=$fdir${fnrnew[$i]}'/'
mkdir ${fdirz[$i]}
done

adirz=()
nanat=${#anat[@]}
for (( i=0; i<nanat; i++ ));
do
adirz[i]=$adir${anatnew[$i]}'/'
mkdir ${adirz[$i]}
done

for (( i=0; i<nses; i++ ));
do
dcm2niix -o ${fdirz[$i]} -f ${fnrnew[$i]} -z y $dicomdir${fnr[$i]}
done

for (( i=0; i<nanat; i++ ));
do
dcm2niix -o ${adirz[$i]} -f ${anatnew[$i]} -z y $dicomdir${anat[$i]}
done



