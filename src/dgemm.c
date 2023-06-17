// We start by rewriting the Python program from Section 1.10. Figure 2.43 shows a
// version of a matrix–matrix multiply written in C. This program is commonly called
// DGEMM, which stands for Double-precision General Matrix Multiply. Because
// we are passing the matrix dimension as the parameter , this version of DGEMM
// uses single-dimensional versions of matrices, and and address arithmetic to get
// better performance instead of using the more intuitive two-dimensional arrays that we saw in Python.

#include <x86intrin.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define UNROLL (4)
#define BLOCKSIZE 32

double randfrom(double min, double max)
{
    double range = (max - min);
    double div = RAND_MAX / range;
    return min + (rand() / div);
}

void do_block1(int n, int si, int sj, int sk, double *A, double *B, double *C)
{
    for (int i = si; i < si + BLOCKSIZE; ++i)
        for (int j = sj; j < sj + BLOCKSIZE; ++j)
        {
            double cij = C[i + j * n];
            for (int k = sk; k < sk + BLOCKSIZE; k++)
                cij += A[i + k * n] * B[k + j * n];
            C[i + j * n] = cij;
        }
}

void do_block2(int n, int si, int sj, int sk,
               double *A, double *B, double *C)
{
    for (int i = si; i < si + BLOCKSIZE; i += UNROLL * 8)
        for (int j = sj; j < sj + BLOCKSIZE; j++)
        {
            __m512d c[UNROLL];
            for (int r = 0; r < UNROLL; r++)
                c[r] = _mm512_load_pd(C + i + r * 8 + j * n);
            for (int k = sk; k < sk + BLOCKSIZE; k++)
            {
                __m512d bb = _mm512_broadcastsd_pd(_mm_load_sd(B + j * n + k));
                for (int r = 0; r < UNROLL; r++)
                    c[r] = _mm512_fmadd_pd(_mm512_load_pd(A + n * k + r * 8 + i), bb, c[r]);
            }

            for (int r = 0; r < UNROLL; r++)
                _mm512_store_pd(C + i + r * 8 + j * n, c[r]);
        }
}

void dgemm2(int n, double *A, double *B, double *C)
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

void dgemm3(size_t n, double *A, double *B, double *C)
{
    for (size_t i = 0; i < n; i += 4)
        for (size_t j = 0; j < n; j++)
        {
            __m256d c0 = _mm256_load_pd(C + i + j * n);
            for (size_t k = 0; k < n; k++)
                c0 = _mm256_add_pd(c0,
                                   _mm256_mul_pd(_mm256_load_pd(A + i + k * n),
                                                 _mm256_broadcast_sd(B + k + j * n)));
            _mm256_store_pd(C + i + j * n, c0);
        }
}

void dgemm4(int n, double *A, double *B, double *C)
{
    for (int i = 0; i < n; i += UNROLL * 8)
        for (int j = 0; j < n; ++j)
        {
            __m512d c[UNROLL];
            for (int r = 0; r < UNROLL; r++)
                c[r] = _mm512_load_pd(C + i + r * 8 + j * n);

            for (int k = 0; k < n; k++)
            {
                __m512d bb = _mm512_broadcastsd_pd(_mm_load_sd(B + j * n + k));
                for (int r = 0; r < UNROLL; r++)
                    c[r] = _mm512_fmadd_pd(_mm512_load_pd(A + n * k + r * 8 + i), bb, c[r]);
            }
            for (int r = 0; r < UNROLL; r++)
                _mm512_store_pd(C + i + r * 8 + j * n, c[r]);
        }
}

void dgemm5_1(int n, double *A, double *B, double *C)
{
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block1(n, si, sj, sk, A, B, C);
}

void dgemm5_2(int n, double *A, double *B, double *C)
{
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block2(n, si, sj, sk, A, B, C);
}

void dgemm6(int n, double *A, double *B, double *C)
{
#pragma omp parallel for
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block2(n, si, sj, sk, A, B, C);
}

void measureTime(void (*function)(int, double *, double *, double *), int n, double *A, double *B, double *C)
{
    clock_t start, end;
    double cpu_time_used;

    start = clock();
    function(n, A, B, C);
    end = clock();
    cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("n = %d Time needed: %f seconds\n", n, cpu_time_used);
}

// create larger random matrices, call DGEMM and time it
int main()
{
    int n = 1000;
    clock_t start, end;
    double cpu_time_used;
    double *A = (double *)malloc(n * n * sizeof(double));
    double *B = (double *)malloc(n * n * sizeof(double));
    double *C = (double *)malloc(n * n * sizeof(double));

    // fill A and B with random numbers
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
        {
            A[i + j * n] = randfrom(-1.0, 1.0);
            B[i + j * n] = randfrom(-1.0, 1.0);
        }

    // call DGEMMs
    measureTime(dgemm2, n, A, B, C);
    measureTime(dgemm3, n, A, B, C);
    measureTime(dgemm4, n, A, B, C);
    measureTime(dgemm5_1, n, A, B, C);
    measureTime(dgemm5_2, n, A, B, C);
    measureTime(dgemm6, n, A, B, C);

    return 0;
}