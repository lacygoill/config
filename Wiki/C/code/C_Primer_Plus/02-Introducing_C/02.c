// Purpose: convert 2 fathoms to feet
// Reference: page 42 (paper) / 71 (ebook)

#include <stdio.h>

    int
main(void)
{
    // we can declare multiple variables into a single statement
    int feet, fathoms;

    fathoms = 2;
    // The number of feet in 2 fathoms is the number of feet in one fathom (`6`)
    // times the number of fathoms (`fathoms` which here is `2`).
    // The same way that  the number of meters in 2 kilometers  is the number of
    // meters in one kilometer (`1000`) times the number of kilometers (`2`).
    //
    // More generally, there is an asymmetry between a math equation such as:{{{
    //
    //     1 km = 1000 m
    //
    // And code such as:
    //
    //     int m, km;
    //     m = 1000 * km;
    //
    // Notice how  the multiplication  by 1000 is  not on the  same side  of the
    // equal sign.  That's  because in math `km`  and `m` are units,  while in C
    // they are variables.
    //}}}
    feet = 6 * fathoms;
    printf("There are %d feet in %d fathoms!\n", feet, fathoms);
    printf("Yes, I said %d feet!\n", 6 * fathoms);
    //                               ^---------^
    //                               the argument doesn't have to be a variable;
    //                               it can be any expression of the right type

    return 0;
}
