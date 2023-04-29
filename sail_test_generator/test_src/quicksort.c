#include <stdio.h>
#include <stdlib.h>

#define ARRAY_SIZE 20000

unsigned long lcg_seed = 12345;

unsigned long lcg_rand() {
    lcg_seed = (lcg_seed * 1103515245 + 12345) % 2147483648;
    return lcg_seed;
}

void swap(int* a, int* b) {
    int t = *a;
    *a = *b;
    *b = t;
}

int partition(int arr[], int low, int high) {
    int pivot = arr[high];
    int i = (low - 1);

    for (int j = low; j <= high - 1; j++) {
        if (arr[j] < pivot) {
            i++;
            swap(&arr[i], &arr[j]);
        }
    }
    swap(&arr[i + 1], &arr[high]);
    return (i + 1);
}

void quickSort(int arr[], int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);
        quickSort(arr, low, pi - 1);
        quickSort(arr, pi + 1, high);
    }
}

void generateRandomArray(int size, int array[size]) {
    for (int i = 0; i < size; i++) {
        array[i] = lcg_rand() % 100;
    }
}

int main() {
    int arr[ARRAY_SIZE];
    generateRandomArray(ARRAY_SIZE, arr);

    // printf("Unsorted array:\n");
    // for (int i = 0; i < ARRAY_SIZE; i++) {
    //     printf("%d ", arr[i]);
    // }
    // printf("\n");

    quickSort(arr, 0, ARRAY_SIZE - 1);

    // printf("Sorted array:\n");
    // for (int i = 0; i < ARRAY_SIZE; i++) {
    //     printf("%d ", arr[i]);
    // }
    // printf("\n");

    return 0;
}