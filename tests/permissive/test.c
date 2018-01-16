#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <errno.h>

int main(int argc, const char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "File name required!\n");
        return 1;
    }

    printf("open(...) = ");

    int fd = open(argv[1], 0);

    printf("%d\n", fd);

    if (fd < 0) {
        perror("open() failed");
        return 1;
    }

    return 0;
}
