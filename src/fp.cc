#include <array>
#include <cmath>
#include <functional>
#include <iostream>
#include <random>
#include <tuple>
#include <unistd.h>

const std::size_t INVIVIDUAL_SIZE = 10, POPULATION_SIZE = 10000;

enum class functions { r, s };
enum class types { f, d, l };

std::mt19937_64 engine;

template<typename T>
using individual = std::array<T, INVIVIDUAL_SIZE>;
template<typename T>
using population = std::array<individual<T>, POPULATION_SIZE>;

std::tuple<functions, types> parser(int argc, char **argv)
{
    functions function = functions::r;
    int option = 0;
    int seed = std::random_device()();
    types type = types::f;

    while ((option = getopt(argc, argv, "f:hs:t:")) != -1)
        switch (option)
        {
            case 'f':
                function =
                    (optarg[0] == 'r') ? functions::r : functions::s;
                break;
            case 'h':
                std::cout << "usage: " << argv[0] << "\n"
                          << "\t[-f (rastrigin|sphere)]\n"
                          << "\t[-t (float|double|long double)]\n"
                          << "\t[-s random seed\n";
                exit(EXIT_SUCCESS);
                break;
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
        }

    engine.seed(seed);

    return {function, type};
}

// https://github.com/numbbo/coco/blob/master/code-experiments/src/f_rastrigin.c
template<typename Container>
typename Container::value_type rastrigin(const Container &container)
{
    typename Container::value_type alpha = 10, n = container.size(),
                                   sum1 = 0, sum2 = 0;
    for (const auto &x : container)
    {
        sum1 += std::cos(2 * M_PI * x);
        sum2 += x * x;
    }
    return alpha * (n - sum1) + sum2;
}

// https://github.com/numbbo/coco/blob/master/code-experiments/src/f_sphere.c
template<typename Container>
typename Container::value_type sphere(const Container &container)
{
    typename Container::value_type result = 0;
    for (const auto &x : container)
        result += x * x;
    return result;
}

template<typename T> T work(functions function)
{
    population<T> pop;
    std::uniform_real_distribution<T> uniform(-5.0, +5.0);
    auto evaluator = (function == functions::r)
                       ? rastrigin<individual<T>>
                       : sphere<individual<T>>;

    T best = std::numeric_limits<T>::min();
    for (auto &ind : pop)
    {
        for (auto &gene : ind)
            gene = uniform(engine);
        best = std::max(best, evaluator(ind));
    }
    return best;
}

int main(int argc, char **argv)
{
    auto [function, type] = parser(argc, argv);

    switch (type)
    {
        case types::f: return work<float>(function); break;
        case types::d: return work<double>(function); break;
        case types::l: return work<long double>(function); break;
    }
}
