// Purpose: true and false values in C
// Reference: page 199 (paper) / 228 (ebook)

#include <stdio.h>

    int
main(void)
{
    int true_val, false_val;

    true_val = (10 > 2);   // value of a true relationship
    false_val = (10 == 2);  // value of a false relationship
    printf("true = %d; false = %d\n", true_val, false_val);
    //     true = 1; false = 0

    return 0;
}
