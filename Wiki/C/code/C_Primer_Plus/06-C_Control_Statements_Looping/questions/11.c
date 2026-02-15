// Purpose: Mr. Noah likes  counting by  twos, so  he's written  the following
// program to create an  array and to fill it with the integers  2, 4, 6, 8, and
// so on.  What, if anything, is wrong with this program?
//
//     #include <stdio.h>
//     #define SIZE 8
//     int main(void)
//     {
//       int by_twos[SIZE];
//       int index;
//
//       for (index = 1; index <= SIZE; index++)
//            by_twos[index] = 2 * index;
//       for (index = 1; index <= SIZE; index++)
//            printf("%d ", by_twos);
//       printf("\n");
//       return 0;
//     }
//
// Reference: page 240 (paper) / 269 (ebook)

#include <stdio.h>
#define SIZE 8

    int
main(void)
{
    int by_twos[SIZE];
    int index;

    for (index = 0; index < SIZE; index++)
        by_twos[index] = 2 * (index + 1);
    for (index = 0; index < SIZE; index++)
        printf("%d ", by_twos[index]);
    printf("\n");
    return 0;
}
