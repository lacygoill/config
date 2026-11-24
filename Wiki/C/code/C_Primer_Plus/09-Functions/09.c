// Purpose: room rate program; compile with Listing 10.c
// Reference: page 363 (paper) / 392 (ebook)

// Warning: You can't execute this program by pressing `||` as usual.
// That's because `gcc(1)` needs to be passed 2 files: 09.c and 10.c
//
//     $ gcc 09.c 10.c -o build/09 $GCC_OPTS  && ./build/09
//                ^--^
#include <stdio.h>
#include "11.h"

    int
main(void)
{
    int nights;
    double hotel_rate;
    int code;

    while ((code = menu()) != QUIT)
    {
        switch (code)
        {
            case 1: hotel_rate = HOTEL1;
                    break;
            case 2: hotel_rate = HOTEL2;
                    break;
            case 3: hotel_rate = HOTEL3;
                    break;
            case 4: hotel_rate = HOTEL4;
                    break;
            default: hotel_rate = 0.0;
                     printf("Oops!\n");
                     break;
        }
        nights = getnights();
        showprice(hotel_rate, nights);
    }
    printf("Thank you and goodbye.\n");

    return 0;
}
