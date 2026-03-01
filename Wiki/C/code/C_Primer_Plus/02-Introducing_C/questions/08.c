// Purpose: Consider the following program:
//
//     #include <stdio.h>
//         int
//     main(void)
//     {
//         int a, b;
//         a = 5;
//         b = 2;    // line 7
//         b = a;    // line 8
//         a = b;    // line 9
//         printf("%d %d\n", b, a)
//
//         return 0;
//     }
//
// What is the program state after line 7?  Line 8?  Line 9?
//
// Reference: page 52 (paper) / 81 (ebook)

// After line 7: a = 5, b = 2
// After line 8: a = 5, b = 5
// After line 9: a = 5, b = 5
