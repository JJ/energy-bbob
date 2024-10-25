EXE = $(basename $(SRC))
SRC = $(wildcard *.cc)

CXXFLAGS = -fanalyzer -O3 -Wall

all: $(EXE)

clean:
	-rm -f $(EXE)

.PHONY: all clean
