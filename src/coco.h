//-------------------------------------------------------------------
// coco.h
//-------------------------------------------------------------------

#ifndef COCO_H
#define COCO_H 1

//-------------------------------------------------------------------

// functions adapted from
// https://github.com/numbbo/coco/blob/master/code-experiments/src/

//-------------------------------------------------------------------

#include <cmath>
#include <stdexcept>

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T bent_cigar_function(const Container &x)
{
    if (x.size() == 0) {
        throw std::invalid_argument("Bent Cigar function requires at least 1 variable");
    }
    T result = x[0] * x[0];
    for (std::size_t i = 1; i < x.size(); ++i)
        result += 1.0e6 * x[i] * x[i];
    return result;
}

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T different_powers_function(const Container &x)
{
    T sum = 0.0;
    for (std::size_t i = 0; i < x.size() - 1; ++i)
    {
        T exponent = 2.0 + (4.0 * i) / (x.size() - 1.0);
        sum += std::pow(std::fabs(x[i]), exponent);
    }
    return std::sqrt(sum);
}

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T discus_function(const Container &x)
{
    if (x.size() <= 1) {
        throw std::invalid_argument("Discus function requires at least 2 variable");
    }
    T result = 1.0e6 * x[0] * x[0];
    for (std::size_t i = 1; i < x.size(); ++i)
        result += x[i] * x[i];
    return result;
}

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T katsuura_function(const Container &x)
{
    T result = 1.0;
    for (std::size_t i = 0; i < x.size(); ++i)
    {
        T tmp = 0.0;
        for (std::size_t j = 1; j < 33; ++j)
        {
            T tmp2 = std::pow((T)2.0, (T)j);
            tmp += std::fabs(tmp2 * x[i] - std::round(tmp2 * x[i])) /
                   tmp2;
        }
        tmp = 1.0 + (i + 1) * tmp;
        result *= std::pow(tmp, 10.0 / std::pow((T)x.size(), (T)1.2));
    }
    return 10.0 / ((T)x.size() / (T)x.size()) * (-1.0 + result);
}

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T rastrigin_function(const Container &x)
{
    T sum1 = 0.0, sum2 = 0.0;
    for (std::size_t i = 0; i < x.size(); ++i)
    {
        sum1 += std::cos(2.0 * M_PI * x[i]);
        sum2 += x[i] * x[i];
    }
    return 10.0 * (x.size() - sum1) + sum2;
}

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T rosenbrock_function(const Container &x)
{
    if ( x.size() <= 1) {
        throw std::invalid_argument("Rosenbrock function requires at least 2 variables");
    }
    T s1 = 0.0, s2 = 0.0;
    for (std::size_t i = 0; i < x.size() - 1; ++i)
    {
        T tmp = (x[i] * x[i] - x[i + 1]);
        s1 += tmp * tmp;
        tmp = (x[i] - 1.0);
        s2 += tmp * tmp;
    }
    return 100.0 * s1 + s2;
}

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T schaffers_function(const Container &x)
{
    if (x.size() <= 1) {
        throw std::invalid_argument("Discus function requires at least 2 variables");
    }
    T result = 0.0;
    for (std::size_t i = 0; i < x.size() - 1; ++i)
    {
        T tmp = x[i] * x[i] + x[i + 1] * x[i + 1];
        if (std::isinf(tmp) &&
            std::isnan(std::sin(50.0 * std::pow(tmp, 0.1))))
            return tmp;
        result += std::pow(tmp, 0.25) *
                  (1.0 + std::pow(std::sin(50.0 * std::pow(tmp, 0.1)),
                                  2.0));
    }
    return std::pow(result / (T)(x.size() - 1), 2.0);
}

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T schwefel_function(const Container &container)
{
    // boundary handling
    T penalty = 0.0;
    for (const T &x : container)
    {
        const T tmp = std::fabs(x) - 500.0;
        if (tmp > 0.0)
            penalty += tmp * tmp;
    }

    // computation core
    T result = 0.0;
    for (const T &x : container)
        result += x * std::sin(std::sqrt(std::fabs(x)));
    return 0.01 * (penalty + 418.9828872724339 -
                   result / (T)container.size());
}

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T sharp_ridge_function(const Container &x)
{
    if( x.size() <= 1 ) {
        throw std::invalid_argument( "Sharp Ridge function requires at least 2 variables");
    }
    const T d_vars_40 = x.size() <= 40 ? 1.0 : x.size() / 40.0;
    const size_t vars_40 = std::ceil(d_vars_40);
    T result = 0.0;

    for (std::size_t i = vars_40; i < x.size(); ++i)
        result += x[i] * x[i];
    result = 100.0 * std::sqrt(result / d_vars_40);
    for (std::size_t i = 0; i < vars_40; ++i)
        result += x[i] * x[i] / d_vars_40;
    return result;
}

//-------------------------------------------------------------------

template<typename Container,
         typename T = typename Container::value_type>
T sphere_function(const Container &container)
{
    T result = 0.0;
    for (const T &x : container)
        result += x * x;
    return result;
}

//-------------------------------------------------------------------

#endif // COCO_H
