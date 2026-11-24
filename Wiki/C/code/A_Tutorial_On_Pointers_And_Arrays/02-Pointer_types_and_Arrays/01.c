// Purpose: print out array using array notation or by dereferencing pointer
// Reference: page 10 (paper) / 10 (ebook)

#include <stdio.h>

int my_array[] = {1, 23, 17, 4, -5, 100};
int *ptr;
// TODO: explain purposes of `int` here

    int
main(void)
{
    int i;
    // point our pointer to the first element of the array
    ptr = &my_array[0];

    printf("\n\n");
    for (i = 0; i < 6; i++)
    {
        printf("my_array[%d] = %3d   ", i, my_array[i]);
        printf("ptr + %d = %3d\n", i, *(ptr + i));
    }

    return 0;
}
