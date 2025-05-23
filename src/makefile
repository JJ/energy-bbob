#------------------------------------------------------------------------------
# makefile
#------------------------------------------------------------------------------

.ONESHELL:

#------------------------------------------------------------------------------

BEN = fp
EXE = $(basename $(SRC))
FUN = bent_cigar different_powers discus katsuura none rastrigin rosenbrock schaffers schwefel sharp_ridge sphere
LEN = 128 256 512
LOG = $(wildcard *.log)
NEW != echo $${HOSTNAME%%.*}-$$(date '+%s').log
POP = 40000
REP = 13
SRC = $(wildcard *.cc)
SVG = $(LOG:.log=.svg)
TMP = $(wildcard *.tmp)
CXXSTD = c++23

#------------------------------------------------------------------------------

# Use make CXX=/opt/homebrew/bin/g++-14 on the Mac with homebrew
ifneq ("$(wildcard /opt/homebrew/bin/g++-14)","")
	CXX = /opt/homebrew/bin/g++-14
else ifneq ("$(wildcard /usr/bin/g++-10)","")
	CXX = g++-10
	CXXSTD = c++2a
endif

CXXFLAGS = -flto -march=native -O3 -Wall -std=$(CXXSTD)

#------------------------------------------------------------------------------

all: exe

clean: stop
	-rm -f $(EXE) $(TMP) *.svg nohup.out core.* *~

exe: $(EXE)

new: $(NEW)

start:
	@sudo sysctl kernel.perf_event_paranoid=-1 &> /dev/null
	sudo cpupower frequency-set --governor performance &> /dev/null
	if [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
		echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost
	fi &> /dev/null

stop:
	@sudo sysctl kernel.perf_event_paranoid=2 &> /dev/null
	sudo cpupower frequency-set --governor powersave &> /dev/null
	if [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
		echo 1 | sudo tee /sys/devices/system/cpu/cpufreq/boost
	fi &> /dev/null

svg: $(SVG)

#------------------------------------------------------------------------------

%.log: $(BEN)
	@make -s start &> /dev/null
	LANG=C
	FORMAT='%s;%s;%s;%s;%s;%s;%s\n'
	printf $$FORMAT function type seed pkg cpu sleep diff | tee $@
	for f in $(FUN); do
		for t in float double long_double; do
			for ((s=0; s<$(REP); s++)); do
				pkg=0.0
				sleep=0.0
				while [ $$(bc <<< "$$pkg <= $$sleep") -eq 1 ]; do
					-perf stat -a -e power/energy-pkg/ 2> $*.tmp -- ./$< -f $$f -s $$s -t $$t
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
	rm -f $*.tmp
	make -s stop &> /dev/null

%.svg: plot.gp
	gnuplot < <(sed "s/^file=.*$$/file='$*.log'/" $<)

#------------------------------------------------------------------------------

.INTERMEDIATE: $(NEW) $(TMP)
.PHONY: all clean exe new start stop svg
.PRECIOUS: $(LOG)

#------------------------------------------------------------------------------
