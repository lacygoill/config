// Purpose: Write a program that initializes  an array-of-double and then copies
// the contents of  the array into three other arrays.   (All four arrays should
// be declared  in the main  program.)  To make the  first copy, use  a function
// with array  notation.  To make the  second copy, use a  function with pointer
// notation  and pointer  incrementing.  Have  the first  two functions  take as
// arguments the name of the target array, the name of the source array, and the
// number of elements  to be copied.  Have the third  function take as arguments
// the name of the target, the name of  the source, and a pointer to the element
// following the last element of the  source.  That is, the function calls would
// look like this, given the following declarations:
//
//     double source[5] = {1.1, 2.2, 3.3, 4.4, 5.5};
//     double target1[5];
//     double target2[5];
//     double target3[5];
//     copy_arr(target1, source, 5);
//     copy_ptr(target2, source, 5);
//     copy_ptrs(target3, source, source + 5);
//
// Reference: page 439 (paper) / 468 (ebook)

#include <stdio.h>

void copy_arr(double * target1, double * source, int n);
void copy_ptr(double * target2, double * source, int n);
void copy_ptrs(double * target2, double * source, double * end);

    int
main(void)
{
    double source[5] = {1.1, 2.2, 3.3, 4.4, 5.5};
    double target1[5];
    double target2[5];
    double target3[5];
    copy_arr(target1, source, 5);
    copy_ptr(target2, source, 5);
    copy_ptrs(target3, source, source + 5);

    int i;
    for (i = 0; i < 5; i++)
        printf("%5.1f %5.1f %5.1f %5.1f\n",
                source[i], target1[i], target2[i], target3[i]);
    return 0;
}

    void
copy_arr(double * target1, double * source, int n)
{
    int i;
    for (i = 0; i < n; i++)
        target1[i] = source[i];
}

    void
copy_ptr(double * target2, double * source, int n)
{
    int i;
    for (i = 0; i < n; i++)
        *(target2 + i) = *(source + i);
}

    void
copy_ptrs(double * target2, double * source, double * end)
{
    while (source < end)
        *target2++ = *source++;
}
