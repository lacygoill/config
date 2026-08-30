// Purpose: Write a function that returns the difference between the largest and
// smallest  elements of  an array-of-double.   Test  the function  in a  simple
// program.
//
// Reference: page 439 (paper) / 468 (ebook)

#include <stdio.h>

double diff_max_min(double * array, int size);

    int
main(void)
{
    double array[8] = {4.4, 3.3, 2.2, 1.1, 9.9, 8.8, 7.7, 6.6};
    printf("The difference between the largest and smallest elements is %g.\n",
            diff_max_min(array, 8));
    return 0;
}

    double
diff_max_min(double * array, int size)
{
    int i;
    double min, max;
    for (i = 0, min = max = array[0]; i < size; i++)
    {
        if (array[i] > max)
            max = array[i];
        if (array[i] < min)
            min = array[i];
    }

    return max - min;
}
