#!/bin/bash

# Fill out subject specs here
sub='4WouSch'
sub2='Pilot001'
rdir='/home/control/wousch/Pilot/'
dicomdir=$rdir$sub'/'
niidir=$rdir$sub2'/'
mkdir niidir

declare -a anat=("001-localizer_32ch-head" "002-AAHead_Scout_32ch-head" "003-AAHead_Scout_32ch-head_MPR_sag" "004-AAHead_Scout_32ch-head_MPR_cor" "005-AAHead_Scout_32ch-head_MPR_tra" "018-t1_mprage_sag_ipat2_1p0iso")
declare -a anatnew=("Loc" "Scout" "ScSag" "ScCor" "ScTra" "T1")
declare -a fnr=("006-cmrr_2p0iso_mb6_TR1000_SBRef" "007-cmrr_2p0iso_mb6_TR1000" "008-cmrr_2p0iso_mb6_TR1000" "009-cmrr_2p0iso_mb6_TR1000_PhysioLog" "010-cmrr_2p0iso_mb6_TR1000_PhysioLog" "011-cmrr_2p0iso_mb6_TR1000_SBRef" "012-cmrr_2p0iso_mb6_TR1000" "013-cmrr_2p0iso_mb6_TR1000" "014-cmrr_2p0iso_mb6_TR1000_SBRef" "015-cmrr_2p0iso_mb6_TR1000" "016-cmrr_2p0iso_mb6_TR1000" "017-cmrr_2p0iso_mb6_TR1000_PhysioLog" "019-cmrr_2p0iso_mb6_TR1000_SBRef" "020-cmrr_2p0iso_mb6_TR1000" "021-cmrr_2p0iso_mb6_TR1000" "022-cmrr_2p0iso_mb6_TR1000_PhysioLog")
declare -a fnrnew=("wm1_ref" "wm1" "wm1_ph" "wm1_phys" "topup_phys" "topup_ref" "top_up" "top_ph" "wm2_ref" "wm2" "wm2_ph" "wm2_phys" "loc_ref" "loc" "loc_ph" "loc_phys")

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
dcm2niix -o ${fdirz[$i]} -f ${fnrnew[$i]} $dicomdir${fnr[$i]}
done

for (( i=0; i<nanat; i++ ));
do
dcm2niix -o ${adirz[$i]} -f ${anatnew[$i]} $dicomdir${anat[$i]}
done



