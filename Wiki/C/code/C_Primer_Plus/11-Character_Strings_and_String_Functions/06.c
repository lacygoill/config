// Purpose: using `gets()` and `puts()`
// Reference: page 453 (paper) / 482 (ebook)

#include <stdio.h>
#define STLEN 81

    int
main(void)
{
    char words[STLEN];

    puts("Enter a string, please.");
    gets(words);
    printf("Your string twice:");
    printf("%s\n", words);
    puts(words);
    puts("Done.");

    return 0;
}
//     06.c: In function ‘main’:
//     06.c:13:5: error: implicit declaration of function ‘gets’; did you mean ‘fgets’? [-Wimplicit-function-declaration]
//        13 |     gets(words);
//           |     ^~~~
//           |     fgets
//
// Our compiler doesn't support `gets()` because it has been deprecated.
//
// The problem is that `gets()` doesn't check  to see if the input line actually
// fits into the  `words` array.  Given that its only  argument here is `words`,
// `gets()` can't check.  Recall  that the name of an array  is converted to the
// address  of the  first element.   Thus `gets()`  only knows  where the  array
// begins, not how many elements it has.
//
// If  the input  string is  too long,  you get  *buffer overflow*, meaning  the
// excess characters overflow the designated target.  The extra characters might
// just  go into  unused memory  and cause  no immediate  problems, or  they may
// overwrite other data  in your program and cause  a *segmentation fault* (this
// means that the program attempted to access memory not allocated to it).
