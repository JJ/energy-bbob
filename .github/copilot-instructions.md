# Copilot Instructions for energy-bbob

## Repository Overview

This repository supports a research project on **measuring and minimizing the energy consumption of BBOB (Black Box Optimization Benchmark) floating-point fitness functions** implemented in C++. It contains two published academic papers, all experimental data, analysis scripts, and the C++ benchmark programs used to collect measurements.

**Authors**: Juan J. Merelo-Guervós & Gustavo Romero López (University of Granada), Mario García-Valdez (Tec-Tijuana).

---

## Repository Structure

```
energy-bbob/
├── paper/          # .Rnw papers (LaTeX + knitr), bibliography (.bib), figures
├── data/           # CSV files with raw experimental measurements
├── src/            # C++ benchmark programs and BBOB function headers
├── script/         # Perl scripts that run experiments via pinpoint
├── lib/            # Perl utility module (Utils.pm)
├── preso/          # Reveal.js presentation (index.html)
└── img/            # Generated plots (PNG) saved by R scripts
```

---

## The .Rnw File Format (Primary Content)

`.Rnw` files are the core of this repository. They are **Literate Programming** documents combining:
- **LaTeX** markup for text, sections, citations, figures, equations
- **knitr R code chunks** delimited by `<<chunk-name, options>>=` … `@`

The R chunks perform all data loading, statistical analysis, and plot generation inline inside the paper text. Understanding a `.Rnw` file requires reading both the LaTeX prose and the embedded R code together.

### Building the papers

From the `paper/` directory:
```bash
make          # builds all .pdf files from all .Rnw files
```

The build pipeline is:
1. `Rscript -e "knitr::knit('paper.Rnw', output='paper.tex')"` — executes R chunks, produces `.tex`
2. `latexmk -pdf -shell-escape paper.tex` — compiles LaTeX to PDF

Required R packages: `knitr`, `ggplot2`, `ggthemes`, `dplyr`, `kableExtra`
Install them via: `make install` (in `paper/`), which calls `sudo R -e "install.packages(...)"`.

The `.R` tangle file (e.g., `fp-evostar-2025.R`) is automatically extracted from the `.Rnw` and contains only the R code chunks — useful for running analysis independently of the paper build.

---

## The Two Papers

### 1. `paper/fp-evostar-2025.Rnw` — Main Paper (EvoStar 2025)
**Title**: *Measuring energy consumption of BBOB fitness functions*

This is the primary paper. It introduces the methodology and presents the main experimental results. Key content:
- **Methodology**: Use `pinpoint` to measure whole-system PKG (CPU+memory) energy via RAPL while a single-threaded C++ process runs. Subtract a *baseline* (chromosome generation only) from function measurements to isolate function energy.
- **Experiments**: 40,000 chromosomes evaluated 30 times per configuration; variables are:
  - **type**: `float` (f) vs `double` (d)
  - **size**: 128, 256, 512 (chromosome dimension)
  - **data structure**: variable-size `std::vector` vs fixed-size `std::array`
  - **function**: 10 selected BBOB functions (see below)
- **Key finding**: Double precision + `std::vector` generally consumes the least energy. Float vs double differences are small or negligible except for `katsuura`. Fixed-size `std::array` is dramatically cheaper for chromosome *generation* (~1/8th energy) but shows mixed results for function *evaluation*.
- **Known issue**: The BBOB-published implementation of `katsuura` contains a bug that prevents it from computing the correct mathematical value, but this does not affect energy measurements.
- **Limitation**: Advanced compiler optimizations (`-O3 -flto -march=native`) sometimes fold simple function evaluation into the generation loop, yielding unmeasurable (zero) delta energy for lightweight functions (`bent_cigar`, `discus`, `different_powers` at small sizes).

### 2. `paper/energy-temperature.Rnw` — Poster Paper (EuroParallel/similar venue)
**Title**: *Time-related effects in the measurement of energy consumption in evolutionary algorithms*

A follow-up poster that reanalyzes the data from the main paper to investigate temporal and path-dependent effects:
- Energy consumption oscillates (up and down) over time — no monotonic temperature-driven increase.
- Power drawn decreases with experiment duration for short runs (CPU frequency scaling).
- **Proposed statistical summary**: Use the **75th percentile** of watts/PKG rather than the mean, to capture worst-case energy behavior and account for inherent variability.
- Focuses on three representative functions: `katsuura` (highest consumption), `schaffers` (medium), `bent_cigar` (lowest).

