#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <selinux/selinux.h>
#include <arpa/inet.h>

int main(int argc, const char *argv[]) {
    char *context = NULL;

    // get selinux context
    getcon(&context);
    printf("getcon: %s\n", context);

    int fd = socket(AF_INET, SOCK_STREAM, 0);

    int tmp = errno;

    printf("socket(...) = %d\n", fd);

    if (fd < 0) {
        errno = tmp;
        perror("socket() failed");
        return 1;
    }

    struct sockaddr_in sa;
    memset(&sa, 0, sizeof(sa));
    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = htonl(INADDR_ANY);
    sa.sin_port = htons(12345);

    int res = bind(fd, (struct sockaddr *) &sa, sizeof(sa));

    tmp = errno;

    printf("bind(...) = %d\n", res);

    if (res < 0) {
        errno = tmp;
        perror("bind() failed");
        return 1;
    }

    res = close(fd);

    printf("close(...) = %d\n", res);

    return 0;
}
