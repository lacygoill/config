// Purpose: using `scanf()`
// Reference: page 462 (paper) / 491 (ebook)

#include <stdio.h>

    int
main(void)
{
    char name1[11], name2[11];
    int count;

    printf("Please enter 2 names.\n");
    count = scanf("%5s %10s", name1, name2);
    printf("I read the %d names %s and %s.\n",
            count, name1, name2);

    return 0;
}
//     Please enter 2 names.
//     Jesse Jukes
//     I read the 2 names Jesse and Jukes.
//
//     Please enter 2 names.
//     Liza Applebottham
//     I read the 2 names Liza and Applebotth.
//
//     Please enter 2 names.
//     Portensia Callowit
//     I read the 2 names Porte and nsia.
//
// In the first example, both names fell within the allowed size limits.  In the
// second  example, only  the first  10 characters  of `Applebottham`  were read
// because we used a `%10s` format.  In the third example, the last four letters
// of `Portensia` went into `name2` because the second call to `scanf()` resumed
// reading input where the first ended; in  this case, that was still inside the
// word `Portensia`.
