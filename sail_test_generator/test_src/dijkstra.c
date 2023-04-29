#include <stdio.h>
#include <limits.h>

#define VERTICES 500
#define MAX_EDGES 10000
#define MAX_WEIGHT 100
#define INF INT_MAX

unsigned int lcg_seed = 0;

unsigned int xorshift32(unsigned int *state) {
    /* Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs" */
    unsigned int x = *state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    *state = x;
    return x;
}

unsigned int custom_rand() {
    static unsigned int state = 123456789;
    return xorshift32(&state);
}

unsigned int custom_rand_range(unsigned int n) {
    return custom_rand() % n;
}

void generate_adjacency_matrix(int graph[VERTICES][VERTICES]) {
    // 初始化所有節點之間的邊為0
    for (int i = 0; i < VERTICES; i++) {
        for (int j = 0; j < VERTICES; j++) {
            graph[i][j] = 0;
        }
    }

    // 生成隨機的邊並賦予隨機權重
    int e = 0;
    while (e < MAX_EDGES) {
        int src = custom_rand_range(VERTICES);
        int dest = custom_rand_range(VERTICES);
        int weight = 1 + custom_rand_range(MAX_WEIGHT);

        // 避免自循環
        if (src == dest) {
            continue;
        }

        // 無向圖，保持對稱性
        graph[src][dest] = weight;
        graph[dest][src] = weight;
        e++;
    }
}



int min_distance(int dist[], int spt_set[]) {
    int min = INF, min_index;
    
    for (int v = 0; v < VERTICES; v++) {
        if (spt_set[v] == 0 && dist[v] <= min) {
            min = dist[v];
            min_index = v;
        }
    }

    return min_index;
}

void dijkstra(int graph[VERTICES][VERTICES], int src) {
    int dist[VERTICES];
    int spt_set[VERTICES];

    for (int i = 0; i < VERTICES; i++) {
        dist[i] = INF;
        spt_set[i] = 0;
    }

    dist[src] = 0;

    for (int count = 0; count < VERTICES - 1; count++) {
        int u = min_distance(dist, spt_set);
        spt_set[u] = 1;

        for (int v = 0; v < VERTICES; v++) {
            if (!spt_set[v] && graph[u][v] && dist[u] != INF &&
                dist[u] + graph[u][v] < dist[v]) {
                dist[v] = dist[u] + graph[u][v];
            }
        }
    }

    // printf("Vertex\t Distance from Source\n");
    // for (int i = 0; i < VERTICES; i++) {
    //     printf("%d\t %d\n", i, dist[i]);
    // }
}

int main() {
    int graph[VERTICES][VERTICES];
    generate_adjacency_matrix(graph);
    dijkstra(graph, 0);

    return 0;
}
