// Purpose: pointers and strings
// Reference: page 452 (paper) / 481 (ebook)

#include <stdio.h>

    int
main(void)
{
    const char * mesg = "Don't be a fool!";
    const char * copy;
    copy = mesg;
    printf("%s\n", copy);
    printf("mesg = %s; &mesg = %p; value = %p\n",
            mesg, (const void *)&mesg, (const void *)mesg);
    printf("copy = %s; &copy = %p; value = %p\n",
            copy, (const void *)&copy, (const void *)copy);
    return 0;
}
//     Don't be a fool!
//     mesg = Don't be a fool!; &mesg = 0x7ffe1c48f558; value = 0x56272d481004
//     copy = Don't be a fool!; &copy = 0x7ffe1c48f550; value = 0x56272d481004
//
// Notice  how  `mesg`  and  `copy`  points to  the  same  location.   All  that
// `copy = mesg;` does  is produce a  second pointer  pointing to the  very same
// string.  That's because it's more efficient  to copy one address than a bunch
// of characters.  Often, the address is all that is needed to get the job done.
// If you truly require  a copy that is a duplicate, you  can use the `strcpy()`
// or `strncpy()` function, discussed later in this chapter.
