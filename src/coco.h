// https://github.com/numbbo/coco/blob/master/code-experiments/src/f_rastrigin.c
static double f_rastrigin_raw(const double *x, const size_t number_of_variables) {

  size_t i = 0;
  double result;
  double sum1 = 0.0, sum2 = 0.0;

  if (coco_vector_contains_nan(x, number_of_variables))
    return NAN;

  for (i = 0; i < number_of_variables; ++i) {
    sum1 += cos(coco_two_pi * x[i]);
    sum2 += x[i] * x[i];
  }
  if (coco_is_inf(sum2)) // cos(inf) -> nan
    return sum2;
  result = 10.0 * ((double) (long) number_of_variables - sum1) + sum2;

  return result;
}

// https://github.com/numbbo/coco/blob/master/code-experiments/src/f_sphere.c
static double f_sphere_raw(const double *x, const size_t number_of_variables) {

  size_t i = 0;
  double result;

  if (coco_vector_contains_nan(x, number_of_variables))
    return NAN;

  result = 0.0;
  for (i = 0; i < number_of_variables; ++i) {
    result += x[i] * x[i];
  }

  return result;
}
