// Purpose: You suspect that the following  program is not perfect.  What errors
// can you find?
//
//     #include <stdio.h>
//     int main(void)
//     {
//       int i, j, list(10);
//
//       for (i = 1, i <= 10, i++)
//       {
//           list[i] = 2*i + 3;
//           for (j = 1, j > = i, j++)
//               printf(" %d", list[j]);
//           printf("\n");
//       }
//
// Reference: page 236 (paper) / 265 (ebook)

#include <stdio.h>
int main(void)
{
    int i, j;
    int list[10];

    for (i = 0; i < 10; i++)
    {
        list[i] = 2 * i + 3;
        for (j = 1; j <= i; j++)
            printf(" %d", list[j]);
        printf("\n");
    }

    return 0;
}
