// Purpose: Use a  copy function from Programming  Exercise 2 to copy  the third
// through  fifth  elements  of  a  seven-element  array  into  a  three-element
// array.  The function itself need not be altered; just choose the right actual
// arguments.  (The actual  arguments need not be an array  name and array size.
// They only have to be the address of an array element and a number of elements
// to be processed.)
//
// Reference: page 439 (paper) / 468 (ebook)

#include <stdio.h>
#define SOURCE_SIZE 7
#define TARGET_SIZE 3

void copy_arr(double * target, double * source, int n);
void print_arr(double * source, int size);

    int
main(void)
{
    double source[SOURCE_SIZE] = {1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7};
    double target[TARGET_SIZE];

    printf("%s", "The original array is: ");
    print_arr(source, SOURCE_SIZE);
    copy_arr(target, source + TARGET_SIZE - 1, TARGET_SIZE);
    printf("%s", "The new array is: ");
    print_arr(target, TARGET_SIZE);

    return 0;
}

    void
copy_arr(double * target, double * source, int n)
{
    int i;
    for (i = 0; i < n; i++)
        target[i] = source[i];
}

    void
print_arr(double * array, int size)
{
    for (int i = 0; i < size; i++)
        printf("%g ", array[i]);
    putchar('\n');
}
