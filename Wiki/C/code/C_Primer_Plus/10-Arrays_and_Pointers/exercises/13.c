// Purpose: Write a  program that prompts the  user to enter three  sets of five
// double numbers each.  (You may assume the user responds correctly and doesn't
// enter non-numeric data.)  The program should accomplish all of the following:
//
//    a. Store the information in a 3x5 array.
//    b. Compute the average of each set of five values.
//    c. Compute the average of all the values.
//    d. Determine the largest value of the 15 values.
//    e. Report the results.
//
// Each  major  task  should  be  handled  by  a  separate  function  using  the
// traditional C approach to handling  arrays.  Accomplish task “b” by using
// a function that computes and returns  the average of a one-dimensional array;
// use a loop  to call this function  three times.  The other  tasks should take
// the entire array  as an argument, and the functions  performing tasks “c”
// and “d” should return the answer to the calling program.
//
// Reference: page 440 (paper) / 469 (ebook)

#include <stdio.h>
#define ROWS 3
#define COLS 5

void get_numbers(double array[][COLS], int rows);
double average_row(double array[]);
double average_all(double array[][COLS], int rows);
double get_max(double array[][COLS], int rows);

    int
main(void)
{
    double array[ROWS][COLS], average, max;
    int i;

    get_numbers(array, ROWS);

    for (i = 0; i < ROWS; i++)
    {
        average = average_row(array[i]);
        printf("\nThe average of row %d is: %g", i + 1, average);
    }

    average = average_all(array, ROWS);
    printf("\nThe average of all values is: %g\n", average);

    max = get_max(array, ROWS);
    printf("\nThe largest value is: %g\n", max);

    return 0;
}

    void
get_numbers(double array[][COLS], int rows)
{
    int i, j;
    printf("Enter 3 sets of 5 double numbers:\n");
    for (i = 0; i < rows; i++)
        for (j = 0; j < COLS; j++)
            scanf("%lf", &array[i][j]);
}

    double
average_row(double array[])
{
    double subtot;
    int i;

    for (i = 0, subtot = 0; i < COLS; i++)
        subtot += array[i];

    return subtot / COLS;
}

    double
average_all(double array[][COLS], int rows)
{
    int i, j;
    double total;
    for (i = 0, total = 0; i < rows; i++)
        for (j = 0; j < COLS; j++)
            total += array[i][j];
    return total / (rows * COLS);
}

    double
get_max(double array[][COLS], int rows)
{
    int i, j;
    double max = array[0][0];
    for (i = 0; i < rows; i++)
        for (j = 0; j < COLS; j++)
            if (array[i][j] > max)
                max = array[i][j];
    return max;
}
