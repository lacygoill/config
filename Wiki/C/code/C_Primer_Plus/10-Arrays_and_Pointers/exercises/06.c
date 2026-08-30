// Purpose: Write a function that reverses the  contents of an array of `double`
// and test it in a simple program.
//
// Reference: page 439 (paper) / 468 (ebook)

#include <stdio.h>
#define SIZE 8
void reverse(double * array, int size);

    int
main(void)
{
    int i;
    double array[SIZE] = {8.8, 7.7, 6.6, 5.5, 4.4, 3.3, 2.2, 1.1};
    reverse(array, SIZE - 1);
    printf("%s", "The reversed array is: ");
    for (i = 0; i < SIZE; i++)
        printf(i == SIZE - 1 ? "%g" : "%g, ", array[i]);
    putchar('\n');
    return 0;
}

    void
reverse(double * array, int size)
{
    int i = 0;
    int j = size;
    double temp;
    while (i < j)
    {
        temp = array[i];
        array[i] = array[j];
        array[j] = temp;
        i++;
        j--;
    }
}
