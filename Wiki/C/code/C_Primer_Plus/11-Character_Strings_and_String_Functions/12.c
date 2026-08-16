// Purpose: using `puts()`
// Reference: page 464 (paper) / 493 (ebook)

#include <stdio.h>
#define DEF "I am a #defined string."

    int
main(void)
{
    char str1[80] = "An array was initialized to me.";
    const char * str2 = "A pointer was initialized to me.";

    puts("I'm an argument to puts().");
    puts(DEF);
    puts(str1);
    puts(str2);
    puts(&str1[5]);
    puts(str2 + 4);

    return 0;
}
//     I'm an argument to puts().
//     I am a #defined string.
//     An array was initialized to me.
//     A pointer was initialized to me.
//     ray was initialized to me.
//     inter was initialized to me.
//
// This example  reminds you that phrases  in double quotation marks  are string
// constants  and  are treated  as  addresses.   Also,  the names  of  character
// array strings  are treated  as addresses.  The  expression `&str1[5]`  is the
// address of  the sixth  element of  the array  `str1`.  That  element contains
// the  character  'r',  and  that  is  what  `puts()`  uses  for  its  starting
// point.  Similarly, `str2 + 4` points to the memory cell containing the 'i' of
// "pointer", and the printing starts there.
