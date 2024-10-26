.ONESHELL:

EXE = $(basename $(SRC))
LOG = $(EXE:=.log)
REP = 10
SRC = $(wildcard *.cc)
SVG = $(EXE:=.svg)

CXXFLAGS = -march=native -O3 -Wall

all: $(EXE)

clean: off
	-rm -f $(EXE) $(LOG) *.tmp *.svg *~

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
	for f in 'bent cigar' 'different powers' 'discus' 'katsuura' 'rastrigin' 'rosenbrock' 'schaffers' 'schwefel' 'sharp ridge' 'sphere'; do
		for t in 'float' 'double' 'long double'; do
			for ((s=0; s<$(REP); s++)); do
				pkg=0.0
				sleep=0.0
				while [ $$(bc <<< "$$pkg <= $$sleep") -eq 1 ]; do
					-perf stat -a -e power/energy-pkg/ 2> $<.tmp -- ./$< -f "$$f" -s $$s -t "$$t"
					pkg=$$(sed -n 's/[[:space:]]*\([[:digit:].,]*\) Joules .*/\1/p' $<.tmp)
					cpu=$$(grep seconds $<.tmp | tr -s ' ' | cut -d' ' -f2)
					-perf stat -a -e power/energy-pkg/ 2> $<.tmp -- sleep $$cpu
					sleep=$$(sed -n 's/[[:space:]]*\([[:digit:].,]*\) Joules .*/\1/p' $<.tmp)
					diff=$$(bc -l <<< "$$pkg - $$sleep")
				done
				printf $$FORMAT "$$f" "$$t" $$s $$pkg $$cpu $$sleep $$diff | tee -a $@
			done
		done
	done
	make -s off

%.svg: %.gp %.log
	gnuplot $<

.PHONY: all clean off on
.PRECIOUS: $(LOG)
