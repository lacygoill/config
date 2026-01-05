// Purpose: recursion illustration
// Reference: page 354 (paper) / 383 (ebook)

#include <stdio.h>
void up_and_down(int);

    int
main(void)
{
    up_and_down(1);
    return 0;
}

    void
up_and_down(int n)
{
    printf("level %d: n location %p\n", n, (void *)&n); // 1
    if (n < 4)
        up_and_down(n + 1);
    printf("LEVEL %d: n location %p\n", n, (void *)&n); // 2
}
