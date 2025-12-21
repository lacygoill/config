// Purpose: exit condition loop
// Reference: page 221 (paper) / 250 (ebook)

#include <stdio.h>

    int
main(void)
{
    const int secret_code = 13;
    int code_entered;

    do
    {
        printf("To enter the triskaidekaphobia therapy club,\n");
        printf("please enter the secret code number: ");
        scanf("%d", &code_entered);
    } while (code_entered != secret_code);
    //                                   ^
    // The `do while` loop itself counts as a statement and, therefore, requires
    // a terminating semicolon.
    printf("Congratulations! You are cured!\n");

    return 0;
}
