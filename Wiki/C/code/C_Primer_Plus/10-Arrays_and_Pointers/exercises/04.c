// Purpose: Write a function that returns the  index of the largest value stored
// in an array-of-double.  Test the function in a simple program.
//
// Reference: page 439 (paper) / 468 (ebook)

#include <stdio.h>

int max_index(double * array, int size);

    int
main(void)
{
    double array[8] = {4.4, 3.3, 2.2, 1.1, 9.9, 8.8, 7.7, 6.6};
    printf("The index of the largest value is %d.\n", max_index(array, 8));
    return 0;
}

    int
max_index(double * array, int size)
{
    int i, max;
    for (i = 0, max = 0; i < size; i++)
        if (array[i] > array[max])
            max = i;
    return max;
}
