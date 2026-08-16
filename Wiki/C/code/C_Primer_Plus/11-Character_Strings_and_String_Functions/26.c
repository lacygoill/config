// Purpose: `strcpy()` demo
// Reference: page 484 (paper) / 513 (ebook)

#include <stdio.h>
#include <string.h>
#define WORDS "beast"
#define SIZE 40

    int
main(void)
{
    const char * orig = WORDS;
    char copy[SIZE] = "Be the best that you can be.";
    char * ps;

    puts(orig);
    puts(copy);
    // replace `copy` from its 8th character with `orig`
    //
    //            8th character
    //            v
    //     Be the best that you can be.
    //     Be the beast
    //            ^---^
    //            replacement, including its terminating Null
    //            which discards the original end of the string
    ps = strcpy(copy + 7, orig);
    //   ^----^        ^
    puts(copy);
    puts(ps);

    return 0;
}

//     beast
//     Be the best that you can be.
//     Be the beast
//     beast
