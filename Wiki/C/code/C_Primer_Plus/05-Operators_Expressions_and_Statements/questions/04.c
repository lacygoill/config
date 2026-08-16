// Purpose: You suspect that there are some errors in the next program.  Can you find them?
//     int main(void)
//     {
//       int i = 1,
//       float n;
//       printf("Watch out! Here come a bunch of fractions!\n");
//       while (i < 30)
//         n = 1/i;
//         printf(" %f", n);
//       printf("That's all, folks!\n");
//       return;
//     }
//
// Reference: page 183 (paper) / 212 (ebook)
#include <stdio.h>

    int
main(void)
{
    int i = 1;
    float n;
    printf("Watch out! Here come a bunch of fractions!\n");
    while (i++ < 30)
    {
        n = 1.0f / (float)i;
        printf("%f\n", n);
    }
    printf("That's all, folks!\n");
    return 0;
}
