// Purpose: Write a  program that reads  input as  a stream of  characters until
// encountering EOF.  Have it report the number of uppercase letters, the number
// of lowercase letters,  and the number of other characters  in the input.  You
// may assume that  the numeric values for the lowercase  letters are sequential
// and  assume  the  same  for  uppercase.   Or,  more  portably,  you  can  use
// appropriate classification functions from the `ctype.h` library.
//
// Reference: page 333 (paper) / 362 (ebook)

#include <stdio.h>
#include <ctype.h>

    int
main(void)
{
    int ch;
    int upper = 0;
    int lower = 0;
    int other = 0;
    while ((ch = getchar()) != EOF)
        if (isupper(ch))
            upper++;
        else if (islower(ch))
            lower++;
        else
            other++;
    printf("There are %d uppercase characters, %d lowercase characters,"
            " and %d other characters.\n", upper, lower, other);
    return 0;
}
