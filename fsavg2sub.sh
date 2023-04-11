sub='Pilot002'
export SUBJECTS_DIR='/home/control/wousch/Pilot/'$sub'/derivatives/fs'

mri_surf2surf --srcsubject fsaverage --sval-annot $SUBJECTS_DIR'/lh.HCPMMP1.annot' --trgsubject $sub --tval $SUBJECTS_DIR'/'$sub'/label/lh.HCPMMP1.annot' --hemi lh
mri_surf2surf --srcsubject fsaverage --sval-annot $SUBJECTS_DIR'/rh.HCPMMP1.annot' --trgsubject $sub --tval $SUBJECTS_DIR'/'$sub'/label/rh.HCPMMP1.annot' --hemi rh

