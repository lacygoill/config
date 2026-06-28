// Purpose: Write a  program that initializes a  two-dimensional array-of-double
// and uses  one of the copy  functions from exercise 2  to copy it to  a second
// two-dimensional  array.  (Because  a  two-dimensional array  is  an array  of
// arrays, a one-dimensional copy function can be used with each subarray.)
//
// Reference: page 439 (paper) / 468 (ebook)

#include <stdio.h>
#define ROWS 3
#define COLS 2

void copy_arr(double * target1, double * source, int n);
void print_arr(double (* target)[COLS], int rows);

    int
main(void)
{
    double array[ROWS][COLS] = {{1.1, 2.2}, {3.3, 4.4}, {5.5, 6.6}};
    double target[ROWS][COLS];
    int i;
    printf("The original array is:\n");
    print_arr(array, ROWS);

    for (i = 0; i < ROWS; i++)
        copy_arr(target[i], array[i], COLS);

    printf("\nThe copied array is:\n");
    print_arr(target, ROWS);
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
print_arr(double (* target)[COLS], int rows)
{
    int r, c;
    for (r = 0; r < rows; r++)
    {
        for (c = 0; c < COLS; c++)
            printf("%g ", target[r][c]);
        putchar('\n');
    }
}
