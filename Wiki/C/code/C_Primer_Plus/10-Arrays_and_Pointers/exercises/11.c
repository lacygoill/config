// Purpose: Write a program that declares a 3×5 array of int and initializes it
// to some values of your choice.  Have the program print the values, double all
// the values,  and then  display the new  values.  Write a  function to  do the
// displaying and a second function to do the doubling.  Have the functions take
// the array name and the number of rows as arguments.
//
// Reference: page 440 (paper) / 469 (ebook)

#include <stdio.h>
#define ROWS 3
#define COLS 5

void print_arr(int array[][COLS], int rows);
void double_arr(int array[][COLS], int rows);

    int
main(void)
{
    int array[ROWS][COLS] = {
        {1, 2, 3, 4, 5},
        {6, 7, 8, 9, 10},
        {11, 12, 13, 14, 15}
    };
    printf("%s", "The original array is:\n");
    print_arr(array, ROWS);
    double_arr(array, ROWS);
    printf("%s", "\nThe new array is:\n");
    print_arr(array, ROWS);
    return 0;
}

    void
print_arr(int array[][COLS], int rows)
{
    int r, c;
    for (r = 0; r < rows; r++)
    {
        for (c = 0; c < COLS; c++)
            printf("%2d ", array[r][c]);
        putchar('\n');
    }
}

    void
double_arr(int array[][COLS], int rows)
{
    int r, c;
    for (r = 0; r < rows; r++)
        for (c = 0; c < COLS; c++)
            array[r][c] *= 2;
}
