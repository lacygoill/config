// Purpose: Define a `power(m, n)`  function which raises an integer  `m` to the
// positive integer power `n`, and call it from `main()`.
// Reference: page 24 (paper) / 38 (ebook)

#include <stdio.h>

// Function prototype.{{{
//
// It must be  located *before* calling the function (from  `main()`).  Here, we
// say that `power()` is a function which expects two `int` arguments and return
// an `int`.
//
// It  has to  agree with  the later  definition and  uses of  `power()`.  OTOH,
// parameter names  don't need to agree.   For example, here, we  name the first
// parameter `m`, but later, when we define `power()`, we name it `base`.
//
// It could be shortened into:
//
//     int power(int, int);
//
// Because parameter  names are  optional.  Still,  prefer to  write well-chosen
// names to serve as documentation.
//}}}
int power(int m, int n);
//                     ^
//                     Don't forget the trailing semicolon!

    int
main(void)
{
    int i;

    // Print 2ⁱ and (-3)ⁱ for i ∈ [0, 9]:{{{
    //
    //     0 1 1
    //     1 2 -3
    //     2 4 9
    //     3 8 -27
    //     4 16 81
    //     5 32 -243
    //     6 64 729
    //     7 128 -2187
    //     8 256 6561
    //     9 512 -19683
    //}}}
    for (i = 0; i < 10; ++i)
        printf("%d %d %d\n", i, power(2, i), power(-3, i));
        //                            ^--^         ^---^
        //                            arguments (!= parameters)

    // A  program should  return status  to its  environment.  We  terminate the
    // function immediately and `return` 0 to  the caller (i.e. the shell).  `0`
    // implies normal  termination; non-zero values signal  unusual or erroneous
    // termination conditions.
    return 0;
}

// raise `base` to `n`-th power; `n >= 0`
// A function definition has this form:{{{
//
//     return-type function-name(parameter declarations, if any)
//     {
//         declarations
//         statements
//     }
//
// Function  definitions can  appear in  any order,  and in  one source  file or
// several, although no function can be split between files.
//}}}
    int
power(int base, int n)
//    ^-------------^
//    parameters and their types
//
// Parameters and variables are local to a function.
// Thus, the `i` in `power()` is unrelated to the `i` in `main()`.
{
    int i, res;

    res = 1;
    for (i = 1; i <= n; ++i)
        res *= base;

    // We terminate the function immediately and `return` the computation to the
    // caller.
    return res;
}
