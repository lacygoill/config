// Purpose: Do Programming  Exercise 13, but use  variable-length array function
// parameters.
//
// Reference: page 440 (paper) / 469 (ebook)

#include <stdio.h>
#define ROWS 3
#define COLS 5

void get_numbers(int rows, int cols, double array[rows][cols]);
double average_row(double array[]);
double average_all(int rows, int cols, double array[rows][cols]);
double get_max(int rows, int cols, double array[rows][cols]);

    int
main(void)
{
    double array[ROWS][COLS], average, max;
    int i;

    get_numbers(ROWS, COLS, array);

    for (i = 0; i < ROWS; i++)
    {
        average = average_row(array[i]);
        printf("\nThe average of row %d is: %g", i + 1, average);
    }

    average = average_all(ROWS, COLS, array);
    printf("\nThe average of all values is: %g\n", average);

    max = get_max(ROWS, COLS, array);
    printf("\nThe largest value is: %g\n", max);

    return 0;
}

    void
get_numbers(int rows, int cols, double array[rows][cols])
{
    int i, j;
    printf("Enter 3 sets of 5 double numbers:\n");
    for (i = 0; i < rows; i++)
        for (j = 0; j < cols; j++)
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
average_all(int rows, int cols, double array[rows][cols])
{
    int i, j;
    double total;
    for (i = 0, total = 0; i < rows; i++)
        for (j = 0; j < cols; j++)
            total += array[i][j];
    return total / (rows * cols);
}

    double
get_max(int rows, int cols, double array[rows][cols])
{
    int i, j;
    double max = array[0][0];
    for (i = 0; i < rows; i++)
        for (j = 0; j < cols; j++)
            if (array[i][j] > max)
                max = array[i][j];
    return max;
}
