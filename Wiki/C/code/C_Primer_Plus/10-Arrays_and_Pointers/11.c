// Purpose: sums the elements of an array
// Reference: page 405 (paper) / 434 (ebook)

#include <stdio.h>
#define SIZE 10

int sump(int * start, int * end);

    int
main(void)
{
    int marbles[SIZE] = {20, 10, 5, 39, 4, 16, 19, 26, 31, 20};
    int answer;

    answer = sump(marbles, marbles + SIZE);
    printf("The total number of marbles is %d.\n", answer);

    return 0;
}

// use pointer arithmetic
    int
sump(int * start, int * end)
{
    int total = 0;

    while (start < end)
    {
        total += *start;  // add value to `total`
        start++;          // advance pointer to next element
        //
        // You can also condense the body of the loop to one line:
        //
        //     total += *start++;
        //
        // The  unary  operators `*`  and  `++`  have  the same  precedence  but
        // associate from right to left.   IOW, this is equivalent to:
        //
        //     total += (*(start++))
    }

    return total;
}
