#include <stdio.h>

#define ITEMS 1000
#define CAPACITY 200

int weights[ITEMS];
int values[ITEMS];

int max(int a, int b) {
    return a > b ? a : b;
}

unsigned int seed = 1; // You can use any positive integer as the initial seed.

// A simple Linear Congruential Generator (LCG) for generating random numbers.
unsigned int lcg_rand() {
    seed = (1103515245 * seed + 12345) % 2147483648; // a = 1103515245, c = 12345, m = 2^31
    return seed;
}

// Generates random weights and values without using time.h and rand()
void generate_weights_and_values() {
    for (int i = 0; i < ITEMS; i++) {
        int weight = (lcg_rand() % (CAPACITY / 2)) + (lcg_rand() % (CAPACITY / 2));
        int value = weight / 2 + (lcg_rand() % (CAPACITY / 2));

        weights[i] = weight;
        values[i] = value;
    }
}


int knapsack(int capacity, int weights[], int values[], int items) {
    int dp[items + 1][capacity + 1];

    for (int i = 0; i <= items; i++) {
        for (int w = 0; w <= capacity; w++) {
            if (i == 0 || w == 0) {
                dp[i][w] = 0;
            } else if (weights[i - 1] <= w) {
                dp[i][w] = max(values[i - 1] + dp[i - 1][w - weights[i - 1]], dp[i - 1][w]);
            } else {
                dp[i][w] = dp[i - 1][w];
            }
        }
    }

    return dp[items][capacity];
}

int main() {
    generate_weights_and_values();

    // printf("Generated weights: ");
    // for (int i = 0; i < ITEMS; i++) {
    //     printf("%d ", weights[i]);
    // }
    // printf("\n");

    // printf("Generated values: ");
    // for (int i = 0; i < ITEMS; i++) {
    //     printf("%d ", values[i]);
    // }
    // printf("\n");

    int max_value = knapsack(CAPACITY, weights, values, ITEMS);
    printf("Maximum value for capacity %d: %d\n", CAPACITY, max_value);
    return 0;
}