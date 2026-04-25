# Consumption of energy computed for BBOB functions


This repository was created for the paper *Measuring energy consumption of BBOB
fitness functions*, by Merelo-Guervós & Romero-López (UGR) García Valdez
(Tec-Tijuana), accepted in the [EvoStar 2025](https://evostar.org/2025)
conference.

## Instructions

In this repository you can find the [paper](paper/), [code for experiments
run](code/), as well ad the [data](data/) generated in the experiments.

## Papers published

### Measuring Energy Consumption of BBOB Fitness Functions

This [paper was published in the Evostar 2025
conference](https://link.springer.com/chapter/10.1007/978-3-031-90065-5_15). Here's
the BiBTeX entry:

```bibtex
@InProceedings{10.1007/978-3-031-90065-5_15,
author="Merelo-Guerv{\'o}s, Juan J.
and Romero L{\'o}pez, Gustavo
and Garc{\'i}a-Valdez, Mario",
editor="Garc{\'i}a-S{\'a}nchez, Pablo
and Hart, Emma
and Thomson, Sarah L.",
title="Measuring Energy Consumption of BBOB Fitness Functions",
booktitle="Applications of Evolutionary Computation",
year="2025",
publisher="Springer Nature Switzerland",
address="Cham",
pages="240--254",
abstract="Making software greener is a process that includes identifying the functions that consume the most energy, developing a methodology that can measure precisely that energy consumption and eventually measuring that energy under different design decisions and circumstances to be able to, eventually, produce best practices for minimizing said consumption. In this paper we are focusing on well-known floating-point fitness functions: some functions included in the black box optimization benchmark that cover all different types of functions under study. In general, these fitness functions will be the single operation that consumes the most energy; this is why in this paper we use them to test a methodology that is able to measure the energy consumed by their implementation in a low-level language C++. We test different single-element representations (single and double precision) as well as individual level representation (fixed size vs. variable size), drawing conclusions on the adequacy and accuracy of the methodology as well as which combination of the above elements would consume the least.",
isbn="978-3-031-90065-5"
}
```

Check also out the [presentation](preso/index.html) at the conference in
Trieste, including its relationship to Joyce, Italo Svevo and the city at
large. The state of the repository at the moment of publication is in the
[Evostar25 released
version](https://github.com/JJ/energy-bbob/releases/tag/v1.0Evostar).

## LICENSE

This repository and all its contents are released under a GPL license. Check the
[
`LICENSE`](LICENSE) file for details.
