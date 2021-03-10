// *************************************************************************
//
// Copyright 2020 Xilinx, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// *************************************************************************
// Compile with `gcc -shared -fPIC -I${SVDPI_PATH} -o tap.so tap.c`, where
// ${SVDPI_PATH} is the directory of `svdpi.h`
#include <svdpi.h>

#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/epoll.h>

#include <netinet/in.h>
#include <linux/if.h>
#include <linux/if_tun.h>

#define MAX_FUNC 4
#define MAX_CMAC 2

#define MAX_QUEUE 16
#define MAX_PKT_LEN 1514

#define QDMA_HDR_SIZE 8

struct qdma_queue_t {
    struct qdma_function_t *func;
    int virt_qid;
};

struct qdma_function_t {
    int func_id;
    int q_base;
    int num_q;
    struct qdma_queue_t queues[MAX_QUEUE];
    int fds[MAX_QUEUE];
};

struct qdma_struct_t {
    int num_func;
    struct qdma_function_t funcs[MAX_FUNC];
    int epfd;
};

struct cmac_struct_t {
    int num_cmac;
    int fds[MAX_CMAC];
};

static struct qdma_struct_t qdma_struct;
static struct cmac_struct_t cmac_struct;

static void dump_data(const char *data, int len)
{
    const unsigned int buf_len = 2048;
    char buf[buf_len];
    int i, offset;

    printf("data length = %d\n", len);
    offset = 0;
    for (i = 0; i < len; ++i) {
        offset += snprintf(buf+offset, buf_len-offset, " %02x", (unsigned char)(data[i]));
        if (i % 16 == 15) {
            printf("%s\n", buf);
            offset = 0;
        }
    }
    if (i % 16 != 0)
        printf("%s\n", buf);
}

/**
 * tap_alloc - Create a TAP device
 * @dev: device name
 * @fd: pointer to returned file descriptor
 *
 * Unless user is the owner of `/dev/net/tun`, which is not the usual case, it
 * is actually not allowed to create TUN/TAP devices.  However, with a read
 * permission to `/dev/net/tun`, user can grab the file descriptor for an
 * existing device by passing in the device name and correct flags.  This is
 * perhaps the most common usecase for this function.
 *
 * Return 0 on success, negative on failure
 **/
static int tap_alloc(char *dev, int *fd)
{
    struct ifreq ifr;
    int err;

    if (!dev || !fd)
        return -1;

    /**
     * Flags: IFF_TUN   - TUN device (no Ethernet headers)
     *        IFF_TAP   - TAP device
     *        IFF_NO_PI - Do not provide packet information
     **/
    memset(&ifr, 0, sizeof(ifr));
    ifr.ifr_flags = IFF_TAP | IFF_NO_PI;
    strncpy(ifr.ifr_name, dev, IFNAMSIZ);

    if ((*fd = open("/dev/net/tun", O_RDWR)) < 0) {
        printf("[DPI] alloc_tap: failed to open /dev/net/tun\n");
        return -1;
    }

    if ((err = ioctl(*fd, TUNSETIFF, (void *) &ifr)) < 0) {
        printf("[DPI] alloc_tap: failed to do ioctl, err = %d\n", err);
        close(*fd);
        return -1;
    }

    return 0;
}

/**
 * tap_alloc_mq - Create a multi-queue TAP device
 * @dev: device name
 * @num_q: number of queues
 * @fds: file descriptors for each queue
 *
 * Unless user is the owner of `/dev/net/tun`, which is not the usual case, it
 * is actually not allowed to create TUN/TAP devices.  However, with a read
 * permission to `/dev/net/tun`, user can grab the file descriptor for an
 * existing device by passing in the device name and correct flags.  This is
 * perhaps the most common usecase for this function.
 *
 * Return 0 on success, negative on failure
 **/
static int tap_alloc_mq(char *dev, int num_q, int *fds)
{
    struct ifreq ifr;
    int i;

    if (!dev)
        return -1;

    /**
     * Flags: IFF_TUN         - TUN device (no Ethernet headers)
     *        IFF_TAP         - TAP device
     *        IFF_NO_PI       - Do not provide packet information
     *        IFF_MULTI_QUEUE - Create a queue of multiqueue device
     **/
    memset(&ifr, 0, sizeof(ifr));
    ifr.ifr_flags = IFF_TAP | IFF_NO_PI | IFF_MULTI_QUEUE;
    strncpy(ifr.ifr_name, dev, IFNAMSIZ);

    for (i = 0; i < num_q; ++i) {
        int err;
        int fd = open("/dev/net/tun", O_RDWR);

        if (fd < 0) {
            printf("[DPI] alloc_tap_mq: failed to open /dev/net/tun\n");
            goto err;
        }

        if ((err = ioctl(fd, TUNSETIFF, (void *) &ifr)) < 0) {
            printf("[DPI] alloc_tap_mq: failed to do ioctl, err = %d\n", err);
            close(fd);
            goto err;
        }

        fds[i] = fd;
    }

    return 0;
err:
    for (--i; i >= 0; --i)
        close(fds[i]);
    return -1;
}

static int tap_read(int fd, const svOpenArrayHandle h, int hdr_size)
{
    char buf[MAX_PKT_LEN];
    int n;

    n = read(fd, buf, MAX_PKT_LEN);
    if (n < 0)
        return n;

    if (svSizeOfArray(h) < n + hdr_size) {
        printf("[DPI] read_tap: SV array not large enough\n");
        return -1;
    }

    for (int i = 0; i < n; ++i)
        svPutBitArrElem(h, buf[i], i + hdr_size);
    return n;
}

