#!/bin/bash
sub='Pilot002'
export SUBJECTS_DIR='/home/control/wousch/Pilot/'$sub'/derivatives/fs/'
recon-all -all -s $sub -i '/home/control/wousch/Pilot/'$sub'/anat/T1/T1.nii.gz' -parallel -openmp 4
