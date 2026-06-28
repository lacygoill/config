// Purpose: Write  a program  that creates  an integer  variable called  `toes`.
// Have the  program set  `toes` to  10.  Also have  the program  calculate what
// twice `toes`  is and what  `toes` squared is.   The program should  print all
// three values, identifying them.
//
// Reference: page 54 (paper) / 83 (ebook)

#include <stdio.h>

    int
main(void)
{
    int toes = 10;
    printf("toes = %d\ntwice toes = %d\ntoes squared = %d\n", toes, toes * 2, toes * toes);
    return 0;
}
