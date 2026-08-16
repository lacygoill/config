// Purpose: Write a  program that shows  you a menu  offering you the  choice of
// addition,  subtraction,  multiplication,  or division.   After  getting  your
// choice,  the  program asks  for  two  numbers,  then performs  the  requested
// operation.   The program  should accept  only the  offered menu  choices.  It
// should use type `float` for the numbers and allow the user to try again if he
// or she fails to enter a number.   In the case of division, the program should
// prompt the  user to enter a  new value if 0  is entered as the  value for the
// second number.  A typical program run should look like this:
//
//     Enter the operation of your choice:
//     a. add           s. subtract
//     m. multiply      d. divide
//     q. quit
//     a
//     Enter first number: 22.4
//     Enter second number: one
//     one is not a number.
//     Please enter a number, such as 2.5, -1.78E8, or 3: 1
//     22.4 + 1 = 23.4
//     Enter the operation of your choice:
//     a. add           s. subtract
//     m. multiply      d. divide
//     q. quit
//     d
//     Enter first number: 18.4
//     Enter second number: 0
//     Enter a number other than 0: 0.2
//     18.4 / 0.2 = 92
//     Enter the operation of your choice:
//     a. add           s. subtract
//     m. multiply      d. divide
//     q. quit
//     q
//     Bye.
//
// GCC Options: -Wno-float-equal
//
// Reference: page 333 (paper) / 362 (ebook)

#include <stdio.h>

char get_choice(void);
char get_first(void);
float get_float(void);

    int
main(void)
{
    char choice;
    float a, b;

    while ((choice = get_choice()) != 'q')
    {
        printf("%s", "Enter first number: ");
        a = get_float();
        printf("%s", "Enter second number: ");
        b = get_float();

        switch (choice)
        {
            case 'a': printf("\n%.1f + %.1f = %.1f\n\n", a, b, a + b);
                      break;
            case 'm': printf("\n%.1f * %.1f = %.1f\n\n", a, b, a * b);
                      break;
            case 's': printf("\n%.1f - %.1f = %.1f\n\n", a, b, a - b);
                      break;
            case 'd': while (b == 0)
                      {
                          printf("Enter a number other than 0: ");
                          b = get_float();
                      }
                      printf("\n%.1f / %.1f = %.1f\n\n", a, b, a / b);
                      break;
            case 'q': return 0;
            default: printf("Program error!\n");
                     break;
        }
    }

    printf("Bye.\n");
    return 0;
}

    char
get_choice(void)
{
    char ch;
    printf("Enter the operation of your choice:\n");
    printf("a. add           s. subtract\n");
    printf("m. multiply      d. divide\n");
    printf("q. quit\n");
    ch = get_first();
    while (ch != 'a' && ch != 'm' && ch != 's' && ch != 'd' && ch != 'q')
    {
        printf("Please respond with a, m, s, d, or q.\n");
        ch = get_first();
    }

    return ch;
}

    char
get_first(void)
{
    int ch;

    ch = getchar();
    // abc
    //  ^^
    //  flush that
    while (getchar() != '\n')
        continue;

    return (char)ch;
}

    float
get_float(void)
{
    float num;
    int ch;

    while (scanf("%f", &num) != 1)
    {
        while ((ch = getchar()) != '\n')
            putchar(ch);  // dispose of bad input
        printf(" is not a number.\n");
        printf("Please enter a number, such as 2.5, -1.78E8, or 3: ");
    }
    // 123abc
    //    ^^^
    //    flush that
    while (getchar() != '\n')
        continue;

    return num;
}