static int tap_write(int fd, const svOpenArrayHandle h, int hdr_size)
{
    char buf[MAX_PKT_LEN];
    int n, size;

    size = svSizeOfArray(h) - hdr_size;
    for (int i = 0; i < size; ++i)
        buf[i] = svGetBitArrElem(h, i + hdr_size);

    n = write(fd, buf, size);
    if (n < 0) {
        printf("[DPI] write_tap: failed to write\n");
        return n;
    }

    if (n < size) {
        printf("[DPI] write_tap: partial write\n");
        return -1;
    }

    return n;
}

void qdma_clear()
{
    for (int i = 0; i < qdma_struct.num_func; ++i) {
        struct qdma_function_t *func = &qdma_struct.funcs[i];

        for (int j = 0; j < func->num_q; ++j) {
            if (func->fds[j])
                close(func->fds[j]);
        }
    }

    close(qdma_struct.epfd);
}

int qdma_init(int num_func, int num_q)
{
    char dev[16];

    if (num_func > MAX_FUNC || num_q > MAX_QUEUE) {
        printf("[DPI] qdma_init: invalid inputs\n");
        return -1;
    }

    memset(&qdma_struct, 0, sizeof(qdma_struct));

    qdma_struct.num_func = num_func;
    qdma_struct.epfd = epoll_create1(0);
    if (qdma_struct.epfd == -1) {
        printf("[DPI] qdma_init: epoll_create1 failed\n");
        return -1;
    }

    for (int i = 0; i < num_func; ++i) {
        struct qdma_function_t *func = &qdma_struct.funcs[i];
        struct epoll_event ev;

        func->q_base = num_q * i;
        func->num_q = num_q;

        memset(dev, 0, 16);
        snprintf(dev, 16, "qdma-func-%d", i);
        if (tap_alloc_mq(dev, func->num_q, func->fds) < 0) {
            printf("[DPI] qdma_init: tap_alloc_mq failed\n");
            goto err;
        }

        for (int j = 0; j < func->num_q; ++j) {
            struct qdma_queue_t *q = &func->queues[j];

            q->func = func;
            q->virt_qid = j;

            ev.events = EPOLLIN;
            ev.data.ptr = (void *)q;

            if (epoll_ctl(qdma_struct.epfd, EPOLL_CTL_ADD,
                          func->fds[j], &ev) == -1) {
                perror("[DPI] qdma_init: epoll_ctl failed");
                /* printf("[DPI] qdma_init: epoll_ctl failed\n"); */
                goto err;
            }
        }
    }

    return 0;
err:
    qdma_clear();
    return -1;
}

int qdma_read(const svOpenArrayHandle h)
{
    struct epoll_event ev;
    struct qdma_queue_t *q;
    int nfds, qid, len, fd;

    nfds = epoll_wait(qdma_struct.epfd, &ev, 1, 0);
    if (nfds == -1) {
        printf("[DPI] qdma_read: epoll_wait failed\n");
        return -1;
    }

    if (nfds == 0)
        return 0;

    q = (struct qdma_queue_t *)ev.data.ptr;
    qid = q->func->q_base + q->virt_qid;

    fd = q->func->fds[q->virt_qid];
    len = tap_read(fd, h, QDMA_HDR_SIZE);

    svPutBitArrElemVecVal(h, &qid, 0);
    svPutBitArrElemVecVal(h, &len, 4);

    return len;
}

int qdma_write(const svOpenArrayHandle h)
{
    struct qdma_function_t *func = NULL;
    struct qdma_queue_t *q = NULL;
    int qid, len, fd;

    svGetBitArrElemVecVal(&qid, h, 0);
    svGetBitArrElemVecVal(&len, h, 4);

    for (int i = 0; i < qdma_struct.num_func; ++i) {
        struct qdma_function_t *tmp_func = &qdma_struct.funcs[i];

        if ((qid >= tmp_func->q_base) && (qid < tmp_func->q_base + tmp_func->num_q)) {
            func = tmp_func;
            q = &tmp_func->queues[qid - tmp_func->q_base];
            break;
        }
    }

    if (!func)
        return -1;

    fd = func->fds[q->virt_qid];
    return tap_write(fd, h, QDMA_HDR_SIZE);
}

void cmac_clear()
{
    for (int i = 0; i < cmac_struct.num_cmac; ++i) {
        if (cmac_struct.fds[i])
            close(cmac_struct.fds[i]);
    }
}

int cmac_init(int num_cmac)
{
    char dev[16];
    int flags;

    if (num_cmac > MAX_CMAC) {
        printf("[DPI] cmac_init: invalid inputs\n");
        return -1;
    }

    memset(&cmac_struct, 0, sizeof(cmac_struct));
    cmac_struct.num_cmac = num_cmac;

    for (int i = 0; i < num_cmac; ++i) {
        int fd;

        memset(dev, 0, 16);
        snprintf(dev, 16, "cmac-%d", i);
        if (tap_alloc(dev, &fd) < 0) {
            printf("[DPI] cmac_init: tap_alloc failed\n");
            goto err;
        }

        flags = fcntl(fd, F_GETFL, 0);
        fcntl(fd, F_SETFL, flags | O_NONBLOCK);

        cmac_struct.fds[i] = fd;
    }

    return 0;
err:
    cmac_clear();
    return -1;
}

int cmac_read(int cmac_id, const svOpenArrayHandle h)
{
    if (cmac_id >= cmac_struct.num_cmac)
        return -1;

    return tap_read(cmac_struct.fds[cmac_id], h, 0);
}

int cmac_write(int cmac_id, const svOpenArrayHandle h)
{
    if (cmac_id >= cmac_struct.num_cmac)
        return -1;

    return tap_write(cmac_struct.fds[cmac_id], h, 0);
}
