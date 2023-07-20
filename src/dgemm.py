import random
import time


def create_matrix(n: int) -> list[list[float]]:
    """
    Creates a random matrix of size n x n.

    Args:
        n (int): The size of the matrix.

    Returns:
        list[list[float]]: The matrix."
    """
    return [[random.uniform(-1, 1) for _ in range(n)] for _ in range(n)]


def dgemm(A: list[list[float]], B: list[list[float]], C: list[list[float]]) -> None:
    """
    Multiplies two matrices A and B and stores the result in C.

    Args:
        A (list[list[float]]): The first matrix.
        B (list[list[float]]): The second matrix.
        C (list[list[float]]): The matrix where the result will be stored.

    Returns:
        None: The result is stored in C.

    """


    n = len(A)

    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] += A[i][k] * B[k][j]


if __name__ == "__main__":

    max_power = int(input("Enter the max power of 2: "))
    num_runs = int(input("Enter the number of runs: "))

    # create list of sizes
    sizes = [2 ** i for i in range(5,  max_power + 1)]

    with open("./docs/csv/results.csv", "a") as f:
        for _ in range(num_runs):
            for n in sizes:
                A = create_matrix(n)
                B = create_matrix(n)
                C = create_matrix(n)

                start = time.time()
                dgemm(A, B, C)
                end = time.time()

                # write in the end of the file
                f.write(f"Python,{n},{end - start}\n")

    print("Done!")