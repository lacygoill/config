// Purpose: sums the elements of an array
// GCC Options: -Wno-sizeof-array-argument
// Reference: page 403 (paper) / 432 (ebook)

#include <stdio.h>
#define SIZE 10

int sum(int ar[], int n);

    int
main(void)
{
    int marbles[SIZE] = {20, 10, 5, 39, 4, 16, 19, 26, 31, 20};
    long answer;

    answer = sum(marbles, SIZE);
    printf("The total number of marbles is %ld.\n", answer);
    printf("The size of marbles is %zd bytes.\n", sizeof(marbles));

    return 0;
}

    int
sum(int ar[], int n)    // how big an array?
{
    int total = 0;

    for (int i = 0; i < n; i++)
        total += ar[i];
    printf("The size of ar is %zd bytes.\n", sizeof(ar));

    return total;
}

//     The size of ar is 8 bytes.
//     The total number of marbles is 190.
//     The size of marbles is 40 bytes.
//
// NOTE: The size of `marbles` is 40  bytes.  This makes sense because `marbles`
// contains 10  ints, each 4 bytes,  for a total of  40 bytes.  But the  size of
// `ar` is  just 8 bytes.  That's  because `ar` is  not an array itself;  it's a
// pointer  to the  first element  of `marbles`.   Our system  uses 8  bytes for
// storing addresses, so the size of a pointer variable is 8 bytes.
