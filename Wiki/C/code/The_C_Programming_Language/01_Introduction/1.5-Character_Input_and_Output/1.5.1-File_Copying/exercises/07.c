// Purpose: Write a program to print the value of EOF.
// Reference: page 17 (paper) / 31 (ebook)

#include <stdio.h>

    int
main(void)
{
    printf("EOF is %d\n", EOF);
    //     EOF is -1
    //
    // On our machine, `EOF` is `-1`.
    // It's `#define`d in `stdio.h`.
    // But the actual value might vary from system to system.
    // That's why you should always prefer symbolic constants over magic values.
}
