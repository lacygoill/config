// Purpose: Write a  program that requests  the user's  first name and  then the
// user's last name.  Have it print the entered names on one line and the number
// of letters in each name on the  following line.  Align each letter count with
// the end of the corresponding name, as in the following:
//
//     Melissa Honeybee
//           7        8
//
// Next, have  it print the same  information, but with the  counts aligned with
// the beginning of each name:
//
//     Melissa Honeybee
//     7       8
//
// Reference: page 141 (paper) / 170 (ebook)

#include <stdio.h>
#include <string.h>

    int
main(void)
{
    char first[40];
    char last[40];
    int size_first, size_last;

    printf("Enter you first name and then your last name: ");
    scanf("%s%s", first, last);
    printf("%s %s\n", first, last);

    size_first = (int)strlen(first);
    size_last = (int)strlen(last);

    printf("%*d %*d\n", size_first, size_first, size_last, size_last);
    printf("%s %s\n", first, last);
    printf("%-*d %-*d\n", size_first, size_first, size_last, size_last);

    return 0;
}
