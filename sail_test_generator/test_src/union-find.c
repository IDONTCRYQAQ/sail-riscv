#include <stdio.h>

#define ELEMENTS 100000
#define UNION_OPERATIONS 10000
#define MODULUS 2147483648
#define MULTIPLIER 1103515245
#define INCREMENT 12345

unsigned int lcg_seed = 1;

unsigned int lcg_rand() {
    lcg_seed = (lcg_seed * MULTIPLIER + INCREMENT) % MODULUS;
    return lcg_seed;
}

void generate_set(int parent[], int rank[]) {
    for (int i = 0; i < ELEMENTS; i++) {
        parent[i] = i;
        rank[i] = 0;
    }
}

int find(int parent[], int x) {
    if (parent[x] != x) {
        parent[x] = find(parent, parent[x]);
    }
    return parent[x];
}

void union_set(int parent[], int rank[], int x, int y) {
    int root_x = find(parent, x);
    int root_y = find(parent, y);

    if (root_x == root_y) {
        return;
    }

    if (rank[root_x] > rank[root_y]) {
        parent[root_y] = root_x;
    } else {
        parent[root_x] = root_y;
        if (rank[root_x] == rank[root_y]) {
            rank[root_y]++;
        }
    }
}

void print_sets(int parent[]) {
    printf("Element\t Parent\n");
    for (int i = 0; i < ELEMENTS; i++) {
        printf("%d\t %d\n", i, parent[i]);
    }
}

int main() {
    int parent[ELEMENTS];
    int rank[ELEMENTS];

    generate_set(parent, rank);

    for (int i = 0; i < UNION_OPERATIONS; i++) {
        int x = lcg_rand() % ELEMENTS;
        int y = lcg_rand() % ELEMENTS;
        //printf("Union: %d, %d\n", x, y);
        union_set(parent, rank, x, y);
    }

    //print_sets(parent);

    return 0;
}
