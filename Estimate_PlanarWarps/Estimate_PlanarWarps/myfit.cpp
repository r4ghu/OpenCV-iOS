//
//  myfit.cpp
//  Estimate_PlanarWarps
//
//  Created by Sri Raghu Malireddi on 07/10/16.
//  Copyright © 2016 Sri Raghu Malireddi. All rights reserved.
//

#include "myfit.h"

// Use the Armadillo namespace
using namespace arma;

//-----------------------------------------------------------------
// Function to return the affine warp between 3D points on a plane
//
// <in>
// X = concatenated matrix of 2D projected points in the image (2xN)
// W = concatenated matrix of 3D points on the plane (3XN)
//
// <out>
// A = 2x3 matrix of affine parameters
fmat myfit_affine(fmat &X, fmat &W) {
    
    // Fill in the answer here.....
    fmat A,B;
    for (int i=0; i<X.n_cols; i++) {
        B << W(0,i) << W(1,i) << 0 << 0 << 1 << 0 <<endr
        << 0 << 0 << W(0,i) << W(1,i) << 0 << 1 << endr;
        A = join_vert(A,B);
    }
    cout<<A<<endl;
    fvec p = solve(A, vectorise(X));
    cout<<p<<endl;
    fmat C;
    C << p(0) << p(1) << p(4) << endr
    << p(2) << p(3) << p(5) << endr;
    return C;
}
//-----------------------------------------------------------------
// Function to project points using the affine transform
//
// <in>
// W = concatenated matrix of 3D points on the plane (3XN)
// A = 2x3 matrix of affine parameters
//
// <out>
// X = concatenated matrix of 2D projected points in the image (2xN)
fmat myproj_affine(fmat &W, fmat &A) {
    
    // Fill in the answer here.....
    fmat X,xi;
    for (int i=0; i<W.n_cols; i++) {
        xi = A*W.col(i) + A.col(2);
        X = join_horiz(X, xi);
    }
    cout << X << endl;
    return X;
}

//-----------------------------------------------------------------
// Function to return the affine warp between 3D points on a plane
//
// <in>
// X = concatenated matrix of 2D projected points in the image (2xN)
// W = concatenated matrix of 3D points on the plane (3XN)
//
// <out>
// H = 3x3 homography matrix
fmat myfit_homography(fmat &X, fmat &W) {
    
    // Fill in the answer here.....
    fmat A,B;
    for (int i=0; i<X.n_cols; i++) {
        B << 0 << 0 << 0 << -W(0,i) << -W(1,i) << -1 << X(1,i)*W(0,i) << X(1,i)*W(1,i) << X(1,i) << endr
        << W(0,i) << W(1,i) << 1 << 0 << 0 << 0 << -X(0,i)*W(0,i) << -X(0,i)*W(1,i) << -X(0,i) << endr;
        A = join_vert(A, B);
    }
    fmat U, V; fvec s;
    svd(U,s,V,A);
    fmat H;
    H << V(0,V.n_cols-1) << V(1,V.n_cols-1) << V(2,V.n_cols-1) << endr
    << V(3,V.n_cols-1) << V(4,V.n_cols-1) << V(5,V.n_cols-1) << endr
    << V(6,V.n_cols-1) << V(7,V.n_cols-1) << V(8,V.n_cols-1) << endr;
    return H;
}

//-----------------------------------------------------------------
// Function to project points using the affine transform
//
// <in>
// W = concatenated matrix of 3D points on the plane (3XN)
// H = 3x3 homography matrix
//
// <out>
// X = concatenated matrix of 2D projected points in the image (2xN)
fmat myproj_homography(fmat &W, fmat &H) {
    
    // Fill in the answer here.....
    fmat X,xi,xii,point;
    for (int i=0; i<W.n_cols; i++) {
        point << W(0,i) << W(1,i) << 1 << endr;
        xi = H*point.t();
        xii << xi(0,0)/xi(2,0) << endr
        << xi(1,0)/xi(2,0) <<endr;
        X = join_horiz(X, xii);
    }
    cout << X << endl;
    return X;
    //fmat X = H*W; return X;
}
