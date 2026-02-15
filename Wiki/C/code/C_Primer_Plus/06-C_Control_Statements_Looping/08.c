// Purpose: misuse of =
// Reference: page 201 (paper) / 230 (ebook)

#include <stdio.h>

    int
main(void)
{
    long num;
    long sum = 0L;
    int status;

    printf("Please enter an integer to be summed ");
    printf("(q to quit): ");
    status = scanf("%ld", &num);
    while (status = 1)
    //            ^
    //            ✘
    // `status = 1` assigns  `1` to `status`,  and always evaluates to  `1` (the
    // RHS  of the  assignment)  which  is true.   Besides,  if  you enter  `q`,
    // `scanf()` will indefinitely fail to read  a number; in each iteration, it
    // will put back the same `q` in the input buffer.
    {
        sum = sum + num;
        printf("Please enter next integer (q to quit): ");
        status = scanf("%ld", &num);
    }
    printf("Those integers sum to %ld.\n", sum);

    return 0;
}
