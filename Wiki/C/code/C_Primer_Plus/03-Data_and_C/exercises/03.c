// Purpose: Write a program that sounds an alert and then prints the following text:
//
//     Startled by the sudden sound, Sally shouted,
//     "By the Great Pumpkin, what was that!"
//
// Reference: page 97 (paper) / 126 (ebook)

#include <stdio.h>

    int
main(void)
{
    //      alert
    //      vv
    printf("\aStartled by the sudden sound, Sally shouted,\n");
    printf("\"By the Great Pumpkin, what was that!\"\n");
    return 0;
}
