
#include <unistd.h>
#include <string.h>

int main() {
    const char password[] = "1234";
    char input[64];

    for (int attempt = 0; attempt < 5; attempt++) {

        write(1, "Enter password: ", 16);

        int len = read(0, input, sizeof(input) - 1);

        if (len <= 0)
            return 1;

        input[len] = '\0';

        if (input[len - 1] == '\n')
            input[len - 1] = '\0';

        if (strcmp(input, password) == 0) {
            write(1, "Successful\n", 11);
            return 0;
        }

        write(1, "Incorrect password\n", 19);
    }

    write(1, "Failed\n", 7);

    return 0;
}
