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

//-------------------------------------------------------------------

std::tuple<functions, types>
parser(int argc, char **argv)
{
    functions function = functions::none;
    int option = 0;
    types type = types::f;
    std::string_view function_name;

    while ((option = getopt(argc, argv, "f:ht:")) != -1)
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
                break;
            case 'h':
                std::cout
                    << "usage: " << argv[0] << "\n"
                    << "\t-f "
                       "(bent_cigar|different_powers|discus|"
                       "katsuura|none|rastigin|rosenbrock|schaffers|"
                       "schwefel|sharp_ridge|sphere) (required)\n"
                    << "\t-h show this help             (optional)\n"
                    << "\t-t (float|double|long_double) (required)\n";
                exit(EXIT_SUCCESS);
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
        }

    return {function, type};
}

//-------------------------------------------------------------------

template<typename T>
T work(functions function)
{
    const std::size_t INDIVIDUAL_SIZE = 100, POPULATION_SIZE = 40'000;
    using individual = std::array<T, INDIVIDUAL_SIZE>;
    using population = std::vector<individual>;

    // initialize population
    std::cout << "INDIVIDUAL_SIZE = " << INDIVIDUAL_SIZE << '\n'
              << "POPULATION_SIZE = " << POPULATION_SIZE << '\n';
    population p(POPULATION_SIZE);
    std::uniform_real_distribution<T> domain(-5.0, +5.0);
    std::mt19937_64 engine;
    engine.seed(std::random_device()());
    auto rng_domain = std::bind(domain, std::ref(engine));
    for (auto &i : p)
        for (auto &gene : i)
            gene = rng_domain();

    if (function == functions::none)
    {
        // no evaluation must avoid unused code removal
        std::uniform_int_distribution<std::size_t> pop_index(
            0, POPULATION_SIZE - 1);
        auto rng_pop = std::bind(pop_index, std::ref(engine));
        std::uniform_int_distribution<std::size_t> ind_index(
            0, INDIVIDUAL_SIZE - 1);
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

    auto [function, type] =
        parser(argc, argv);

    long double result = 0.0;

    switch (type)
    {
        case types::f:
            result = work<float>(function);
            break;
        case types::d:
            result = work<double>(function);
            break;
        case types::l:
            result = work<long double>(function);
            break;
        default:
            std::cerr << "unknown type\n";
            exit(EXIT_FAILURE);
    }

    std::cout << "Result: " << result << '\n';
    return 0;
}

//-------------------------------------------------------------------
