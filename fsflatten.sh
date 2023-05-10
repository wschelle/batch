
#qsub -l 'walltime=12:00:00,mem=32gb' fsflatten.sh 

sub='sub-P003'
export SUBJECTS_DIR='/home/control/wousch/Pilot/'$sub'/derivatives/fs'

mris_flatten -w 10 $SUBJECTS_DIR'/'$sub'/surf/lh.full.patch.3d' $SUBJECTS_DIR'/'$sub'/surf/lh.full.flat.patch.3d'
mris_flatten -w 10 $SUBJECTS_DIR'/'$sub'/surf/rh.full.patch.3d' $SUBJECTS_DIR'/'$sub'/surf/rh.full.flat.patch.3d'
