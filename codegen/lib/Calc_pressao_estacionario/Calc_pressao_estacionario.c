/*
 * File: Calc_pressao_estacionario.c
 *
 * MATLAB Coder version            : 3.3
 * C/C++ source code generated on  : 30-Mar-2022 16:35:58
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "Calc_pressao_estacionario.h"
#include "calc_p.h"
#include "calc_H.h"
#include "calc_v.h"
#include "calc_th.h"
#include "calc_r.h"
#include "sum.h"

/* Function Definitions */

/*
 * Arguments    : double x
 *                double y
 *                double z
 *                const struct0_T *transdutor
 * Return Type  : creal_T
 */
creal_T Calc_pressao_estacionario(double x, double y, double z, const struct0_T *
  transdutor)
{
  double k;
  int i;
  creal_T p[128];
  creal_T r[128];
  creal_T theta[128];
  creal_T Pax[128];
  double brm;
  double bim;
  creal_T v[128];
  creal_T H[128];
  double d;

  /*  FUN��ES */
  /*      normal_v2 = transdutor.normal2; */
  k = transdutor->k;
  for (i = 0; i < 128; i++) {
    r[i].re = calc_r(transdutor->posx[i], transdutor->posy[i], transdutor->
                     posz[i], x, y, z);
    r[i].im = 0.0;

    /*          if i<=n1/2 */
    theta[i] = calc_th(transdutor->posx[i], transdutor->posy[i],
                       transdutor->posz[i], x, y, z, transdutor->normal, r[i]);

    /*          else */
    /*              theta(:,:,i) = calc_th(x_t(i), y_t(i), z_t(i), x, y, z, normal_v2, r(:,:,i)); */
    /*          end */
    if (r[i].im == 0.0) {
      Pax[i].re = transdutor->A / r[i].re;
      Pax[i].im = 0.0;
    } else if (r[i].re == 0.0) {
      if (transdutor->A == 0.0) {
        Pax[i].re = 0.0 / r[i].im;
        Pax[i].im = 0.0;
      } else {
        Pax[i].re = 0.0;
        Pax[i].im = -(transdutor->A / r[i].im);
      }
    } else {
      brm = fabs(r[i].re);
      bim = fabs(r[i].im);
      if (brm > bim) {
        bim = r[i].im / r[i].re;
        d = r[i].re + bim * r[i].im;
        Pax[i].re = (transdutor->A + bim * 0.0) / d;
        Pax[i].im = (0.0 - bim * transdutor->A) / d;
      } else if (bim == brm) {
        if (r[i].re > 0.0) {
          bim = 0.5;
        } else {
          bim = -0.5;
        }

        if (r[i].im > 0.0) {
          d = 0.5;
        } else {
          d = -0.5;
        }

        Pax[i].re = (transdutor->A * bim + 0.0 * d) / brm;
        Pax[i].im = (0.0 * bim - transdutor->A * d) / brm;
      } else {
        bim = r[i].re / r[i].im;
        d = r[i].im + bim * r[i].re;
        Pax[i].re = bim * transdutor->A / d;
        Pax[i].im = (bim * 0.0 - transdutor->A) / d;
      }
    }

    v[i] = calc_v(k, transdutor->a, theta[i]);
    H[i] = calc_H(v[i]);
    p[i] = calc_p(Pax[i], H[i], transdutor->omega, k, 0.0, r[i],
                  transdutor->phase[i]);
  }

  return sum(p);
}

/*
 * File trailer for Calc_pressao_estacionario.c
 *
 * [EOF]
 */
