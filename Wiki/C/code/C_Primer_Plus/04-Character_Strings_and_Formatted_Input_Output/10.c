// Purpose: string formatting
// Reference: page 121 (paper) / 150 (ebook)

#include <stdio.h>
#define BLURB "Authentic imitation!"

    int
main(void)
{
    printf("[%2s]\n", BLURB);
    printf("[%24s]\n", BLURB);
    printf("[%24.5s]\n", BLURB);
    printf("[%-24.5s]\n", BLURB);
    //     [Authentic imitation!]
    //     [    Authentic imitation!]
    //     [                   Authe]
    //     [Authe                   ]

    return 0;
}
