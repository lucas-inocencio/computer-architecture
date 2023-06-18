# To demonstrate the impact of the ideas in this book, every chapter has a “Going
# Faster” section that improves the performance of a program that multiplies a
# matrix times a vector. We start with this Python program:

import random
import time

n_values = [pow(2, i) for i in range(11)]

for n in n_values:
    # Create random matrices A and B of shape (n, n) without using numpy
    A = [[random.random() for i in range(n)] for j in range(n)]
    B = [[random.random() for i in range(n)] for j in range(n)]

    # Create a matrix C of shape (n, n) to hold the result
    C = [[0 for i in range(n)] for j in range(n)]

    # Compute time for matrix multiplication
    start = time.time()
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] += A[i][k] * B[k][j]
    end = time.time()

    print("Time for matrix multiplication with n =", n, ":", end - start)