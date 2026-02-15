// Purpose: Write a program that requests a  type `double` number and prints the
// value of  the number cubed.  Use  a function of  your own design to  cube the
// value  and print  it.  The  `main()` should  pass the  entered value  to this
// function.
//
// Reference: page 188 (paper) / 217 (ebook)

#include <stdio.h>

void cube(double d);

    int
main(void)
{
    double d;
    printf("Enter a `double` number: ");
    scanf("%lf", &d);
    cube(d);

    return 0;
}

    void
cube(double d)
{
    printf("the cube is: %.2f\n", d * d * d);
}
