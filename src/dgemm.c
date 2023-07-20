#include <immintrin.h>
#include <omp.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define UNROLL (4)
#define BLOCKSIZE 32
#define P 4

/**
 * Basic Implementation with cache blocking
 *
 * @param n size of the matrix
 * @param si starting index of i
 * @param sj starting index of j
 * @param sk starting index of k
 * @param A matrix A
 * @param B matrix B
 * @param C matrix C
 *
 * @return void
 */
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

/**
 * AVX2 Instructions with Loop Unrolling and cache blocking
 *
 * @param n size of the matrix
 * @param si starting index of i
 * @param sj starting index of j
 * @param sk starting index of k
 * @param A matrix A
 * @param B matrix B
 * @param C matrix C
 *
 * @return void
 */
void do_block2(int n, int si, int sj, int sk,
               double *A, double *B, double *C)
{
    for (int i = si; i < si + BLOCKSIZE; i += UNROLL * 4)
        for (int j = sj; j < sj + BLOCKSIZE; j++)
        {
            __m256d c[UNROLL];
            for (int r = 0; r < UNROLL; r++)
                c[r] = _mm256_load_pd(C + i + r * 4 + j * n);
            for (int k = sk; k < sk + BLOCKSIZE; k++)
            {
                __m256d bb = _mm256_broadcast_sd(B + j * n + k);
                for (int r = 0; r < UNROLL; r++)
                    c[r] = _mm256_fmadd_pd(_mm256_load_pd(A + n * k + r * 4 + i), bb, c[r]);
            }

            for (int r = 0; r < UNROLL; r++)
                _mm256_store_pd(C + i + r * 4 + j * n, c[r]);
        }
}

/**
 * Basic Implementation
 *
 * @param n size of the matrix
 * @param A matrix A
 * @param B matrix B
 * @param C matrix C
 *
 * @return void
 *
 * @note This function is not optimized
 *
 */
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

/**
 * AVX Instructions
 *
 * @param n size of the matrix
 * @param A matrix A
 * @param B matrix B
 * @param C matrix C
 *
 * @return void
 */
void dgemm3_avx(int n, double *A, double *B, double *C)
{
    for (int i = 0; i < n; i += 4)
        for (int j = 0; j < n; j++)
        {
            __m256d c0 = _mm256_load_pd(C + i + j * n);
            for (int k = 0; k < n; k++)
                c0 = _mm256_add_pd(c0,
                                   _mm256_mul_pd(_mm256_load_pd(A + i + k * n),
                                                 _mm256_set1_pd(B[k + j * n])));
            _mm256_store_pd(C + i + j * n, c0);
        }
}

/**
 * AVX2 Instructions
 *
 * @param n size of the matrix
 * @param A matrix A
 * @param B matrix B
 * @param C matrix C
 *
 * @return void
 */
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

/**
 * AVX2 Instructions with Loop Unrolling
 *
 * @param n size of the matrix
 * @param A matrix A
 * @param B matrix B
 * @param C matrix C
 *
 * @return void
 */
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

/**
 * Basic Implementation with cache blocking
 *
 * @param n size of the matrix
 * @param A matrix A
 * @param B matrix B
 * @param C matrix C
 *
 * @return void
 */
void dgemm5_1(int n, double *A, double *B, double *C)
{
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block1(n, si, sj, sk, A, B, C);
}

/**
 * AVX2 Instructions with Loop Unrolling and cache blocking
 *
 * @param n size of the matrix
 * @param A matrix A
 * @param B matrix B
 * @param C matrix C
 *
 * @return void
 *
 */
void dgemm5_2(int n, double *A, double *B, double *C)
{
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block2(n, si, sj, sk, A, B, C);
}

/**
 * AVX2 Instructions with Loop Unrolling, cache blocking and parallelization
 *
 * @param n size of the matrix
 * @param A matrix A
 * @param B matrix B
 * @param C matrix C
 *
 * @return void
 */
void dgemm6(int n, double *A, double *B, double *C)
{
#pragma omp parallel for num_threads(P)
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block2(n, si, sj, sk, A, B, C);
}

/**
 * Create a square matrix of size n
 * 
 * @param n size of the matrix
 * 
 * @return double* pointer to the matrix
 */
double *createSquareMatrix(int n)
{
    double *matrix = (double *)malloc(n * n * sizeof(double));
    for (int i = 0; i < n * n; i++)
        matrix[i] = (double)rand() / (double)RAND_MAX;
    return matrix;
}

int main()
{
    int max_power, num_runs, target;

    printf("Enter max power of 2:\n");
    scanf("%d", &max_power);
    printf("Enter number of runs:\n");
    scanf("%d", &num_runs);
    printf("Enter target DGEMM function:\n"
           "1: Basic Implementation\n"
           "2: AVX Instructions\n"
           "3: AVX2 Instructions\n"
           "4: AVX2 Instructions with Loop Unrolling\n"
           "5: Basic Implementation with cache blocking\n"
           "6: AVX2 Instructions with Loop Unrolling and cache blocking\n"
           "7: AVX2 Instructions with Loop Unrolling, cache blocking and parallelization\n");
    scanf("%s", &target);

    int sizes[max_power];
    for (int i = 5; i < max_power; i++)
        sizes[i] = 1 << i;

    FILE *fp;
    fp = fopen("./docs/csv/results.csv", "a");

    for (int i = 0; i < num_runs; i++)
    {
        for (int j = 0; j < max_power; j++)
        {
            int n = sizes[j];
            double *A = createSquareMatrix(n);
            double *B = createSquareMatrix(n);
            double *C = createSquareMatrix(n);

            clock_t start = clock();

            switch (target)
            {
            case 1:
                dgemm2(n, A, B, C);
            case 2:
                dgemm3_avx(n, A, B, C);
            case 3:
                dgemm3_avx2(n, A, B, C);
            case 4:
                dgemm4(n, A, B, C);
            case 5:
                dgemm5_1(n, A, B, C);
            case 6:
                dgemm5_2(n, A, B, C);
            case 7:
                dgemm6(n, A, B, C);
            }

            clock_t end = clock();

            double time_taken = (double)(end - start) / CLOCKS_PER_SEC;

            fprintf(fp, "%d,%d,%f\n", target, n, time_taken);

            free(A);
            free(B);
            free(C);
        }
    }

    return 0;
}