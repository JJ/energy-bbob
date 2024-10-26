#-----------------------------------------------------------------------------
# fp.gp
#-----------------------------------------------------------------------------

set datafile separator ';'
set key autotitle columnhead
set terminal svg noenhanced
set xtics rotate by 33 right scale 0
set ylabel 'power/energy-pkg/ (Joules)'

#-----------------------------------------------------------------------------
# statistics
#-----------------------------------------------------------------------------

stats 'fp.log' using (column('diff')) name 'diff' nooutput

do for [function in 'bent different discus katsuura rastrigin rosenbrock schaffers schwefel sharp sphere'] {
    stats '<(head -n1 fp.log; grep '.function.' fp.log)' using (column('diff')) name 'diff_'.function nooutput
}

do for [type in 'float double long'] {
    stats '<(head -n1 fp.log; grep ";'.type.'" fp.log)' using (column('diff')) name 'diff_'.type nooutput
}

#-----------------------------------------------------------------------------
# plotting all together
#-----------------------------------------------------------------------------

set output 'fp-all.svg'
plot 'fp.log' using (1):(column('diff')):(0.75):(column('function')) with boxplot linecolor variable notitle, diff_mean w l lc 0 lt 1 lw 2 t 'mean', diff_median w l lc 0 lt 0 lw 2 t 'median'

#-----------------------------------------------------------------------------
# plot by function
#-----------------------------------------------------------------------------

do for [function in 'bent different discus katsuura rastrigin rosenbrock schaffers schwefel sharp sphere'] {
    set output 'fp-'.function.'.svg'
    plot '<(head -n1 fp.log; grep '.function.' fp.log)' using (1):(column('diff')):(0.75):(column('type')) with boxplot linecolor variable notitle
}

#-----------------------------------------------------------------------------
# plot by type
#-----------------------------------------------------------------------------

do for [type in 'float double long'] {
    set output 'fp-'.type.'.svg'
    plot '<(head -n1 fp.log; grep ";'.type.'" fp.log)' using (1):(column('diff')):(0.75):(column('function')) with boxplot linecolor variable notitle, value('diff_'.type.'_mean') w l lc 0 lt 1 lw 2 t 'mean', value('diff_'.type.'_median') w l lc 0 lt 0 lw 2 t 'median'
}