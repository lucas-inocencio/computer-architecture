import random
import time

MAX_POWER = 11

def create_matrix(n):
    return [[random.random() for _ in range(n)] for _ in range(n)]

def multiply_matrices(matrixA, matrixB, matrixC):
    n = len(matrixA)

    for i in range(n):
        for j in range(n):
            for k in range(n):
                matrixC[i][j] += matrixA[i][k] * matrixB[k][j]

def measure_execution_time(n):
    matrixA = create_matrix(n)
    matrixB = create_matrix(n)
    matrixC = create_matrix(n)

    start_time = time.perf_counter()
    multiply_matrices(matrixA, matrixB, matrixC)
    end_time = time.perf_counter()

    execution_time = end_time - start_time
    print(f"{n},{execution_time}")

n_values = [pow(2, i) for i in range(MAX_POWER)]

for n in n_values:
    measure_execution_time(n)