---

## BBOB Functions Studied

The 10 functions selected from the 24-function BBOB suite, grouped by type:

| Function | BBOB Group | Relative Energy |
|---|---|---|
| `sphere` | Separable | Low |
| `rastrigin` | Separable | Medium-high |
| `rosenbrock` | Low/moderate conditioning | Very low (≈0 at size 128) |
| `discus` | High conditioning/unimodal | Low |
| `bent_cigar` | High conditioning/unimodal | Very low |
| `different_powers` | High conditioning/unimodal | Low–medium |
| `sharp_ridge` | High conditioning/unimodal | Low |
| `schaffers` | Multimodal, adequate structure | Medium |
| `schwefel` | Multimodal, weak structure | Medium |
| `katsuura` | Multimodal, weak structure | **Highest** (order of magnitude above next) |

---

## Data Files

All CSVs are in `data/`. Column meanings:

- **`work`**: BBOB function name, or `generation`/`none` for baseline
- **`type`**: ` f` (float) or ` d` (double) — note the leading space in raw CSV values
- **`size`**: chromosome dimension (128, 256, 512)
- **`PKG`**: energy consumed in **Joules** (RAPL PKG domain = CPU + memory, excluding peripherals)
- **`seconds`**: wall-clock time of the run

Derived variable used in papers: `watts = PKG / seconds` (average power in watts).

| File | Description |
|---|---|
| `evostar25-generation-5-Nov-07-30-15.csv` | Baseline: variable-size vector generation (float/double, all sizes) |
| `fixed-evostar25-generation-5-Nov-07-37-13.csv` | Baseline: fixed-size array generation (size=128 only) |
| `variable-evostar25-bbob-10-Nov-19-10-32.csv` | BBOB function evaluation, variable-size vector (all functions, types, sizes) |
| `evostar25-bbob-fixed-12-Nov-08-20-03.csv` | BBOB function evaluation, fixed-size array (size=128 only) |
| `test-3-Nov-20-39-24.csv` | Small test file with different column format (`Platform,size,PKG,seconds`) |

---

## C++ Source Code (`src/`)

- **`fp.cc`**: Variable-size (`std::vector<T>`) benchmark. Compiled as `fp`. Accepts CLI flags:
  - `-f <function>`: BBOB function to evaluate (or `none` for baseline)
  - `-t <f|d|l>`: type (float, double, long_double)
  - `-i <size>`: individual/chromosome size (default 128)
  - `-p <pop>`: population size (default 40000)
  - `-s <seed>`: RNG seed
- **`fp-fixed.cc`**: Fixed-size (`std::array<T, N>`) benchmark. Compiled as `fp-fixed`. Size is a compile-time template parameter, requiring separate compilation per size.
- **`coco.h`**: Header-only adaptation of BBOB/COCO functions templated over numeric type T (float or double), so the same function body measures both precisions.
- **`makefile`**: Builds executables, runs experiments using `perf stat -e power/energy-pkg/`, saves to timestamped `.log` files. Before experiments: sets CPU governor to `performance` and disables boost. After: restores defaults.

Compiler flags: `-flto -march=native -O3 -Wall -std=c++2a` (or `c++23` on newer systems).

---

## Experiment Execution Scripts (`script/`)

- **`measure-functions.pl`**: Runs the `fp` binary for all BBOB functions × types × sizes using `pinpoint`. Writes to `data/<prefix>-bbob-<timestamp>.csv`. Requires 30 successful (non-zero PKG) measurements per configuration.
- **`measure-fixed-functions.pl`**: Same but for the fixed-size `fp-fixed` binary.
- **`run-pinpoint-command.pl`**: Generic pinpoint runner.
- **`run-pinpoint-fixed-size.pl`**: Pinpoint runner for fixed-size experiments.
- **`energy-temperature.R`** and **`watts-order.R`**: Standalone R scripts to generate enhanced figures for the poster and presentation (saved to `img/`).
- **`lib/Utils.pm`**: Perl module with `process_pinpoint_output` (parses GPU, PKG Joules, seconds from pinpoint output) and `process_powermetrics_output` (for macOS powermetrics).

