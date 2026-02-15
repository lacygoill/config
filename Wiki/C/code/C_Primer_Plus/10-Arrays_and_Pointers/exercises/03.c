// Purpose: Write  a  function that  returns  the  largest  value stored  in  an
// array-of-int.  Test the function in a simple program.
//
// Reference: page 439 (paper) / 468 (ebook)

#include <stdio.h>

int max(int * array, int size);

    int
main(void)
{
    int array[8] = {4, 3, 2, 1, 9, 8, 7, 6};
    printf("The maximum value of the array is: %d\n", max(array, 8));
    return 0;
}

    int
max(int * array, int size)
{
    int i, max;
    for (i = 0, max = array[0]; i < size; i++)
        if (array[i] > max)
            max = array[i];
    return max;
}
