// Purpose: You have just been employed  by MacroMuscle, Inc. (Software for Hard
// Bodies).  The  company is entering  the European  market and wants  a program
// that converts  inches to centimeters (1  inch = 2.54 cm).   The company wants
// the program set up so that it prompts  the user to enter an inch value.  Your
// assignment is  to define  the program  objectives and  to design  the program
// (steps 1 and 2 of the programming process).
//
// Reference: page 25 (paper) / 54 (ebook)

#include <stdio.h>
    int
main(void)
{
    float inch;

    printf("Enter an inch value: ");
    scanf("%f", &inch);
    printf("%.2f inches = %.2f centimeters\n", inch, 2.54f * inch);

    return 0;
}
