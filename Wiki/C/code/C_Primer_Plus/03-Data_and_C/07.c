// Purpose: portable names for integer types
// Reference: page 82 (paper) / 111 (ebook)

#include <stdio.h>
int main(void)
{
    float a,b;
    b = 2.0e20 + 1.0;
    a = b - 2.0e20;
    printf("%f \n", a);
    return 0;
}
