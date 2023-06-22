#include <immintrin.h>
#include <omp.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define UNROLL (4)
#define BLOCKSIZE 32
#define P 4

#define min(a, b)               \
    ({                          \
        __typeof__(a) _a = (a); \
        __typeof__(b) _b = (b); \
        _a < _b ? _a : _b;      \
    })

// Basic Implementation with cache blocking
void do_block1(int n, int si, int sj, int sk, double *A, double *B, double *C)
{
    int blocksize = min(n, BLOCKSIZE);
    for (int i = si; i < si + blocksize; ++i)
        for (int j = sj; j < sj + blocksize; ++j)
        {
            double cij = C[i + j * n];
            for (int k = sk; k < sk + blocksize; k++)
                cij += A[i + k * n] * B[k + j * n];
            C[i + j * n] = cij;
        }
}

// AVX2 Instructions with Loop Unrolling and cache blocking
void do_block2(int n, int si, int sj, int sk,
               double *A, double *B, double *C)
{
    int blocksize = min(n, BLOCKSIZE);
    for (int i = si; i < si + blocksize; i += UNROLL * 4)
        for (int j = sj; j < sj + blocksize; j++)
        {
            __m256d c[UNROLL];
            for (int r = 0; r < UNROLL; r++)
                c[r] = _mm256_load_pd(C + i + r * 4 + j * n);
            for (int k = sk; k < sk + blocksize; k++)
            {
                __m256d bb = _mm256_broadcast_sd(B + j * n + k);
                for (int r = 0; r < UNROLL; r++)
                    c[r] = _mm256_fmadd_pd(_mm256_load_pd(A + n * k + r * 4 + i), bb, c[r]);
            }

            for (int r = 0; r < UNROLL; r++)
                _mm256_store_pd(C + i + r * 4 + j * n, c[r]);
        }
}

// Basic Implementation
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

// AVX Instructions
void dgemm3_avx(int n, double *A, double *B, double *C)
{
    for (int i = 0; i < n; i += 4)
        for (int j = 0; j < n; j++)
        {
            __m256d c0 = _mm256_load_pd(C + i + j * n);
            for (int k = 0; k < n; k++)
                c0 = _mm256_add_pd(c0,
                                   _mm256_mul_pd(_mm256_load_pd(A + i + k * n),
                                                 _mm256_broadcast_sd(B + k + j * n)));
            _mm256_store_pd(C + i + j * n, c0);
        }
}

// AVX2 Instructions
void dgemm3_avx2(int n, double *A, double *B, double *C)
{
    for (int i = 0; i < n; i += 4)
        for (int j = 0; j < n; j++)
        {
            __m256d c0 = _mm256_load_pd(C + i + j * n);
            for (int k = 0; k < n; k++)
                c0 = _mm256_add_pd(c0,
                                   _mm256_mul_pd(_mm256_load_pd(A + i + k * n),
                                                 _mm256_broadcast_sd(B + k + j * n)));
            _mm256_store_pd(C + i + j * n, c0);
        }
}

// AVX2 Instructions with Loop Unrolling
void dgemm4(int n, double *A, double *B, double *C)
{
    for (int i = 0; i < n; i += UNROLL * 4)
        for (int j = 0; j < n; ++j)
        {
            __m256d c[UNROLL];
            for (int r = 0; r < UNROLL; r++)
                c[r] = _mm256_load_pd(C + i + r * 4 + j * n);

            for (int k = 0; k < n; k++)
            {
                __m256d bb = _mm256_broadcast_sd(B + j * n + k);
                for (int r = 0; r < UNROLL; r++)
                    c[r] = _mm256_fmadd_pd(_mm256_load_pd(A + n * k + r * 4 + i), bb, c[r]);
            }
            for (int r = 0; r < UNROLL; r++)
                _mm256_store_pd(C + i + r * 4 + j * n, c[r]);
        }
}

// Basic Implementation with cache blocking
void dgemm5_1(int n, double *A, double *B, double *C)
{
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block1(n, si, sj, sk, A, B, C);
}

// AVX2 Instructions with Loop Unrolling and cache blocking
void dgemm5_2(int n, double *A, double *B, double *C)
{
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block2(n, si, sj, sk, A, B, C);
}

// AVX2 Instructions with Loop Unrolling, cache blocking and parallelization
void dgemm6(int n, double *A, double *B, double *C)
{
#pragma omp parallel num_threads(P)
#pragma omp parallel for
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block2(n, si, sj, sk, A, B, C);
}

// Measure the time it takes to run a function
void measureTime(void (*function)(int, double *, double *, double *), int n, double *A,
                 double *B, double *C)
{
    clock_t start, end;
    double cpu_time_used;

    start = clock();
    function(n, A, B, C);
    end = clock();
    cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("%d,%f\n", n, cpu_time_used);
}

// Create a random matrix of size n x n
double *createMatrix(int n)
{
    double *matrix = (double *)malloc(n * n * sizeof(double));
    for (int i = 0; i < n * n; i++)
        matrix[i] = (double)rand() / (double)RAND_MAX;
    return matrix;
}

int main()
{
    int n_values[] = {32, 64, 128, 256, 512, 1024, 2048, 4096, 8192};
    int num_values = sizeof(n_values) / sizeof(n_values[0]);

    for (int index = 0; index < num_values; index++)
    {
        int n = n_values[index];
        double *A = createMatrix(n);
        double *B = createMatrix(n);
        double *C = createMatrix(n);

        // measureTime(dgemm2, n, A, B, C);
        // measureTime(dgemm3, n, A, B, C);
        // measureTime(dgemm4, n, A, B, C);
        // measureTime(dgemm5_1, n, A, B, C);
        measureTime(dgemm5_2, n, A, B, C);
        measureTime(dgemm6, n, A, B, C);

        free(A);
        free(B);
        free(C);
    }

    return 0;
}