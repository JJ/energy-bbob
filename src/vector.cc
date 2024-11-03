#include "coco.h"

#include <algorithm>
#include <functional>
#include <iostream>
#include <random>
#include <ranges>
#include <tuple>
#include <unistd.h>
#include <vector>

const std::size_t INDIVIDUAL_SIZE = 100, POPULATION_SIZE = 400'000;

template<typename T> using individual = std::vector<T>;

template<typename T> using population = std::vector<individual<T>>;

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

std::tuple<functions, types> parser(int argc, char **argv)
{
    functions function = functions::none;
    int option = 0;
    int seed = std::random_device()();
    types type = types::none;

    while ((option = getopt(argc, argv, "f:hs:t:")) != -1)
        switch (option)
        {
            case 'f':
                {
                    std::string function_name(optarg);
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
                }
            case 'h':
                {
                    std::cout
                        << "usage: " << argv[0] << "\n"
                        << "\t -f "
                           "(bent_cigar|different_powers|discus|"
                           "katsuura|rastigin|rosenbrock|schaffers|"
                           "schwefel|sharp_ridge|sphere)\n"
                        << "\t[-h show this help]\n"
                        << "\t[-s random seed]\n"
                        << "\t -t (float|double|long_double)\n";
                    exit(EXIT_SUCCESS);
                }
            case 's':
                {
                    seed = atoi(optarg);
                    break;
                }
            case 't':
                {
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
                }
            default:
                {
                    std::cerr << argv[0] << ": unknown option\n";
                    exit(EXIT_FAILURE);
                }
        }

    if (function == functions::none)
    {
        std::cerr << argv[0] << ": required parameter function\n";
        exit(EXIT_FAILURE);
    }

    if (type == types::none)
    {
        std::cerr << argv[0] << ": required parameter type\n";
        exit(EXIT_FAILURE);
    }

    engine.seed(seed);

    return {function, type};
}

template<typename T> T work(functions function)
{
    auto evaluator = bent_cigar_function<individual<T>>;

    switch (function)
    {
        case functions::bent_cigar:
            evaluator = bent_cigar_function<individual<T>>;
            break;
        case functions::different_powers:
            evaluator = different_powers_function<individual<T>>;
            break;
        case functions::discus:
            evaluator = discus_function<individual<T>>;
            break;
        case functions::katsuura:
            evaluator = katsuura_function<individual<T>>;
            break;
        case functions::rastrigin:
            evaluator = rastrigin_function<individual<T>>;
            break;
        case functions::schaffers:
            evaluator = schaffers_function<individual<T>>;
            break;
        case functions::schwefel:
            evaluator = schwefel_function<individual<T>>;
            break;
        case functions::sharp_ridge:
            evaluator = sharp_ridge_function<individual<T>>;
            break;
        case functions::sphere:
            evaluator = sphere_function<individual<T>>;
            break;
        default:
            std::cerr << "unknown function\n";
            exit(EXIT_FAILURE);
    }

    // initialize population
    population<T> pop(POPULATION_SIZE,
                      individual<T>(INDIVIDUAL_SIZE));
    std::uniform_real_distribution<T> domain(-5.0, +5.0);
    auto rng_domain = std::bind(domain, std::ref(engine));
    for (auto &ind : pop)
        for (auto &gene : ind)
            gene = rng_domain();

    // evaluate population
    T max = std::numeric_limits<T>::min();
    for (auto &ind : pop)
        max = std::max(max, evaluator(ind));
    return max;
}

int main(int argc, char **argv)
{
    auto [function, type] = parser(argc, argv);

    switch (type)
    {
        case types::f: return work<float>(function); break;
        case types::d: return work<double>(function); break;
        case types::l: return work<long double>(function); break;
        default: std::cerr << "unknown type\n"; exit(EXIT_FAILURE);
    }
}
