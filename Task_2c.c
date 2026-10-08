#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main() {
    char buf[64];
    long n, sum = 0;

    write(1, "Enter n: ", 9);

    int len = read(0, buf, sizeof(buf)-1);
    buf[len] = '\0';

    n = atol(buf);

    for (long k = 1; k <= n; k++) {
        long term = k * k;

        if (k % 2 == 0)
            sum -= term;
        else
            sum += term;
    }

    printf("Result = %ld\n", sum);

    return 0;
}
