// Purpose: What will the following program print?
//
//     /* retire.c   */
//     #include <stdio.h>
//     int main(void)
//     {
//       int age = 20;
//
//       while (age++ <= 65)
//       {
//          if (( age % 20) == 0) /* is age divisible by 20? */
//              printf("You are %d. Here is a raise.\n", age);
//          if (age = 65)
//              printf("You are %d. Here is your gold watch.\n", age);
//       }
//       return 0;
//     }
//
// Output:
//
//     You are 65. Here is your gold watch.
//     You are 65. Here is your gold watch.
//     ...
//
// Because, there is an error here:
//
//          if (age = 65)
//                  ^
//                  ✘
//                  assignment (it should be ==)
//
// Reference: page 294 (paper) / 323 (ebook)
