#include <stdio.h>
#include <stdlib.h>

#define WIDTH 200
#define HEIGHT 200

unsigned int seed = 1;

void srand_simple(unsigned int new_seed) {
    seed = new_seed;
}

unsigned int rand_simple() {
    seed = (1103515245 * seed + 12345) % 0x80000000;
    return seed;
}

int to_fixed(int n, int frac_bits) {
    return n << frac_bits;
}

int to_int(int n, int frac_bits) {
    if (n < 0) {
        return (n + (1 << frac_bits) - 1) >> frac_bits;
    } else {
        return n >> frac_bits;
    }
}

int approx_sqrt(int num, int frac_bits) {
    int x = num;
    int y = to_fixed(1, frac_bits);
    int e = to_fixed(0.001f, frac_bits);

    while (x - y > e) {
        x = (x + y) / 2;
        y = to_fixed(num, frac_bits) / x;
    }
    return x;
}

void sobel(unsigned char *image, unsigned char *edge_image, int width, int height, int frac_bits) {
    int Gx[3][3] = {{-1, 0, 1},
                    {-2, 0, 2},
                    {-1, 0, 1}};

    int Gy[3][3] = {{-1, -2, -1},
                    {0,  0,  0},
                    {1,  2,  1}};

    for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
            int gx = 0;
            int gy = 0;

            for (int k = -1; k <= 1; k++) {
                for (int j = -1; j <= 1; j++) {
                    int pixel = image[(y + k) * width + (x + j)];
                    gx += Gx[k + 1][j + 1] * pixel;
                    gy += Gy[k + 1][j + 1] * pixel;
                }
            }

            int edge_value = approx_sqrt(to_fixed(gx * gx + gy * gy, frac_bits), frac_bits);
            edge_value = edge_value > to_fixed(255, frac_bits) ? to_fixed(255, frac_bits) : edge_value;
            edge_image[y * width + x] = (unsigned char)to_int(edge_value, frac_bits);
        }
    }
}

int main() {
    // 初始化測試影像
    unsigned char image[WIDTH * HEIGHT] = {0};

    // 隨機生成測試影像
    srand_simple(123);
    for (int i = 0; i < WIDTH * HEIGHT; i++) {
        image[i] = rand_simple() % 256;
    }

    // 分配邊緣影像的內存空間
    unsigned char edge_image[WIDTH * HEIGHT];

    // 執行 Sobel 邊緣檢測算法
    int frac_bits = 10;
    sobel(image, edge_image, WIDTH, HEIGHT, frac_bits);

    // 處理邊緣影像（例如：顯示、儲存等）
    return 0;
}