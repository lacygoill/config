// Purpose: Simplify `power()` using the fact that all function arguments are passed "by value".{{{
//
// This means that the  called function is given the values  of its arguments in
// temporary variables rather than the originals.
//
// ---
//
// This contrasts with "call by reference"  languages like Fortran, in which the
// called routine has access to the original argument, not a local copy.
//
// ---
//
// If necessary, a  function can modify a variable from  its caller.  The latter
// must provide the *address* of the variable to be set (technically a *pointer*
// to the variable); the  callee must declare the parameter to  be a pointer and
// access the variable indirectly through it.
//
// ---
//
// Arrays are an exception.   When the name of an array is  used an an argument,
// the value passed to the callee is the location or address of the beginning of
// the array –  there is no copying  of array elements.  The  callee can alter
// any of them.
//}}}
// Reference: page 27 (paper) / 41 (ebook)

#include <stdio.h>

int power(int m, int n);

    int
main(void)
{
    int i;

    for (i = 0; i < 10; ++i)
        printf("%d %d %d\n", i, power(2, i), power(-3, i));

    return 0;
}

    int
power(int base, int n)
{
    int res;

    // Previously, we incremented an `i` counter.
    // Now, we get rid of `i`, and directly decrement `n`.
    // It will  have no effect  on the original  `i` argument used  in `main()`,
    // because the  argument is  passed "by  value" (i.e. it's  a copy,  not the
    // original).
    for (res = 1; n > 0; --n)
        res *= base;

    return res;
}
