// Purpose: Modify  the temperature  conversion program  to print  the table  in
// reverse order, that is, from 300 degrees to 0.
// Reference: page 14 (paper) / 28 (ebook)

#include <stdio.h>

    int
main(void)
{
    int fahr;

    for (fahr = 300; fahr >= 0; fahr -= 20)
        printf("%3d %6.1f\n", fahr, (5.0f / 9.0f) * ((float)fahr - 32.0f));
}
