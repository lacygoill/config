// Purpose: What will the following program print?
//
//     #include <stdio.h>
//     int main(void)
//     {
//        int k;
//        for (k = 1, printf("%d: Hi!\n", k); printf("k = %d\n",k),
//             k*k < 26; k+=2, printf("Now k is %d\n", k) )
//                 printf("k is %d in the loop\n",k);
//        return 0;
//     }
//
// Output:
//
//     1: Hi!
//     k = 1
//     k is 1 in the loop
//     Now k is 3
//     k = 3
//     k is 3 in the loop
//     Now k is 5
//     k = 5
//     k is 5 in the loop
//     Now k is 7
//     k = 7
//
// Reference: page 240 (paper) / 269 (ebook)
