# run like so:
# qsub -l 'nodes=1:ppn=4,walltime=06:00:00,mem=64gb' nordic.sh

matlab -nodisplay -nosplash -nodesktop -r "run('/home/control/wousch/Documents/MATLAB/NORDICpersubBIDS.m');exit;"
#matlab -r "run('/home/control/wousch/Documents/MATLAB/NORDICpersub.m');"

