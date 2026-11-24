// Purpose: introduction to pointers
// Reference: page 8 (paper) / 8 (ebook)

#include <stdio.h>

int j, k;
int *ptr;
//  ^
//  `*` is used in an **l**value to *declare* a pointer

    int
main(void)
{
    j = 1;
    k = 2;
    ptr = &k;

    printf("\n");
    //                                                    `%p` expects an argument of type `void *`,
    //                                                    so we type cast `&j` to the expected type
    //                                                    v------v
    printf("j has the value %d and is stored at %p\n", j, (void *)&j);
    printf("k has the value %d and is stored at %p\n", k, (void *)&k);
    printf("ptr has the value %p and is stored at %p\n", (void *)ptr, (void *)&ptr);
    printf("The value of the integer pointed to by ptr is %d\n", *ptr);
    //                                                           ^
    // `*` is used in an **r**value to *dereference* a pointer

    return 0;
}
