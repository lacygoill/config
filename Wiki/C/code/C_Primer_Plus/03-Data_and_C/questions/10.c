// Purpose: Correct this silly program. (The `/` in C means division.)
//
//     void main(int) / this program is perfect /
//     {
//      cows, legs integer;
//      printf("How many cow legs did you count?\n");
//      scanf("%c", legs);
//      cows = legs / 4;
//      printf("That implies there are %f cows.\n", cows);
//     }
//
// Reference: page 96 (paper) / 125 (ebook)

#include <stdio.h>

    int
main(void) /* this program is perfect */
{
    int cows, legs;
    printf("How many cow legs did you count?\n");
    scanf("%d", &legs);
    cows = legs / 4;
    printf("That implies there are %d cows.\n", cows);
    return 0;
}
