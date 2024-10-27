#-----------------------------------------------------------------------------
# plot.gp
#-----------------------------------------------------------------------------

functions='bent_cigar different_powers discus katsuura rastrigin rosenbrock schaffers schwefel sharp_ridge sphere'
types='float double long_double'

file='fp.log'
stem=file[:strlen(file)-4]

set datafile separator ';'
set encoding utf8
set key autotitle columnhead
set terminal svg noenhanced
set xtics rotate by 33 right scale 0
set ylabel 'power/energy-pkg (J)'

#-----------------------------------------------------------------------------
# statistics
#-----------------------------------------------------------------------------

stats file using (column('diff')) name 'diff' nooutput

do for [function in functions] {
    stats '<(head -n1 '.file.'; grep '.function.' '.file.')' using (column('diff')) name 'diff_'.function nooutput
}

do for [type in types] {
    stats '<(head -n1 '.file.'; grep ";'.type.'" '.file.')' using (column('diff')) name 'diff_'.type nooutput
}

#-----------------------------------------------------------------------------
# all functions
#-----------------------------------------------------------------------------

set output stem.'-functions.svg'
plot file using (1):(column('diff')):(0.75):(column('function')) with boxplot linecolor variable notitle, diff_mean w l lc 0 lt 1 lw 2 t 'mean', diff_median w l lc 0 lt 0 lw 2 t 'median'

#-----------------------------------------------------------------------------
# plot by function
#-----------------------------------------------------------------------------

do for [function in functions] {
    set output stem.'-'.function.'.svg'
    plot '<(head -n1 '.file.'; grep '.function.' '.file.')' using (1):(column('diff')):(0.75):(column('type')) with boxplot linecolor variable notitle
}

#-----------------------------------------------------------------------------
# plot by type
#-----------------------------------------------------------------------------

do for [type in types] {
    set output stem.'-'.type.'.svg'
    plot '<(head -n1 '.file.'; grep \;'.type.' '.file.')' using (1):(column('diff')):(0.75):(column('function')) with boxplot linecolor variable notitle, value('diff_'.type.'_mean') w l lc 0 lt 1 lw 2 t 'mean', value('diff_'.type.'_median') w l lc 0 lt 0 lw 2 t 'median'
}
