.ONESHELL:

EXE = $(basename $(SRC))
LOG = $(wildcard *.log)
REP = 100
SRC = $(wildcard *.cc)
SVG = $(LOG:.log=.svg)

CXXFLAGS = -march=native -O3 -Wall

exe: $(EXE)

all: $(SVG)

clean: off
	-rm -f $(EXE) *.tmp *.svg *~

off:
	@sudo sysctl kernel.perf_event_paranoid=2 &> /dev/null
	sudo cpupower frequency-set --governor performance &> /dev/null

on:
	@sudo sysctl kernel.perf_event_paranoid=-1 &> /dev/null
	sudo cpupower frequency-set --governor powersave &> /dev/null

%.log: % | on
	@LANG=C
	FORMAT='%s;%s;%s;%s;%s;%s;%s\n'
	printf $$FORMAT function type seed pkg cpu sleep diff | tee $@
	for f in bent_cigar different_powers discus katsuura rastrigin rosenbrock schaffers schwefel sharp_ridge sphere; do
		for t in float double long_double; do
			for ((s=0; s<$(REP); s++)); do
				pkg=0.0
				sleep=0.0
				while [ $$(bc <<< "$$pkg <= $$sleep") -eq 1 ]; do
					-perf stat -a -e power/energy-pkg/ 2> $<.tmp -- ./$< -f $$f -s $$s -t $$t
					pkg=$$(sed -n 's/[[:space:]]*\([[:digit:].,]*\) Joules .*/\1/p' $<.tmp)
					cpu=$$(grep seconds $<.tmp | tr -s ' ' | cut -d' ' -f2)
					-perf stat -a -e power/energy-pkg/ 2> $<.tmp -- sleep $$cpu
					sleep=$$(sed -n 's/[[:space:]]*\([[:digit:].,]*\) Joules .*/\1/p' $<.tmp)
					diff=$$(bc -l <<< "$$pkg - $$sleep")
				done
				printf $$FORMAT $$f $$t $$s $$pkg $$cpu $$sleep $$diff | tee -a $@
			done
		done
	done
	make -s off

%.svg: %.log | plot.gp
	gnuplot < <(sed "s/^file=.*$$/file='$<'/" plot.gp)

.PHONY: all clean off on
.PRECIOUS: $(LOG)
