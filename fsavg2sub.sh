
#qsub -l 'walltime=00:10:00,mem=4gb' fsavg2sub.sh 

sub='sub-P003'
export SUBJECTS_DIR='/home/control/wousch/Pilot/'$sub'/derivatives/fs'

mri_surf2surf --srcsubject fsaverage --sval-annot $SUBJECTS_DIR'/lh.HCPMMP1.annot' --trgsubject $sub --tval $SUBJECTS_DIR'/'$sub'/label/lh.HCPMMP1.annot' --hemi lh
mri_surf2surf --srcsubject fsaverage --sval-annot $SUBJECTS_DIR'/rh.HCPMMP1.annot' --trgsubject $sub --tval $SUBJECTS_DIR'/'$sub'/label/rh.HCPMMP1.annot' --hemi rh

mri_label2vol --subject $sub --annot $SUBJECTS_DIR'/'$sub'/label/lh.HCPMMP1.annot' --o $SUBJECTS_DIR'/'$sub'/mri/lh.HCPMMP1.nii.gz' --regheader $SUBJECTS_DIR'/'$sub'/mri/brainmask.mgz' --hemi lh --temp '/home/control/wousch/Pilot/'$sub'/pipeline1/func/'$sub'_task-wmg_run-01_prep.nii.gz' --proj frac 0 1 0.25
mri_label2vol --subject $sub --annot $SUBJECTS_DIR'/'$sub'/label/rh.HCPMMP1.annot' --o $SUBJECTS_DIR'/'$sub'/mri/rh.HCPMMP1.nii.gz' --regheader $SUBJECTS_DIR'/'$sub'/mri/brainmask.mgz' --hemi rh --temp '/home/control/wousch/Pilot/'$sub'/pipeline1/func/'$sub'_task-wmg_run-01_prep.nii.gz' --proj frac 0 1 0.25

mri_concat --i $SUBJECTS_DIR'/'$sub'/mri/lh.HCPMMP1.nii.gz' --i $SUBJECTS_DIR'/'$sub'/mri/rh.HCPMMP1.nii.gz' --o $SUBJECTS_DIR'/'$sub'/mri/HCPMMP1.nii.gz' --combine
