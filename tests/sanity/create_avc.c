#include <stdio.h>

int main(int argc, const char *argv[]) {
    FILE *f;
    
    f = fopen("/etc/passwd", "w");

    return 0;
}
