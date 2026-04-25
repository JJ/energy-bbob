//-------------------------------------------------------------------
// test.cc — unit tests for coco.h BBOB functions
//-------------------------------------------------------------------

#include "coco.h"

#include <cmath>
#include <iostream>
#include <stdexcept>
#include <vector>

//-------------------------------------------------------------------
// Minimal test harness
//-------------------------------------------------------------------

static int tests_run    = 0;
static int tests_failed = 0;

#define CHECK(expr)                                                            \
    do {                                                                       \
        ++tests_run;                                                           \
        if (!(expr)) {                                                         \
            std::cerr << "FAIL [line " << __LINE__ << "]: " #expr "\n";       \
            ++tests_failed;                                                    \
        }                                                                      \
    } while (0)

#define CHECK_CLOSE(a, b, eps)                                                 \
    do {                                                                       \
        ++tests_run;                                                           \
        if (std::fabs((double)(a) - (double)(b)) >= (double)(eps)) {          \
            std::cerr << "FAIL [line " << __LINE__ << "]: |" #a " - " #b      \
                      << "| = " << std::fabs((double)(a) - (double)(b))       \
                      << " >= " << (double)(eps) << "\n";                     \
            ++tests_failed;                                                    \
        }                                                                      \
    } while (0)

#define CHECK_THROWS(expr)                                                     \
    do {                                                                       \
        ++tests_run;                                                           \
        bool threw = false;                                                    \
        try { (void)(expr); } catch (...) { threw = true; }                   \
        if (!threw) {                                                          \
            std::cerr << "FAIL [line " << __LINE__                            \
                      << "]: expected exception not thrown for: " #expr "\n"; \
            ++tests_failed;                                                    \
        }                                                                      \
    } while (0)

//-------------------------------------------------------------------
// sphere_function
//-------------------------------------------------------------------

void test_sphere()
{
    // f(0,...,0) = 0
    std::vector<double> zeros(5, 0.0);
    CHECK(sphere_function<std::vector<double>>(zeros) == 0.0);

    // f(3,4) = 9+16 = 25
    std::vector<double> v34 = {3.0, 4.0};
    CHECK_CLOSE(sphere_function<std::vector<double>>(v34), 25.0, 1e-10);

    // float variant: f(1,1,1) = 3
    std::vector<float> ones_f(3, 1.0f);
    CHECK_CLOSE(sphere_function<std::vector<float>>(ones_f), 3.0f, 1e-5f);

    // single element
    std::vector<double> single = {5.0};
    CHECK_CLOSE(sphere_function<std::vector<double>>(single), 25.0, 1e-10);
}

//-------------------------------------------------------------------
// bent_cigar_function
//-------------------------------------------------------------------

void test_bent_cigar()
{
    // f(0,...,0) = 0
    std::vector<double> zeros(4, 0.0);
    CHECK(bent_cigar_function<std::vector<double>>(zeros) == 0.0);

    // f(1,0) = 1^2 = 1
    std::vector<double> v10 = {1.0, 0.0};
    CHECK_CLOSE(bent_cigar_function<std::vector<double>>(v10), 1.0, 1e-10);

    // f(0,1) = 1e6 * 1^2 = 1e6
    std::vector<double> v01 = {0.0, 1.0};
    CHECK_CLOSE(bent_cigar_function<std::vector<double>>(v01), 1e6, 1e-4);

    // empty input must throw
    std::vector<double> empty;
    CHECK_THROWS(bent_cigar_function<std::vector<double>>(empty));
}

//-------------------------------------------------------------------
// different_powers_function
//-------------------------------------------------------------------

void test_different_powers()
{
    // f(0,...,0) = sqrt(0) = 0
    std::vector<double> zeros(5, 0.0);
    CHECK(different_powers_function<std::vector<double>>(zeros) == 0.0);

    // result is always non-negative (sqrt of a sum of non-negative terms)
    std::vector<double> v = {1.0, 2.0, 3.0, 4.0};
    CHECK(different_powers_function<std::vector<double>>(v) >= 0.0);
}

//-------------------------------------------------------------------
// discus_function
//-------------------------------------------------------------------

