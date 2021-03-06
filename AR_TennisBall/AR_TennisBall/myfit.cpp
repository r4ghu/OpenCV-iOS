//
//  myfit.cpp
//  AR_TennisBall
//
//  Created by Sri Raghu Malireddi on 19/07/16.
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
    cout<<H<<endl;
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


//-----------------------------------------------------------------
// Function to estimate the extrinsic parameters
//
// <in>
// K = Intrinsics matrix for the device it was caputured from (3x3)
// H = 3x3 homography matrix
//
// <out>
// E = Extrinsic matrix
float lambda;
fmat myfit_extrinsic(fmat &K, fmat &H) {
    
    // Fill in the answer here.....
    fmat Hnew = K.i() * H;
    fmat U,V; fvec s;
    svd(U,s,V,Hnew.cols(0,1));
    fmat L;
    L << 1 << 0 << endr
    << 0 << 1 << endr
    << 0 << 0 << endr;
    //Find the omega
    fmat omega = U*L*V.t();
    fvec o3 = cross(omega.col(0), omega.col(1));
    omega = join_horiz(omega, o3);
    if (det(omega) == -1)
        omega.col(2) = -1*omega.col(2);
    
    //Find the tou
    lambda = accu(Hnew.cols(0,1)/omega.cols(0,1))/6;
    fvec tou = Hnew.col(2)/lambda;
    
    //Calculate the Extrinsic matrix
    fmat E = join_horiz(omega, tou);
    cout << E << endl;
    return E;
}

fmat myproj_extrinsic(fmat &K, fmat &E, fmat &W) {
    fmat X,w,x,xx;
    for (int i=0; i<W.n_cols; i++) {
        w << W(0,i) << W(1,i) << W(2,i) << 1 << endr;
        x = lambda * K * E * w.t();
        xx << x(0,0)/x(2,0) << endr
        << x(1,0)/x(2,0) << endr;
        X = join_horiz(X, xx);
    }
    cout<<X<<endl;
    return X;
}

fmat myproj_translate(fmat &W, fmat &A) {
    
    // Fill in the answer here.....
    fmat X,xi;
    for (int i=0; i<W.n_cols; i++) {
        xi = W.col(i) + A;
        X = join_horiz(X, xi);
    }
    cout << X << endl;
    return X;
}

