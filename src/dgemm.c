#include <x86intrin.h>
#include <math.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define BLOCKSIZE 32
#define P 8
#define UNROLL (8)

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
        for (int j = 0; j < n; ++j)
        {
            double cij = C[i + j * n];
            for (int k = 0; k < n; k++)
                cij += A[i + k * n] * B[k + j * n];
            C[i + j * n] = cij;
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
    for (int i = 0; i < n; i += UNROLL * 8)
        for (int j = 0; j < n; ++j)
        {
            __m256d c[UNROLL];
            for (int r = 0; r < UNROLL; r++)
                c[r] = _mm256_load_pd(C + i + r * 8 + j * n);

            for (int k = 0; k < n; k++)
            {
                __m256d bb = _mm256_broadcast_sd(B + j * n + k);
                for (int r = 0; r < UNROLL; r++)
                    c[r] = _mm256_fmadd_pd(_mm256_load_pd(A + n * k + r * 8 + i), bb, c[r]);
            }
            for (int r = 0; r < UNROLL; r++)
                _mm256_store_pd(C + i + r * 8 + j * n, c[r]);
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
    omp_set_num_threads(P);
#pragma omp parallel for
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
    double *matrix = (double *)_mm_malloc(n * n * sizeof(double), 64);
    for (int i = 0; i < n * n; i++)
        matrix[i] = (double)rand() / (double)RAND_MAX;
    return matrix;
}

int main()
{
    int min_power, max_power, num_runs, label;

    printf("Enter min power of 2:\n");
    if (scanf("%d", &min_power))
        ;
    printf("Enter max power of 2:\n");
    if (scanf("%d", &max_power))
        ;
    printf("Enter number of runs:\n");
    if (scanf("%d", &num_runs))
        ;
    printf("Enter label DGEMM function:\n"
           "1: Basic Implementation\n"
           "2: AVX Instructions\n"
           "3: AVX2 Instructions\n"
           "4: AVX2 Instructions with Loop Unrolling\n"
           "5: Basic Implementation with cache blocking\n"
           "6: AVX2 Instructions with Loop Unrolling and cache blocking\n"
           "7: AVX2 Instructions with Loop Unrolling, cache blocking and parallelization\n");
    if (scanf("%d", &label))
        ;

    int sizes[max_power - min_power + 1];
    for (int i = 0; i < max_power - min_power + 1; i++)
        sizes[i] = (int)pow(2, min_power + i);

    FILE *fp;
    fp = fopen("./docs/csv/results.csv", "a");

    for (int i = 0; i < num_runs; i++)
        for (int j = 0; j < max_power - min_power + 1; j++)
        {
            int n = sizes[j];
            double *A = createSquareMatrix(n);
            double *B = createSquareMatrix(n);
            double *C = createSquareMatrix(n);

            clock_t start = clock();

            switch (label)
            {
            case 1:
                dgemm2(n, A, B, C);
                break;
            case 2:
                dgemm3_avx(n, A, B, C);
                break;
            case 3:
                dgemm3_avx2(n, A, B, C);
                break;
            case 4:
                dgemm4(n, A, B, C);
                break;
            case 5:
                dgemm5_1(n, A, B, C);
                break;
            case 6:
                dgemm5_2(n, A, B, C);
                break;
            case 7:
                dgemm6(n, A, B, C);
                break;
            }

            clock_t end = clock();

            double time_taken = (double)(end - start) / CLOCKS_PER_SEC;

            printf("Run %d: %d, %d, %f\n", i, label, n, time_taken);
            fprintf(fp, "%d,%d,%f\n", label, n, time_taken);

            _mm_free(A);
            _mm_free(B);
            _mm_free(C);
        }

    fclose(fp);
    return 0;
}