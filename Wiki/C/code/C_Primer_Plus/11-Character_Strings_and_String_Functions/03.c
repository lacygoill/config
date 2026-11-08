// Purpose: addresses of strings
// Reference: page 446 (paper) / 475 (ebook)

#include <stdio.h>
#define MSG "I'm special."

    int
main(void)
{
    char ar[] = MSG;
    const char *pt = MSG;
    printf("address of \"I'm special\": %p \n", "I'm special");
    printf("           address of ar: %p\n", ar);
    printf("           address of pt: %p\n", pt);
    printf("          address of MSG: %p\n", MSG);
    printf("address of \"I'm special\": %p \n", "I'm special");
    return 0;
}
//     address of "I'm special": 0x56406726b004
//                address of ar: 0x7ffd745374d3
//                address of pt: 0x56406726b02e
//               address of MSG: 0x56406726b02e
//     address of "I'm special": 0x56406726b004
//
// Notice that `pt`  and `MSG` are the  same address, while `ar`  is a different
// address.
//
// Second,  although the  string  literal  "I'm special."  occurs  twice in  the
// `printf()` statements,  the compiler chose  to use one storage  location, but
// not the  same address  as `MSG`.   The compiler  has the  freedom to  store a
// literal  that's used  more  than  once in  one  or  more locations.   Another
// compiler might  choose to represent  all three occurrences of  "I'm special."
// with a single storage location.
//
// Third, the part  of memory used for  static data is different  from that used
// for dynamic  memory, the  memory used  for `ar`.   Notice how  `ar`'s address
// starts differently compared to the other addresses.
