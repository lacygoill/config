// Purpose: What's wrong with this program?
//
//     #include <stdio.h>
//     int main(void)
//     {
//       char ch;
//       int lc = 0;    /* lowercase char count
//       int uc = 0;    /* uppercase char count
//       int oc = 0;    /* other char count
//
//       while ((ch = getchar()) != '#')
//       {
//            if ('a' <= ch >= 'z')
//                 lc++;
//            else if (!(ch < 'A') || !(ch > 'Z')
//                 uc++;
//            oc++;
//       }
//       printf(%d lowercase, %d uppercase, %d other, lc, uc, oc);
//       return 0;
//     }
//
// Reference: page 294 (paper) / 323 (ebook)

#include <stdio.h>
#include <ctype.h>

    int
main(void)
{
    int ch;
    int lc = 0;    // lowercase char count
    int uc = 0;    // uppercase char count
    int oc = 0;    // other char count

    while ((ch = getchar()) != '#')
    {
        if (islower(ch))
            lc++;
        else if (isupper(ch))
            uc++;
        else
            oc++;
    }
    printf("%d lowercase, %d uppercase, %d other", lc, uc, oc);

    return 0;
}
