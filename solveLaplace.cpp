#include <stdint.h>
#include <iostream>
#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <vector>
#include "misc/Eigen/Dense"
#include "misc/Eigen/Sparse"

using namespace Eigen;
using namespace std;

typedef Eigen::SparseMatrix<double> SpMat;
typedef Eigen::Triplet<double> T;

bool insertCoefficient(int id, int i, int j, double w, std::vector<T>& coeffs, Eigen::VectorXd& bX, Eigen::VectorXd& bY,  
                                                        const mwSize* dims, int* BoundaryPoints)
{
  int id1 = i*dims[0]+j;
  if(i==-1 || i==dims[1]) return false;
  else  if(j==-1 || j==dims[0]) return false;
  else  if(BoundaryPoints[id]/*id == 100*dims[0]+120*/){
      if(id==id1){
          coeffs.push_back(T(id,id,1));
      }
      return true;
  }
  else  if(BoundaryPoints[id1]/*i == 100 && j == 120*/){
      bX(id) -= w * bX(id1)/*2*/;
      bY(id) -= w * bY(id1);
      return true;
  }
  else{
      coeffs.push_back(T(id,id1,w));
      return true;
  }
}

void buildProblem(std::vector<T>& coefficients, Eigen::VectorXd& bX, Eigen::VectorXd& bY, const mwSize* dims, int* BoundaryPoints)
{
  for(int i=0; i<dims[1]; ++i)
  {
    for(int j=0; j<dims[0]; ++j)
    {
        int id = i*dims[0]+j;
        int k = 0;
        if(insertCoefficient(id, i-1,j, -1, coefficients, bX, bY, dims, BoundaryPoints)) k++;
        if(insertCoefficient(id, i+1,j, -1, coefficients, bX, bY, dims, BoundaryPoints)) k++;
        if(insertCoefficient(id, i,j-1, -1, coefficients, bX, bY, dims, BoundaryPoints)) k++;
        if(insertCoefficient(id, i,j+1, -1, coefficients, bX, bY, dims, BoundaryPoints)) k++;
        insertCoefficient(id, i,j,    k, coefficients, bX, bY, dims, BoundaryPoints);
    }
  }
}

/*INPUTS:
 * 0 - BoundaryValues: 2 Dimentional array 
 *                     BoundaryValues(i,j): amount of Displacement in X direction for pixel-i-j which is 
 * 1 - BoundaryValues: 2 Dimentional array 
 *                     BoundaryValues(i,j): amount of Displacement in Y direction for pixel-i-j which is 
 *                                          a boundary point.
 * 2 - BoundaryPoints: 2 Dimentional array
 *                     BoundaryPoints(i,j) = 1 for boundary points. 0 otherwise
 *OUTPUTS:
 * 0 - Displacement: 2 Dimentional array
 *                     Displacement(i,j): amount of Displacement in X direction for pixel-i,j
 * 1 - Displacement: 2 Dimentional array
 *                     Displacement(i,j): amount of Displacement in Y direction for pixel-i,j
*/
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    
    /* check for proper number of arguments */
    if(nrhs!=3) {
        mexErrMsgIdAndTxt("MyToolbox:rotateForeground:nrhs","three inputs required.");
    }
    if(nlhs!=2) {
        mexErrMsgIdAndTxt("MyToolbox:rotateForeground:nlhs","two output required.");
    }
    
    double *BoundaryValuesX;
    double *BoundaryValuesY;
    int* BoundaryPoints;
    double* DisplacementX;
    double* DisplacementY;
    
    BoundaryValuesX = (double *)mxGetPr(prhs[0]);
    BoundaryValuesY = (double *)mxGetPr(prhs[1]);
    BoundaryPoints = (int *)mxGetPr(prhs[2]);
    mwSize NumofDim =  mxGetNumberOfDimensions(prhs[0]);
    const mwSize* dims = mxGetDimensions(prhs[0]);
    
    int m = dims[0]*dims[1];
    
    std::vector<T> coefficients;            // list of non-zeros coefficients
    VectorXd bX = Map<VectorXd>(BoundaryValuesX, m);
    VectorXd bY = Map<VectorXd>(BoundaryValuesY, m);
    buildProblem(coefficients, bX, bY, dims, BoundaryPoints);
    SpMat A(m,m);
    A.setFromTriplets(coefficients.begin(), coefficients.end());
    // Solving:
    Eigen::SimplicialCholesky<SpMat> chol(A);  // performs a Cholesky factorization of A
    Eigen::VectorXd xX = chol.solve(bX);         // use the factorization to solve for the given right hand side
    Eigen::VectorXd xY = chol.solve(bY);
    
    
    plhs[0] = mxCreateNumericArray(NumofDim, dims, mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(NumofDim, dims, mxDOUBLE_CLASS, mxREAL);
    /* get a pointer to the real data in the output matrix */
    DisplacementX = (double*)mxGetPr(plhs[0]);
    DisplacementY = (double*)mxGetPr(plhs[1]);
    
    Map<VectorXd>(DisplacementX, m) = xX;
    Map<VectorXd>(DisplacementY, m) = xY;
}
