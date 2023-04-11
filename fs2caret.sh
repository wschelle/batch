#!/bin/bash
sub='Pilot001'
export SUBJECTS_DIR='/home/control/wousch/Pilot/'$sub'/derivatives/fs/'

fsdir='/home/control/wousch/Pilot/'$sub'/derivatives/fs/'$sub'/'
surfdir=$fsdir'surf/'
mris_smooth -n 2 $surfdir'lh.pial' $surfdir'lh.smooth.pial'
mris_smooth -n 2 $surfdir'rh.pial' $surfdir'rh.smooth.pial'


mridir=$fsdir'/mri/'
labeldir=$fsdir'/label/tmplabels/'
outputdir=$fsdir'/surf/caret/'
mkdir $outputdir

caret_command -file-convert -sc -is FSS $surfdir'lh.white' -os CARET $outputdir'lh_white.coord' $outputdir'lh_closed.topo' FIDUCIAL CLOSED -spec $outputdir'lh_file.spec' -struct LEFT -outbin
caret_command -file-convert -sc -is FSS $surfdir'lh.pial' -os CARET $outputdir'lh_pial.coord' $outputdir'lh_closed.topo' FIDUCIAL CLOSED -spec $outputdir'lh_file.spec' -struct LEFT -outbin
caret_command -file-convert -sc -is FSS $surfdir'lh.smooth.pial' -os CARET $outputdir'lh_smooth_pial.coord' $outputdir'lh_closed.topo' FIDUCIAL CLOSED -spec $outputdir'lh_file.spec' -struct LEFT -outbin
caret_command -file-convert -sc -is FSS $surfdir'lh.inflated' -os CARET $outputdir'lh_inflated.coord' $outputdir'lh_closed.topo' VERY_INFLATED CLOSED -spec $outputdir'lh_file.spec' -struct LEFT -outbin
caret_command -file-convert -sc -is FSS $surfdir'lh.sphere' -os CARET $outputdir'lh_sphere.coord' $outputdir'lh_closed.topo' SPHERICAL CLOSED -spec $outputdir'lh_file.spec' -struct LEFT -outbin
caret_command -file-convert -sc -is FSS $surfdir'rh.white' -os CARET $outputdir'rh_white.coord' $outputdir'rh_closed.topo' FIDUCIAL CLOSED -spec $outputdir'rh_file.spec' -struct RIGHT -outbin
caret_command -file-convert -sc -is FSS $surfdir'rh.pial' -os CARET $outputdir'rh_pial.coord' $outputdir'rh_closed.topo' FIDUCIAL CLOSED -spec $outputdir'rh_file.spec' -struct RIGHT -outbin
caret_command -file-convert -sc -is FSS $surfdir'rh.smooth.pial' -os CARET $outputdir'rh_smooth_pial.coord' $outputdir'rh_closed.topo' FIDUCIAL CLOSED -spec $outputdir'rh_file.spec' -struct RIGHT -outbin
caret_command -file-convert -sc -is FSS $surfdir'rh.inflated' -os CARET $outputdir'rh_inflated.coord' $outputdir'rh_closed.topo' VERY_INFLATED CLOSED -spec $outputdir'rh_file.spec' -struct RIGHT -outbin
caret_command -file-convert -sc -is FSS $surfdir'rh.sphere' -os CARET $outputdir'rh_sphere.coord' $outputdir'rh_closed.topo' SPHERICAL CLOSED -spec $outputdir'rh_file.spec' -struct RIGHT -outbin
caret_command -surface-average $outputdir'lh_midthickness.coord' $outputdir'lh_white.coord' $outputdir'lh_pial.coord'
caret_command -surface-average $outputdir'rh_midthickness.coord' $outputdir'rh_white.coord' $outputdir'rh_pial.coord'
caret_command -spec-file-add $outputdir'lh_file.spec' FIDUCIALcoord_file $outputdir'lh_midthickness.coord'
caret_command -spec-file-add $outputdir'rh_file.spec' FIDUCIALcoord_file $outputdir'rh_midthickness.coord'

