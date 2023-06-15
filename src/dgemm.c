// We start by rewriting the Python program from Section 1.10. Figure 2.43 shows a
// version of a matrix–matrix multiply written in C. This program is commonly called
// DGEMM, which stands for Double-precision General Matrix Multiply. Because
// we are passing the matrix dimension as the parameter , this version of DGEMM
// uses single-dimensional versions of matrices, and and address arithmetic to get
// better performance instead of using the more intuitive two-dimensional arrays that we saw in Python.

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

double randfrom(double min, double max) 
{
    double range = (max - min); 
    double div = RAND_MAX / range;
    return min + (rand() / div);
}

void square_dgemm(int n, double *A, double *B, double *C)
{
    for (int i = 0; i < n; ++i)
    {
        for (int j = 0; j < n; ++j)
        {
            double cij = C[i + j * n];
            for (int k = 0; k < n; k++)
                cij += A[i + k * n] * B[k + j * n];
            C[i + j * n] = cij;
        }
    }
}

// create larger random matrices, call DGEMM and time it
int main()
{
    int n = 25000;
    clock_t start, end;
    double cpu_time_used;
    double *A = (double *)malloc(n * n * sizeof(double));
    double *B = (double *)malloc(n * n * sizeof(double));
    double *C = (double *)malloc(n * n * sizeof(double));

    // fill A and B with random numbers
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            A[i + j * n] = randfrom(-1.0, 1.0);
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            B[i + j * n] = randfrom(-1.0, 1.0);

    // call DGEMM
    start = clock();
    square_dgemm(n, A, B, C);
    end = clock();
    cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("n = %d Time needed for matrix-vector product ij: %f seconds\n", n, cpu_time_used);
    
    return 0;
}