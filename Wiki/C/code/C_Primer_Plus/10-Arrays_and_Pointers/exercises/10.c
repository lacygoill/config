// Purpose: Write a function  that sets each element  in an array to  the sum of
// the corresponding elements in two other arrays.   That is, if array 1 has the
// values 2, 4, 5, and 8 and array 2 has the values 1, 0, 4, and 6, the function
// assigns array 3 the  values 3, 4, 9, and 14.  The  function should take three
// array names and  an array size as  arguments.  Test the function  in a simple
// program.
//
// Reference: page 440 (paper) / 469 (ebook)

#include <stdio.h>
#define SIZE 4

void sum(int [], int [], int [], int);
void print_arr(int [], int);

    int
main(void)
{
    int array1[SIZE] = {2, 4, 5, 8};
    int array2[SIZE] = {1, 0, 4, 6};
    int array3[SIZE];

    printf("The first array is:\n");
    print_arr(array1, SIZE);
    printf("The second array is:\n");
    print_arr(array2, SIZE);

    sum(array1, array2, array3, SIZE);
    printf("The sum of the two arrays is:\n");
    print_arr(array3, SIZE);

    return 0;
}

    void
sum(int array1[], int array2[], int array3[], int size)
{
    for (int i = 0; i < size; i++)
        array3[i] = array1[i] + array2[i];
}

    void
print_arr(int array[], int size)
{
    for (int i = 0; i < size; i++)
        printf("%d ", array[i]);
    putchar('\n');
}
