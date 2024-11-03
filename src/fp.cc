//-------------------------------------------------------------------
// fp.cc
//-------------------------------------------------------------------

#include "coco.h"

#include <algorithm>
#include <functional>
#include <iostream>
#include <random>
#include <tuple>
#include <unistd.h>
#include <vector>

//-------------------------------------------------------------------

const std::size_t POPULATION_SIZE = 1'000'000;

enum class functions : std::size_t {
    bent_cigar = 0,
    different_powers = 1,
    discus = 2,
    katsuura = 3,
    rastrigin = 4,
    rosenbrock = 5,
    schaffers = 6,
    schwefel = 7,
    sharp_ridge = 8,
    sphere = 9,
    none = 10
};

enum class types { f, d, l, none };

std::mt19937_64 engine;

//-------------------------------------------------------------------

std::tuple<functions, std::size_t, bool, std::size_t, types>
parser(int argc, char **argv)
{
    std::size_t individual_size = 0, population_size = 0;
    functions function = functions::none;
    bool init_only = false;
    int option = 0, seed = std::random_device()();
    types type = types::none;
    std::string_view function_name;

    while ((option = getopt(argc, argv, "f:hi:op:s:t:")) != -1)
        switch (option)
        {
            case 'f':
                function_name = optarg;
                if (function_name == "bent_cigar")
                    function = functions::bent_cigar;
                else if (function_name == "different_powers")
                    function = functions::different_powers;
                else if (function_name == "discus")
                    function = functions::discus;
                else if (function_name == "katsuura")
                    function = functions::katsuura;
                else if (function_name == "rastrigin")
                    function = functions::rastrigin;
                else if (function_name == "rosenbrock")
                    function = functions::rosenbrock;
                else if (function_name == "schaffers")
                    function = functions::schaffers;
                else if (function_name == "schwefel")
                    function = functions::schwefel;
                else if (function_name == "sharp_ridge")
                    function = functions::sharp_ridge;
                else if (function_name == "sphere")
                    function = functions::sphere;
                else
                {
                    std::cerr << argv[0] << ": unknown function "
                              << function_name << '\n';
                    exit(EXIT_FAILURE);
                }
                break;
            case 'h':
                std::cout
                    << "usage: " << argv[0] << "\n"
                    << "\t-f "
                       "(bent_cigar|different_powers|discus|"
                       "katsuura|rastigin|rosenbrock|schaffers|"
                       "schwefel|sharp_ridge|sphere) (required)\n"
                    << "\t-h show this help             (optional)\n"
                    << "\t-i individual size            (required)\n"
                    << "\t-o init only                  (optional)\n"
                    << "\t-p population size            (required)\n"
                    << "\t-s random seed                (optional)\n"
                    << "\t-t (float|double|long_double) (required)\n";
                exit(EXIT_SUCCESS);
            case 'i': init_only = true; break;
            case 'p': population_size = atoi(optarg); break;
            case 's': seed = atoi(optarg); break;
            case 't':
                switch (optarg[0])
                {
                    case 'f': type = types::f; break;
                    case 'd': type = types::d; break;
                    case 'l': type = types::l; break;
                    default:
                        std::cerr << argv[0] << ": unknown type "
                                  << optarg[0] << '\n';
                        exit(EXIT_FAILURE);
                }
                break;
            default:
                std::cerr << argv[0] << ": unknown option\n";
                exit(EXIT_FAILURE);
        }

    if (function == functions::none)
    {
        std::cerr << argv[0] << ": function parameter required!\n";
        exit(EXIT_FAILURE);
    }

    if (individual_size == 0)
    {
        std::cerr << argv[0]
                  << ": individual size parameter required!\n";
        exit(EXIT_FAILURE);
    }

    if (population_size == 0)
    {
        std::cerr << argv[0]
                  << ": population size parameter required!\n";
        exit(EXIT_FAILURE);
    }

    if (type == types::none)
    {
        std::cerr << argv[0] << ": type parameter required!\n";
        exit(EXIT_FAILURE);
    }

    engine.seed(seed);

    return {
        function, individual_size, init_only, population_size, type};
}
 Refactor to use AVX #20
T work(functions function,
       std::size_t individual_size,
       bool init_only,
       std::size_t population_size)
{
    using individual = std::vector<T>;
    using population = std::vector<individual>;

    // initialize population
    population p(population_size, individual(individual_size));
    std::uniform_real_distribution<T> domain(-5.0, +5.0);
    auto rng_domain = std::bind(domain, std::ref(engine));
    for (auto &i : p)
        for (auto &gene : i)
            gene = rng_domain();

    if (init_only)
    {
        // avoid unused code removal
        std::uniform_int_distribution<std::size_t> pop_index(
            0, population_size - 1);
        auto rng_pop = std::bind(pop_index, std::ref(engine));
        std::uniform_int_distribution<std::size_t> ind_index(
            0, individual_size - 1);
        auto rng_ind = std::bind(ind_index, std::ref(engine));
        return p[rng_pop()][rng_ind()];
    }
    else
    {
        // choose evaluator
        auto evaluator = bent_cigar_function<individual>;
        switch (function)
        {
            case functions::bent_cigar:
                evaluator = bent_cigar_function<individual>;
                break;
            case functions::different_powers:
                evaluator = different_powers_function<individual>;
                break;
            case functions::discus:
                evaluator = discus_function<individual>;
                break;
            case functions::katsuura:
                evaluator = katsuura_function<individual>;
                break;
            case functions::rastrigin:
                evaluator = rastrigin_function<individual>;
                break;
            case functions::rosenbrock:
                evaluator = rosenbrock_function<individual>;
                break;
            case functions::schaffers:
                evaluator = schaffers_function<individual>;
                break;
            case functions::schwefel:
                evaluator = schwefel_function<individual>;
                break;
            case functions::sharp_ridge:
                evaluator = sharp_ridge_function<individual>;
                break;
            case functions::sphere:
                evaluator = sphere_function<individual>;
                break;
            default:
                std::cerr << "unknown function\n";
                exit(EXIT_FAILURE);
        }

        // evaluate population
        T max = std::numeric_limits<T>::min();
        for (auto &i : p)
            max = std::max(max, evaluator(i));
        return max;
    }
}

//-------------------------------------------------------------------

int main(int argc, char **argv)
{
    auto [function,
          individual_size,
          init_only,
          population_size,
          type] = parser(argc, argv);

    switch (type)
    {
        case types::f:
            return work<float>(function,
                               individual_size,
                               init_only,
                               population_size);
            break;
        case types::d:
            return work<double>(function,
                                individual_size,
                                init_only,
                                population_size);
            break;
        case types::l:
            return work<long double>(function,
                                     individual_size,
                                     init_only,
                                     population_size);
            break;
        default: std::cerr << "unknown type\n"; exit(EXIT_FAILURE);
    }
}

//-------------------------------------------------------------------
