// Purpose: Write a program  that converts time in minutes to  time in hours and
// minutes.  Use `#define` or `const` to create a symbolic constant for 60.  Use
// a `while` loop to allow the user to enter values repeatedly and terminate the
// loop if a value for the time of 0 or less is entered.
//
// Reference: page 187 (paper) / 216 (ebook)

#include <stdio.h>
#define MINUTES_IN_HOUR 60

    int
main(void)
{
    int time, hours, left;
    printf("Enter a time in minutes: ");
    scanf("%d", &time);
    while (time > 0)
    {
        hours = time / MINUTES_IN_HOUR;
        left = time % MINUTES_IN_HOUR;
        printf("That's %d hours, %d minutes.\n", hours, left);
        printf("Enter next time: ");
        scanf("%d", &time);
    }

    return 0;
}
