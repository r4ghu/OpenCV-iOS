//
//  myfit.hpp
//  Estimate_PlanarWarps
//
//  Created by Sri Raghu Malireddi on 07/10/16.
//  Copyright © 2016 Sri Raghu Malireddi. All rights reserved.
//


#ifndef __Estimate_Homography__myfit__
#define __Estimate_Homography__myfit__

#include <stdio.h>
#include "armadillo" // Includes the armadillo library

// Functions for students to fill-in for Assignment 1
arma::fmat myfit_affine(arma::fmat &X, arma::fmat &W);
arma::fmat myproj_affine(arma::fmat &W, arma::fmat &A);
arma::fmat myfit_homography(arma::fmat &X, arma::fmat &W);
arma::fmat myproj_homography(arma::fmat &W, arma::fmat &H);

#endif /* defined(__Estimate_Homography__myfit__) */
