
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    long a, b, c;
    long result;

    // Проверяем количество аргументов
    if (argc != 4) {
        printf("Usage: ./program a b c\n");
        return 1;
    }

    // Получаем значения
    a = atol(argv[1]);
    b = atol(argv[2]);
    c = atol(argv[3]);

    // Проверяем деление на ноль
    if (b == 0) {
        printf("Error: division by zero\n");
        return 1;
    }

    // Вычисляем выражение
    result = ((c - b) - b) / b;

    // Выводим результат
    printf("Result = %ld\n", result);

    return 0;
}
