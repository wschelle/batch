#!/bin/bash

#run like so:
#qsub -l 'nodes=1:ppn=4,walltime=24:00:00,mem=24gb' runfs.sh

sub='sub-P003'
export SUBJECTS_DIR='/home/control/wousch/Pilot/'$sub'/derivatives/fs/'
recon-all -all -s $sub -i '/home/control/wousch/Pilot/'$sub'/raw/anat/'$sub'_T1w.nii.gz' -parallel -openmp 4
