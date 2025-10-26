// Purpose: Write a program which crashes to study `gdb(1)`.
// Reference: page 40

#include <stdio.h>

    void
crash(void)
{
    char *test = NULL;
    printf("%c", test[0]);
}

    void
b(void)
{
    crash();
}

    void
a(void)
{
    b();
}

    int
main(void)
{
    a();
    return 0;
}
