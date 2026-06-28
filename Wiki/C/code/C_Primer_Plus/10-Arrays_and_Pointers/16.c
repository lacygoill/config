// Purpose: zippo info via a pointer variable
// GCC Options: -Wno-format
// Reference: page 420 (paper) / 449 (ebook)
#include <stdio.h>

    int
main(void)
{
    int zippo[4][2] = {{2, 4}, {6, 8}, {1, 3}, {5, 7}};
    int (*pz)[2];
    pz = zippo;

    printf("   pz = %p,    pz + 1 = %p\n",
               pz,         pz + 1);
    printf("pz[0] = %p, pz[0] + 1 = %p\n",
            pz[0],      pz[0] + 1);
    printf("pz[0][0] = %d\n", pz[0][0]);
    printf("  *pz[0] = %d\n", *pz[0]);
    printf("    **pz = %d\n", **pz);
    printf("      pz[2][1] = %d\n", pz[2][1]);
    printf("*(*(pz+2) + 1) = %d\n", *(*(pz+2) + 1));

    return 0;
}

//     pz = 0x7fff49402240,    pz + 1 = 0x7fff49402248
//     pz[0] = 0x7fff49402240, pz[0] + 1 = 0x7fff49402244
//     pz[0][0] = 2
//     *pz[0] = 2
//      **pz = 2
//        pz[2][1] = 3
//     *(*(pz+2) + 1) = 3
