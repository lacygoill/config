// Purpose: Write a program that creates an eight-element array of ints and sets
// the elements to the first eight powers  of 2 and then prints the values.  Use
// a for  loop to  set the  values, and,  for variety,  use a  do while  loop to
// display the values.
//
// Reference: page 243 (paper) / 272 (ebook)

#include <stdio.h>
#define SIZE 8

int pow2(int i);

    int
main(void)
{
    int array[SIZE];
    int i = 0;

    for (; i < SIZE; i++)
        array[i] = pow2(i);

    i = -1;
    do
    {
        i++;
        printf("%d ", array[i]);
    } while (i < SIZE - 1);

    printf("\n");

    return 0;
}

    int
pow2(int i)
{
    int res = 1;
    for (int j = 1; j <= i; j++)
        res *= 2;

    return res;
}
