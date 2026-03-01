// Purpose: checks to see where variables are stored
// Reference: page 367 (paper) / 396 (ebook)

#include <stdio.h>

void mikado(int);           // declare function

    int
main(void)
{
    int pooh = 2, bah = 5;  // local to `main()`

    printf("In main(), pooh = %d and &pooh = %p\n", pooh, (void *)&pooh);
    printf("In main(), bah = %d and &bah = %p\n", bah, (void *)&bah);
    mikado(pooh);

    return 0;
}

    void
mikado(int bah)             // define function
{
    int pooh = 10;
    printf("In mikado(), pooh = %d and &pooh = %p\n", pooh, (void *)&pooh);
    printf("In mikado(), bah = %d and &bah = %p\n", bah, (void *)&bah);
}
