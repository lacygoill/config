// Purpose: Here's  an  alternative  design  for Listing  5.9.   It  appears  to
// simplify the  code by replacing the  two `scanf()` statements in  Listing 5.9
// with a  single `scanf()` statement.  What  makes this design inferior  to the
// original?
//
//     #include <stdio.h>
//     #define S_TO_M 60
//     int main(void)
//     {
//       int sec, min, left;
//
//       printf("This program converts seconds to minutes and ");
//       printf("seconds.\n");
//       printf("Just enter the number of seconds.\n");
//       printf("Enter 0 to end the program.\n");
//       while (sec > 0) {
//         scanf("%d", &sec);
//         min = sec/S_TO_M;
//         left = sec % S_TO_M;
//         printf("%d sec is %d min, %d sec.\n", sec, min, left);
//         printf("Next input?\n");
//         }
//       printf("Bye!\n");
//       return 0;
//     }
//
// Answer: When  `sec > 0`   is  evaluated   for  the   first  time,   `sec`  is
// uninitialized. `sec` could  hold any value, including 0 or  a negative value,
// which would prevent the loop from being run.
//
// One solution, albeit an  inelegant one, is to initialize `sec`  to, say, 1 so
// that  the test  is passed  the first  time through.   This uncovers  a second
// problem.  When  you finally  type 0  to halt the  program, `sec`  doesn't get
// checked until after the  loop is finished, and the results  for 0 seconds are
// printed out.   You need to  move `scanf()`  *after* the 2  `printf()`s, which
// also means that you need a `scanf()` before the loop.
//
// Reference: page 184 (paper) / 213 (ebook)

#include <stdio.h>
#define S_TO_M 60

    int
main(void)
{
    int sec, min, left;

    printf("This program converts seconds to minutes and ");
    printf("seconds.\n");
    printf("Just enter the number of seconds.\n");
    printf("Enter 0 to end the program.\n");
    scanf("%d", &sec);
    while (sec > 0) {
        min = sec / S_TO_M;
        left = sec % S_TO_M;
        printf("%d sec is %d min, %d sec.\n", sec, min, left);
        printf("Next input?\n");
        scanf("%d", &sec);
    }
    printf("Bye!\n");
    return 0;
}
