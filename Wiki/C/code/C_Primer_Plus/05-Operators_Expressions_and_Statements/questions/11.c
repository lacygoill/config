// Purpose: What will the following program print?
//
//     #define MESG "COMPUTER BYTES DOG"
//     #include <stdio.h>
//     int main(void)
//     {
//        int n = 0;
//
//        while ( n < 5 )
//           printf("%s\n", MESG);
//           n++;
//        printf("That's all.\n");
//        return 0;
//     }
//
// Answer: It will print "COMPUTER BYTES DOG" indefinitely, because `n++` is not
// part of the `while` loop; thus, the `n < 5` test will always be true.
//
// Reference: page 186 (paper) / 215 (ebook)
