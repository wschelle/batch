#!/bin/bash

#qsub -l 'walltime=01:00:00,mem=32gb' dicom2niiBIDS.sh

module load dcm2niix

# Fill out subject specs here
sub='sub-x006'
sub2='sub-P003'
rdir='/home/control/wousch/Pilot/'
dicomdir='/project/3017000.01/raw/'$sub'/ses-mri01/'
#dicomdir='H:/common/temporary/4WouSch/'
subdir=$rdir$sub2'/'
mkdir $subdir
niidir=$subdir'raw/'
mkdir $niidir
pipedir=$subdir'pipeline1/'

declare -a anat=("018-t1_mprage_sag_ipat2_1p0iso")
declare -a anatnew=("T1w")

declare -a fmz=("012-cmrr_2p0iso_mb6_TR1000" "013-cmrr_2p0iso_mb6_TR1000")
declare -a fmznew=("acq-AP_magnitude" "acq-AP_phasediff")

declare -a fnr=("007-cmrr_2p0iso_mb6_TR1000" "008-cmrr_2p0iso_mb6_TR1000" "015-cmrr_2p0iso_mb6_TR1000" "016-cmrr_2p0iso_mb6_TR1000" "020-cmrr_2p0iso_mb6_TR1000" "021-cmrr_2p0iso_mb6_TR1000" "024-cmrr_2p0iso_mb6_TR1000" "025-cmrr_2p0iso_mb6_TR1000")
declare -a task=("task-wmg" "task-wmg" "task-wmg" "task-wmg" "task-wmg" "task-wmg" "task-loc" "task-loc")
declare -a run=("run-01" "run-01" "run-02" "run-02" "run-03" "run-03" "run-01" "run-01")
declare -a suff=("bold" "phase" "bold" "phase" "bold" "phase" "bold" "phase")

declare -a phys=("009-cmrr_2p0iso_mb6_TR1000_PhysioLog" "017-cmrr_2p0iso_mb6_TR1000_PhysioLog" "022-cmrr_2p0iso_mb6_TR1000_PhysioLog" "026-cmrr_2p0iso_mb6_TR1000_PhysioLog")
declare -a physnew=("task-wmg_run-01_phys" "task-wmg_run-02_phys" "task-wmg_run-03_phys" "task-loc_run-01_phys")


fdir=$niidir'func/'
adir=$niidir'anat/'
fmdir=$niidir'fmap/'
mkdir $fdir
mkdir $adir
mkdir $fmdir

nses=${#fnr[@]}
nanat=${#anat[@]}
nfm=${#fmz[@]}

for (( i=0; i<nses; i++ ));
do
dcm2niix -o $fdir -f $sub2'_'${task[$i]}'_'${run[$i]}'_'${suff[$i]} -z y $dicomdir${fnr[$i]}
done

for (( i=0; i<nanat; i++ ));
do
dcm2niix -o $adir -f $sub2'_'${anatnew[$i]} -z y $dicomdir${anat[$i]}
done

for (( i=0; i<nfm; i++ ));
do
dcm2niix -o $fmdir -f $sub2'_'${fmznew[$i]} -z y $dicomdir${fmz[$i]}
done

for (( i=0; i<nses; i++ ));
do
if ( [ ${suff[$i]} == "phase" ] ); then
mv -f $fdir$sub2'_'${task[$i]}'_'${run[$i]}'_'${suff[$i]}'_ph.nii.gz' $fdir$sub2'_'${task[$i]}'_'${run[$i]}'_'${suff[$i]}'.nii.gz'
mv -f $fdir$sub2'_'${task[$i]}'_'${run[$i]}'_'${suff[$i]}'_ph.json' $fdir$sub2'_'${task[$i]}'_'${run[$i]}'_'${suff[$i]}'.json'
fi
done

for (( i=0; i<nfm; i++ ));
do
if ( [ ${fmznew[$i]} == "acq-AP_phasediff" ] ); then
mv -f $fmdir$sub2'_'${fmznew[$i]}'_ph.nii.gz' $fmdir$sub2'_'${fmznew[$i]}'.nii.gz'
mv -f $fmdir$sub2'_'${fmznew[$i]}'_ph.json' $fmdir$sub2'_'${fmznew[$i]}'.json'
fi
done

fdir=$pipedir'func/'
adir=$pipedir'anat/'
fmdir=$pipedir'fmap/'
mkdir $fdir
mkdir $adir
mkdir $fmdir


module load anaconda3
source activate venv1
nphys=${#phys[@]}
for (( i=0; i<nphys; i++ ));
do
for entry in "$dicomdir${phys[$i]}"/*
do
f="$(basename -- $entry)"
phys2bids -in $f -indir $dicomdir${phys[$i]} -outdir $fdir -heur ${physnew[$i]}
done
done


