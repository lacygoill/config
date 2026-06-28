// Purpose: strings and pointers
// Reference: page 443 (paper) / 472 (ebook)

#include <stdio.h>

    int
main(void)
{
    printf("%s, %p, %c\n", "We", "are", *"space farers");
    return 0;
}
//     We, 0x564ac034f004, s


// The `%s` format prints the string "We".
// The `%p` format prints the address of the first character of "are".
//
// Finally,  `*"space farers"` prints  the value  to which  the address  points,
// which is  the first  character of  the string "space  farers" (i.e.  "s").  A
// string acts  as a  pointer to  where the  string is  stored.  This  action is
// analogous  to the  name of  an array  acting as  a pointer  to the  array’s
// location.