---

## Measurement Methodology Summary

1. **Tool**: `pinpoint` — wraps a command and reports energy in Joules using RAPL (Running Average Power Limit) on Linux (AMD/Intel), or equivalent APIs on other platforms.
2. **Baseline subtraction**: Mean PKG from chromosome generation runs is subtracted from function evaluation PKG to isolate the function's energy cost (`delta.PKG`).
3. **Filtering**: Runs where pinpoint reports 0 J are discarded and retried (they indicate measurement failure).
4. **Repetitions**: 30 per configuration.
5. **System setup**: CPU performance governor, no frequency boost, single-threaded execution on AMD Ryzen 9 3950X, Ubuntu 20.04, g++ 10.5.0.
6. **PKG sensor**: Covers CPU + memory (not peripherals). RAPL accuracy is ~5%, meaning functions consuming <5% of total measured energy are effectively in the noise floor.

---

## Generating Additional Content from the Papers

When expanding on the papers, the data files and R code chunks are the primary resources. To produce new analysis or visualizations:

1. **Load data the same way the papers do** — use the CSV files in `data/` with the same column names and the same leading-space quirk in `type` values (` f`, ` d`).
2. **Derive `watts`** as `PKG / seconds` for power analysis.
3. **Use `delta.PKG`** (baseline-subtracted energy) for function energy comparisons, clamped to ≥ 0.
4. **The R script `fp-evostar-2025.R`** (extracted tangle) contains all analysis code from the main paper and is a good starting point.
5. **Preferred plot style**: ggplot2 with `scale_y_log10()` for energy comparisons (the range spans orders of magnitude), `scale_color_brewer(palette="Set1")` for type coloring, boxplots for distributions, scatter plots for PKG vs time.
6. **Statistical summary**: Use 75th percentile (not mean) for energy/power comparisons, as noted in the poster paper.

### Suggested expansion directions
- **Per-function deep dives**: Each of the 10 BBOB functions could have its own analysis section exploring how energy scales with chromosome size and how float vs double differ.
- **Improved visualization**: Violin plots or ridgeline plots to better show multi-modal energy distributions; faceted plots showing all functions and sizes together.
- **Practical guidance**: Translate the per-Joule differences into CO₂ equivalents or cost estimates for a full evolutionary algorithm run.
- **Methodology improvements**: Discussion of alternative baselines, or approaches to measure lightweight functions that currently show zero delta (e.g., compiler-fencing techniques like `volatile` or separate compilation units).
- **Ideas for new papers**: Testing additional BBOB functions not included (14 remain untested); testing `long double`; testing higher chromosome sizes (1024+); testing different compilers (clang, MSVC) or architectures (ARM, Intel); measuring memory allocation costs separately; applying transprecision (binary8/binary16alt) representations.

---

## Known Issues / Errors Encountered

- **`katsuura` BBOB implementation bug**: The BBOB-published implementation of `katsuura` is mathematically incorrect (the authors note this in the paper footnote). This does not affect energy measurement results — it only means the function does not compute the correct Katsuura value.
- **Zero delta energy for lightweight functions**: `bent_cigar`, `discus`, `different_powers`, `schwefels` at size=128 with `float` show zero or near-zero `delta.PKG` because the compiler folds their evaluation into the generation loop. These results are correctly handled by `pmax(delta.PKG, 0)` in the R code.
- **RAPL 5% accuracy floor**: Functions that consume <5% of the total measured PKG energy fall within measurement noise. Only heavy functions (`katsuura`, `rastrigin`, `schaffers`) give reliably measurable delta values.
- **leading space in `type` column**: Raw CSV values are ` f` and ` d` (with a leading space). R code uses these as-is in factor comparisons. Be aware of this when filtering: `functions.data$type == " f"` (note the space).
- **`fp-fixed.cc` size constraint**: Fixed-size arrays require compile-time dimensions. The experiments only cover size=128 for this variant.
- **Ubuntu 20.04 / g++ 10.5.0 constraint**: The makefile detects the compiler and uses `c++2a` on older systems, `c++23` on newer ones. Results may differ on other compiler versions.
