#include <stdio.h>

#define MAX_SIZE 200000

void generate_numbers(int numbers[], int size) {
    for (int i = 0; i < size; i++) {
        numbers[i] = i;
    }
}

void sieve_of_eratosthenes(int numbers[], int size) {
    numbers[0] = 0;
    numbers[1] = 0;

    for (int i = 2; i * i < size; i++) {
        if (numbers[i] != 0) {
            for (int j = i * i; j < size; j += i) {
                numbers[j] = 0;
            }
        }
    }
}

int main() {
    int numbers[MAX_SIZE];
    generate_numbers(numbers, MAX_SIZE);
    sieve_of_eratosthenes(numbers, MAX_SIZE);

    // printf("Prime numbers up to %d:\n", MAX_SIZE);
    // for (int i = 0; i < MAX_SIZE; i++) {
    //     if (numbers[i] != 0) {
    //         printf("%d ", numbers[i]);
    //     }
    // }
    // printf("\n");

    return 0;
}
