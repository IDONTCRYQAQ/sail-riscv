#include <stdio.h>

#define N 10

int board[N][N];
int solution_count = 0;

void generate_board(int board[N][N]) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            board[i][j] = 0;
        }
    }
}

int is_safe(int row, int col) {
    int i, j;

    for (i = 0; i < col; i++) {
        if (board[row][i]) {
            return 0;
        }
    }

    for (i = row, j = col; i >= 0 && j >= 0; i--, j--) {
        if (board[i][j]) {
            return 0;
        }
    }

    for (i = row, j = col; j >= 0 && i < N; i++, j--) {
        if (board[i][j]) {
            return 0;
        }
    }

    return 1;
}

void print_solution() {
    printf("Solution #%d:\n", solution_count);
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%d ", board[i][j]);
        }
        printf("\n");
    }
    printf("\n");
}

void solve_n_queens(int col) {
    if (col >= N) {
        solution_count++;
        //print_solution();
        return;
    }

    for (int i = 0; i < N; i++) {
        if (is_safe(i, col)) {
            board[i][col] = 1;
            solve_n_queens(col + 1);
            board[i][col] = 0;
        }
    }
}

int main() {
    generate_board(board);
    solve_n_queens(0);
    printf("Total number of solutions for %d-Queens problem: %d\n", N, solution_count);
    return 0;
}
