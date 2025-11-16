// Purpose: Write a program which crashes to study `gdb(1)`.
// Note that for the program to crash you must not pass `-O` to `gcc(1)`.
// We include it in our `$GCC_OPTS`.
//
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
