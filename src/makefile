#------------------------------------------------------------------------------
# makefile
#------------------------------------------------------------------------------

.ONESHELL:

#------------------------------------------------------------------------------

EXE = $(basename $(SRC))
LOG = $(wildcard *.log)
NEW != echo $${HOSTNAME%%.*}-$$(date '+%s').log
REP = 100
SRC = $(wildcard *.cc)
SVG = $(LOG:.log=.svg)

#------------------------------------------------------------------------------

# Use make CXX=/opt/homebrew/bin/g++-14 on the Mac with homebrew
ifneq ("$(wildcard /opt/homebrew/bin/g++-14)","")
	CXX = /opt/homebrew/bin/g++-14
endif

CXXFLAGS = -march=native -O3 -Wall

#------------------------------------------------------------------------------

all: svg

clean: stop
	-rm -f $(EXE) *.tmp *.svg *~

exe: $(EXE)

run: $(NEW)

start:
	@sudo sysctl kernel.perf_event_paranoid=-1 &> /dev/null
	sudo cpupower frequency-set --governor performance &> /dev/null
	sudo sh -c 'echo 0 > /sys/devices/system/cpu/cpufreq/boost'

stop:
	@sudo sysctl kernel.perf_event_paranoid=2 &> /dev/null
	sudo cpupower frequency-set --governor powersave &> /dev/null
	sudo sh -c 'echo 1 > /sys/devices/system/cpu/cpufreq/boost'

svg: $(SVG)

#------------------------------------------------------------------------------

%.log: fp
	@make -s start
	LANG=C
	FORMAT='%s;%s;%s;%s;%s;%s;%s\n'
	printf $$FORMAT function type seed pkg cpu sleep diff | tee $@
	for f in bent_cigar different_powers discus katsuura rastrigin rosenbrock schaffers schwefel sharp_ridge sphere; do
		for t in float double long_double; do
			for ((s=0; s<$(REP); s++)); do
				pkg=0.0
				sleep=0.0
				while [ $$(bc <<< "$$pkg <= $$sleep") -eq 1 ]; do
					-perf stat -a -e power/energy-pkg/ 2> $*.tmp -- ./fp -f $$f -s $$s -t $$t
					pkg=$$(sed -n 's/[[:space:]]*\([[:digit:].,]*\) Joules .*/\1/p' $*.tmp)
					cpu=$$(grep seconds $*.tmp | tr -s ' ' | cut -d' ' -f2)
					-perf stat -a -e power/energy-pkg/ 2> $*.tmp -- sleep $$cpu
					sleep=$$(sed -n 's/[[:space:]]*\([[:digit:].,]*\) Joules .*/\1/p' $*.tmp)
					diff=$$(bc -l <<< "$$pkg - $$sleep")
				done
				printf $$FORMAT $$f $$t $$s $$pkg $$cpu $$sleep $$diff | tee -a $@
			done
		done
	done
	chmod -w $@
	make -s stop

%.svg: plot.gp
	gnuplot < <(sed "s/^file=.*$$/file='$*.log'/" $<)

#------------------------------------------------------------------------------

.PHONY: all clean exe run start stop svg
.PRECIOUS: $(LOG)

#------------------------------------------------------------------------------
