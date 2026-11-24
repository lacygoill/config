// Purpose: Consider the following program:
//
//     #include <stdio.h>
//     int main(void)
//     {
//         int x, y;
//
//         x = 10;
//         y = 5;        // line 7
//         y = x + y;    // line 8
//         x = x * y;    // line 9
//         printf("%d %d\n", x, y);
//         return 0;
//     }
//
// What is the program state after line 7?  Line 8?  Line 9?
//
// Reference: page 52 (paper) / 81 (ebook)

// After line 7: x = 10, y = 5
// After line 8: x = 10, y = 15
// After line 9: x = 150, y = 15
