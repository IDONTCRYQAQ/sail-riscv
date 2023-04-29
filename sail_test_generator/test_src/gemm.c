#include <stdio.h>
#include <stdlib.h>

#define N 100
#define M 100
#define K 100

unsigned long lcg_seed = 12345;

unsigned long lcg_rand() {
    lcg_seed = (lcg_seed * 1103515245 + 12345) % 2147483648;
    return lcg_seed;
}

void gemm(int n, int m, int k, int a[n][k], int b[k][m], int c[n][m]) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            c[i][j] = 0;
            for (int p = 0; p < k; p++) {
                c[i][j] += a[i][p] * b[p][j];
            }
        }
    }
}

void generateRandomMatrix(int rows, int cols, int matrix[rows][cols]) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            matrix[i][j] = lcg_rand() % 10;
        }
    }
}

int main() {
    int a[N][K], b[K][M], c[N][M];
    generateRandomMatrix(N, K, a);
    generateRandomMatrix(K, M, b);
    gemm(N, M, K, a, b, c);

    // printf("Matrix C:\n");
    // for (int i = 0; i < N; i++) {
    //     for (int j = 0; j < M; j++) {
    //         printf("%d ", c[i][j]);
    //     }
    //     printf("\n");
    // }

    return 0;
}