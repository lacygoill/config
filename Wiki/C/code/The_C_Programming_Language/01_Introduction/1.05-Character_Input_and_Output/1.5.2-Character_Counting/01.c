// Purpose: Write a program which counts characters.
// Reference: page 18 (paper) / 32 (ebook)

#include <stdio.h>

    int
main(void)
{
    // We save the count in a `long`  instead of an `int` because an `int` might
    // be too small to prevent an input overflow.
    long nc;

    nc = 0;
    while (getchar() != EOF)
        // `++` is a new operator which increments by one.
        // It's equivalent to `nc = nc + 1`.
        // To decrement by 1, you would use `--` instead.
        // `++` and  `--` can  be used as  prefix operators  (`++nc`/`--nc`), or
        // postfix operators  (`nc++`, `nc--`);  depending on the  position, the
        // operation is performed before or after the evaluation.
        ++nc;

    printf("%ld\n", nc);
    //       ^^
    //       long integer

    return 0;
}
