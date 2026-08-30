// Purpose: entry condition loop
// Reference: page 221 (paper) / 250 (ebook)

#include <stdio.h>

    int
main(void)
{
    const int secret_code = 13;
    int code_entered;

    // Here a `while` loop makes the code longer compared to a `do while` loop.
    printf("To enter the triskaidekaphobia therapy club,\n");
    printf("please enter the secret code number: ");
    scanf("%d", &code_entered);
    while (code_entered != secret_code)
    {
        printf("To enter the triskaidekaphobia therapy club,\n");
        printf("please enter the secret code number: ");
        scanf("%d", &code_entered);
    }

    printf("Congratulations! You are cured!\n");

    return 0;
}
