#ifndef __KERNEL_USER_SYSCALL_DEFINE_H
#define __KERNEL_USER_SYSCALL_DEFINE_H

typedef enum {
    SYS_GETPID,
    SYS_WRITE,
    SYS_READ,
    SYS_PUTCHAR,
    SYS_MALLOC,
    SYS_FREE,
    SYS_FORK,
    SYS_CLEAR
} SYSCALL;

#endif