void test_discus()
{
    // f(0,...,0) = 0
    std::vector<double> zeros(4, 0.0);
    CHECK(discus_function<std::vector<double>>(zeros) == 0.0);

    // f(1,0,0) = 1e6 * 1^2 + 0 + 0 = 1e6
    std::vector<double> v100 = {1.0, 0.0, 0.0};
    CHECK_CLOSE(discus_function<std::vector<double>>(v100), 1e6, 1e-4);

    // f(0,1,0) = 0 + 1^2 + 0 = 1
    std::vector<double> v010 = {0.0, 1.0, 0.0};
    CHECK_CLOSE(discus_function<std::vector<double>>(v010), 1.0, 1e-10);

    // size <= 1 must throw
    std::vector<double> single = {1.0};
    CHECK_THROWS(discus_function<std::vector<double>>(single));
}

//-------------------------------------------------------------------
// katsuura_function
//-------------------------------------------------------------------

void test_katsuura()
{
    // f(0,...,0) = 0 (result starts at 1, each factor == 1, so (−1+1)*... = 0)
    std::vector<double> zeros(5, 0.0);
    CHECK_CLOSE(katsuura_function<std::vector<double>>(zeros), 0.0, 1e-10);
}

//-------------------------------------------------------------------
// rastrigin_function
//-------------------------------------------------------------------

void test_rastrigin()
{
    // f(0,...,0) = 10*(n - n*cos(0)) + 0 = 0
    std::vector<double> zeros(5, 0.0);
    CHECK_CLOSE(rastrigin_function<std::vector<double>>(zeros), 0.0, 1e-10);

    // result must be non-negative for inputs in [-5, 5]
    std::vector<double> v = {1.0, -1.0, 2.5};
    CHECK(rastrigin_function<std::vector<double>>(v) >= 0.0);
}

//-------------------------------------------------------------------
// rosenbrock_function
//-------------------------------------------------------------------

void test_rosenbrock()
{
    // f(1,...,1) = 0 (global minimum)
    std::vector<double> ones(5, 1.0);
    CHECK_CLOSE(rosenbrock_function<std::vector<double>>(ones), 0.0, 1e-10);

    // size <= 1 must throw
    std::vector<double> single = {1.0};
    CHECK_THROWS(rosenbrock_function<std::vector<double>>(single));
}

//-------------------------------------------------------------------
// schaffers_function
//-------------------------------------------------------------------

void test_schaffers()
{
    // f(0,...,0): each tmp = 0, pow(0,0.25)=0 → result=0, return 0^2=0
    std::vector<double> zeros(4, 0.0);
    CHECK_CLOSE(schaffers_function<std::vector<double>>(zeros), 0.0, 1e-10);

    // size <= 1 must throw
    std::vector<double> single = {1.0};
    CHECK_THROWS(schaffers_function<std::vector<double>>(single));
}

//-------------------------------------------------------------------
// schwefel_function
//-------------------------------------------------------------------

void test_schwefel()
{
    // result must be finite for inputs in [-5, 5]
    std::vector<double> v = {1.0, -2.0, 3.0};
    double val = schwefel_function<std::vector<double>>(v);
    CHECK(std::isfinite(val));

    // penalty is 0 for |x| <= 500; verify via a known computation
    std::vector<double> single_zero = {0.0};
    // For x={0}: penalty=0, result=0*sin(0)=0
    // return 0.01*(penalty + SCHWEFEL_CONST - result/n)
    // where SCHWEFEL_CONST = 418.9828872724339 ≈ 420.9687*sin(π/2)
    // is the per-dimension offset that shifts the global minimum to ≈0.
    const double SCHWEFEL_CONST = 418.9828872724339;
    double sw = schwefel_function<std::vector<double>>(single_zero);
    CHECK_CLOSE(sw, 0.01 * SCHWEFEL_CONST, 1e-8);
}

//-------------------------------------------------------------------
// sharp_ridge_function
//-------------------------------------------------------------------

void test_sharp_ridge()
{
    // f(0,...,0) = 0
    std::vector<double> zeros(5, 0.0);
    CHECK_CLOSE(sharp_ridge_function<std::vector<double>>(zeros), 0.0, 1e-10);

    // size <= 1 must throw
    std::vector<double> single = {1.0};
    CHECK_THROWS(sharp_ridge_function<std::vector<double>>(single));
}

//-------------------------------------------------------------------

int main()
{
    test_sphere();
    test_bent_cigar();
    test_different_powers();
    test_discus();
    test_katsuura();
    test_rastrigin();
    test_rosenbrock();
    test_schaffers();
    test_schwefel();
    test_sharp_ridge();

    std::cout << tests_run - tests_failed << "/" << tests_run
              << " tests passed.\n";

    return tests_failed == 0 ? 0 : 1;
}

//-------------------------------------------------------------------
