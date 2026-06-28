// Purpose: Write   a   program   that   initializes   a   two-dimensional   3x5
// array-of-double  and  uses a  VLA-based  function  to  copy  it to  a  second
// two-dimensional array.  The  two functions should be capable,  in general, of
// processing arbitrary NxM arrays.  (If you  don't have access to a VLA-capable
// compiler, use the traditional C approach of functions that can process an Nx5
// array).
//
// Reference: page 440 (paper) / 469 (ebook)

#include <stdio.h>
#define ROWS 3
#define COLS 5

void copy_arr(int rows, int cols,
        double source[rows][cols],
        double target[rows][cols]);

void print_arr(int rows, int cols,
        double array[rows][cols]);

    int
main(void)
{
    double target[ROWS][COLS];
    double source[ROWS][COLS] = {
        {1.1, 2.2, 3.3, 4.4, 5.5},
        {6.6, 7.7, 8.8, 9.9, 10.0},
        {11.1, 12.2, 13.3, 14.4, 15.5}};

    printf("%s", "The original array is:\n");
    print_arr(ROWS, COLS, source);

    copy_arr(ROWS, COLS, source, target);

    printf("%s", "\nThe copied array is:\n");
    print_arr(ROWS, COLS, target);

    return 0;
}

    void
copy_arr(int rows, int cols,
        double source[rows][cols],
        double target[rows][cols])
{
    int r, c;
    for (r = 0; r < rows ; r++)
        for (c = 0; c < cols ; c++)
            target[r][c] = source[r][c];
}

    void
print_arr(int rows, int cols,
        double array[rows][cols])
{
    int r, c;
    for (r = 0; r < rows; r++)
    {
        for (c = 0; c < cols; c++)
            printf("%g ", array[r][c]);
        putchar('\n');
    }
}
