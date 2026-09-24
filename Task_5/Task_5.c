#include <stdio.h>

int main() {
    long long num = 5277616985LL;
    long long sum = 0;
    while (num > 0) {
        sum += num % 10;
        num /= 10;
    }
    printf("%lld\n", sum);
    return 0;
}
