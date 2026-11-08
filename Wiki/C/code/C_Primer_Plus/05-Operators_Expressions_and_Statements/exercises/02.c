// Purpose: Write a  program that asks  for an integer  and then prints  all the
// integers from (and including) that value up to (and including) a value larger
// by 10.  (That is, if the input is 5,  the output runs from 5 to 15.)  Be sure
// to separate each output value by a space or tab or newline.
//
// Reference: page 187 (paper) / 216 (ebook)

#include <stdio.h>

    int
main(void)
{
    int i, c;
    printf("Enter an integer: ");
    scanf("%d", &i);
    c = i;
    while (c <= i + 10)
    {
        printf("%d ", c);
        ++c;
    }

    return 0;
}