mkdir $labeldir
cd $labeldir
mri_annotation2label --annotation aparc --subject $sub --hemi lh --outdir $labeldir
caret_command -file-convert -fsl2c . $surfdir'lh.white' 'lh_aparc.paint' -spec $outputdir'lh_file.spec' -outbin
rm *.label
mri_annotation2label --annotation aparc.a2009s --subject $sub --hemi lh --outdir $labeldir
caret_command -file-convert -fsl2c . $surfdir'lh.white' 'lh_aparc_a2009s.paint' -spec $outputdir'lh_file.spec' -outbin
rm *.label
mri_annotation2label --annotation BA_exvivo --subject $sub --hemi lh --outdir $labeldir
caret_command -file-convert -fsl2c . $surfdir'lh.white' 'lh_BA.paint' -spec $outputdir'lh_file.spec' -outbin
rm *.label
caret_command -paint-set-column-name 'lh_aparc.paint' 'lh_aparc.paint' 1 aparc
caret_command -paint-set-column-name lh_aparc_a2009s.paint lh_aparc_a2009s.paint 1 aparc_a2009s
caret_command -paint-set-column-name lh_BA.paint lh_BA.paint 1 BA
caret_command -spec-file-add $outputdir'lh_file.spec' paint_file lh_aparc.paint
caret_command -spec-file-add $outputdir'lh_file.spec' paint_file lh_aparc_a2009s.paint
caret_command -spec-file-add $outputdir'lh_file.spec' paint_file lh_BA.paint
caret_command -spec-file-add $outputdir'lh_file.spec' area_color_file area_color_file.areacolor
caret_command -spec-file-add $outputdir'lh_file.spec' foci_color_file foci_color_file.focicolor
mri_annotation2label --annotation aparc --subject $sub --hemi rh --outdir $labeldir
caret_command -file-convert -fsl2c . $surfdir'rh.white' 'rh_aparc.paint' -spec $outputdir'rh_file.spec' -outbin
rm *.label
mri_annotation2label --annotation aparc.a2009s --subject $sub --hemi rh --outdir $labeldir
caret_command -file-convert -fsl2c . $surfdir'rh.white' 'rh_aparc_a2009s.paint' -spec $outputdir'rh_file.spec' -outbin
rm *.label
mri_annotation2label --annotation BA_exvivo --subject $sub --hemi rh --outdir $labeldir
caret_command -file-convert -fsl2c . $surfdir'rh.white' 'rh_BA.paint' -spec $outputdir'rh_file.spec' -outbin
rm *.label
caret_command -paint-set-column-name rh_aparc.paint rh_aparc.paint 1 aparc
caret_command -paint-set-column-name rh_aparc_a2009s.paint rh_aparc_a2009s.paint 1 aparc_a2009s
caret_command -paint-set-column-name rh_BA.paint rh_BA.paint 1 BA
caret_command -spec-file-add $outputdir'rh_file.spec' paint_file rh_aparc.paint
caret_command -spec-file-add $outputdir'rh_file.spec' paint_file rh_aparc_a2009s.paint
caret_command -spec-file-add $outputdir'rh_file.spec' paint_file rh_BA.paint
caret_command -spec-file-add $outputdir'rh_file.spec' area_color_file area_color_file.areacolor
caret_command -spec-file-add $outputdir'rh_file.spec' foci_color_file foci_color_file.focicolor
mv *.paint $outputdir
cd $fsdir
rm -r $labeldir
caret_command -file-convert -fsc2c $surfdir'lh.curv' $surfdir'lh.pial' $outputdir'lh_curve.surface_shape' -spec $outputdir'lh_file.spec' -outbin
caret_command -file-convert -fsc2c $surfdir'lh.thickness' $surfdir'lh.pial' $outputdir'lh_thickness.surface_shape' -spec $outputdir'lh_file.spec' -outbin
caret_command -file-convert -fsc2c $surfdir'lh.sulc' $surfdir'lh.pial' $outputdir'lh_sulc.surface_shape' -spec $outputdir'lh_file.spec' -outbin
caret_command -file-convert -fsc2c $surfdir'rh.curv' $surfdir'rh.pial' $outputdir'rh_curve.surface_shape' -spec $outputdir'rh_file.spec' -outbin
caret_command -file-convert -fsc2c $surfdir'rh.thickness' $surfdir'rh.pial' $outputdir'rh_thickness.surface_shape' -spec $outputdir'rh_file.spec' -outbin
caret_command -file-convert -fsc2c $surfdir'rh.sulc' $surfdir'rh.pial' $outputdir'rh_sulc.surface_shape' -spec $outputdir'rh_file.spec' -outbin


