#!/bin/bash
sub='Pilot001'
export SUBJECTS_DIR='/home/control/wousch/Pilot/'$sub'/derivatives/fs/'
recon-all -autorecon2-wm -autorecon3 -subjid $sub