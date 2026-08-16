// Purpose: Now modify the program of Programming Exercise 5 so that it computes
// the sum  of squares  of the  integers.  (If  you prefer,  how much  money you
// receive if you get $1 the first day, $4 the second day, $9 the third day, and
// so on.   This looks  like a  much better  deal!)  C  doesn't have  a squaring
// function, but you can use the fact that the square of `n` is `n * n`.
//
// Reference: page 187 (paper) / 216 (ebook)

#include <stdio.h>

    int
main(void)
{
    int count, sum, max;

    count = 0;
    sum = 0;
    printf("How far should the calculation proceed? ");
    scanf("%d", &max);
    while (count++ < max)
        sum = sum + count * count;
    printf("sum = %d\n", sum);

    return 0;
}
