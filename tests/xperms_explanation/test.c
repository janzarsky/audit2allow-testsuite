#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <errno.h>

int main(int argc, const char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "File name and ioctl number required!\n");
        return 1;
    }

    printf("open('%s') == ", argv[1]);

    int fd = open(argv[1], 0);

    printf("%d\n", fd);

    if (fd < 0) {
        perror("open() failed");
        return 1;
    }

    int ioctl_num = strtoul(argv[2], NULL, 0);

    printf("ioctl('%s') == ", argv[1]);

    int res = ioctl(fd, ioctl_num);

    int tmp = errno;

    printf("%d\n", res);

    errno = tmp;

    if (res < 0) {
        perror("ioctl() failed");
        fprintf(stderr, "errno = %d\n", errno);

        if (errno == EACCES)
            return 1;
    }

    return 0;
}
