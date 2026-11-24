// Purpose: Given  the input  `Go west, young man!`, what  would each  of the
// following programs produce for output? (The  ! follows the space character in
// the ASCII sequence.)
//
//     a.
//
//     #include <stdio.h>
//     int main(void)
//     {
//         char ch;
//
//         scanf("%c", &ch);
//         while (ch != 'g')
//         {
//              printf("%c", ch);
//              scanf("%c", &ch);
//         }
//         return 0;
//     }
//
// Output:
//
//     Go west, youn
//
// ---
//
//     b.
//
//     #include <stdio.h>
//
//     int main(void)
//     {
//         char ch;
//         scanf("%c", &ch);
//         while (ch != 'g')
//         {
//              printf("%c", ++ch);
//              scanf("%c", &ch);
//         }
//         return 0;
//     }
//
// Output:
//
//     Hp!Xftu-!zpvo
//
// ---
//
//     c.
//     #include <stdio.h>
//
//     int main(void)
//     {
//         char ch;
//
//         do {
//              scanf("%c", &ch);
//              printf("%c", ch);
//         } while (ch != 'g');
//         return 0;
//     }
//
// Output:
//
//     Go west, young
//
// ---
//
//     d.
//
//     #include <stdio.h>
//
//     int main(void)
//     {
//         char ch;
//
//         scanf("%c", &ch);
//         for (ch = '$'; ch != 'g'; scanf("%c", &ch))
//              printf("%c", ch);
//         return 0;
//     }
//
// Output:
//
//     $o west, young
//
// Reference: page 237 (paper) / 266 (ebook)
