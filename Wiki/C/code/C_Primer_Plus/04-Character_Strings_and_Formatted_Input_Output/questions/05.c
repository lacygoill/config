// Purpose: Suppose a program starts as follows:
//
//     #define BOOK "War and Peace"
//     int main(void)
//     {
//        float cost = 12.99;
//        float percent = 80.0;
//
// Construct a `printf()` statement that uses `BOOK`, `cost`, and `percent` to
// print the following:
//
//     This copy of "War and Peace" sells for $12.99.
//     That is 80% of list.
//
// Reference: page 139 (paper) / 168 (ebook)

#include <stdio.h>
#define BOOK "War and Peace"

    int
main(void)
{
    // We need it to suppress an error:{{{
    //
    //     error: conversion from ‘double’ to ‘float’ changes value from ‘1.299e+1’ to ‘1.29899998e+1f’ [-Werror=float-conversion]
    //     float cost = 12.99;
    //
    // Without `f`, 12.99 is first parsed as a double, which is an approximation
    // of 12.99.  Let's call it D.  Then,  D is converted to a float (let's call
    // it F),  which implies a  rounding error.  The  error comes from  the fact
    // that D != F.
    //
    // Appending `f` (12.99f)  tells the compiler to parse  the literal directly
    // as a float in the first  place, skipping the intermediate double rounding
    // step entirely, so there's no lossy conversion for it to warn about.
    //}}}
    //                v
    float cost = 12.99f;
    float percent = 80.0f;
    //                  ^
    // We don't need it, because 80 is exactly representable in both `float` and
    // `double`.  But we use it to  be consistent; all floats should be suffixed
    // with `f`.

    printf("This copy of \"%s\" sells for $%.2f.\n", BOOK, cost);
    printf("That is %.0f%% of list.\n", percent);

    return 0;
}
