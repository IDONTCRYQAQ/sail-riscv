#include <stdio.h>
#include <string.h>

#define TXT_LEN 200000
#define PAT_LEN 2000

unsigned long lcg_seed = 12345;

unsigned long lcg_rand() {
    lcg_seed = (lcg_seed * 1103515245 + 12345) % 2147483648;
    return lcg_seed;
}

void computeLPSArray(char *pat, int M, int *lps) {
    int len = 0;
    lps[0] = 0;
    int i = 1;
    while (i < M) {
        if (pat[i] == pat[len]) {
            len++;
            lps[i] = len;
            i++;
        } else {
            if (len != 0) {
                len = lps[len - 1];
            } else {
                lps[i] = 0;
                i++;
            }
        }
    }
}

void KMPSearch(char *pat, char *txt) {
    int M = strlen(pat);
    int N = strlen(txt);

    int lps[M];
    computeLPSArray(pat, M, lps);

    int i = 0;
    int j = 0;
    while (i < N) {
        if (pat[j] == txt[i]) {
            j++;
            i++;
        }

        if (j == M) {
            printf("Pattern found at index %d\n", i - j);
            j = lps[j - 1];
        } else if (i < N && pat[j] != txt[i]) {
            if (j != 0) {
                j = lps[j - 1];
            } else {
                i = i + 1;
            }
        }
    }
}

void insertPatternWithCustomMemmove(char *str, const char *pat, int occurrences) {
    int pat_len = strlen(pat);
    int txt_len = strlen(str);

    for (int i = 0; i < occurrences; i++) {
        int insert_pos = lcg_rand() % (txt_len - pat_len + 1);

        if (str + insert_pos + pat_len < str + insert_pos) {
            for (int j = 0; j < txt_len - insert_pos; j++) {
                str[insert_pos + pat_len + j] = str[insert_pos + j];
            }
        } else {
            for (int j = txt_len - insert_pos - 1; j >= 0; j--) {
                str[insert_pos + pat_len + j] = str[insert_pos + j];
            }
        }

        for (int j = 0; j < pat_len; j++) {
            str[insert_pos + j] = pat[j];
        }
        txt_len += pat_len;
    }
    str[txt_len] = '\0';
}

void generateRandomString(char *str, int len, const char *pat, int occurrences) {
    static const char alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    for (int i = 0; i < len - 1; i++) {
        str[i] = alphabet[lcg_rand() % (sizeof(alphabet) - 1)];
    }
    str[len - 1] = '\0';

    if (occurrences > 0) {
        insertPatternWithCustomMemmove(str, pat, occurrences);
    }
}


int main() {
    char txt[TXT_LEN];
    char pat[PAT_LEN];
    int occurrences = 3;

    generateRandomString(pat, PAT_LEN, NULL, 0);
    generateRandomString(txt, TXT_LEN, pat, occurrences);

    // printf("Text: %s\n", txt);
    // printf("Pattern: %s\n", pat);

    KMPSearch(pat, txt);
    return 0;
}
