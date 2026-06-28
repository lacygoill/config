// Purpose: mismatched floating-point conversions
// GCC Options: -Wno-error
// Reference: page 124 (paper) / 153 (ebook)

#include <stdio.h>

    int
main(void)
{
    float n1 = 3.0;
    double n2 = 3.0;
    long n3 = 2000000000;
    long n4 = 1234567890;

    printf("%.1e %.1e %.1e %.1e\n", n1, n2, n3, n4);
    printf("%ld %ld\n", n3, n4);
    printf("%ld %ld %ld %ld\n", n1, n2, n3, n4);
    //     3.0e+00 3.0e+00 3.0e+00 8.8e-320
    //     2000000000 1234567890
    //     2000000000 1234567890 2000000000 0
    // On the first line, why is `n3` converted into `3.0e+00`?{{{
    //
    // First, `%e`  causes `printf()` to  expect a  `double` value, which  is an
    // 8-byte value  on our  system.  When  `printf()` looks  at `n3`,  which is
    // a  4-byte  value  on  our  system,  it  also  looks  at  the  adjacent  4
    // bytes.  Therefore,  it looks at an  8-byte unit in which  the actual `n3`
    // is  embedded.   Second,  it  interprets  the  bits  in  this  unit  as  a
    // floating-point number.  Some  bits, for example, would  be interpreted as
    // an exponent. So even  if `n3` had the correct number  of bits, they would
    // be interpreted differently  under `%e` than under `%ld`.   The net result
    // is nonsense.
    //}}}
    // On the third line, why is `n4` converted into 0?{{{
    //
    // Because `printf()` has mismatches elsewhere.  `n1` and `n2` should not be
    // matched with  `%ld`.  The problem lies  in how C passes  information to a
    // function.
    //
    // The program puts  `n1`, `n2`, `n3` and  `n4` on the stack.   For `n1`, it
    // places 8 bytes  on the stack (float is converted  to double).  Similarly,
    // it places 8  more bytes for `n2`,  followed by 4 bytes each  for `n3` and
    // `n4`.
    //
    // Then `printf()` reads the  values off the stack but, when  it does so, it
    // reads them according  to the conversion specifiers.   The `%ld` specifier
    // indicates that  `printf()` should read  4 bytes, so `printf()`  reads the
    // first 4 bytes  in the stack as  its first value.  This is  just the first
    // half of `n1`,  and it is interpreted  as a long integer.   The next `%ld`
    // specifier reads 4 more bytes; this is just the second half of `n1` and is
    // interpreted as  a second long  integer.  Similarly, the third  and fourth
    // instances of `%ld` cause  the first and second halves of  `n2` to be read
    // and to be interpreted as two more  long integers, so although we have the
    // correct specifiers  for `n3`  and `n4`, `printf()`  is reading  the wrong
    // bytes.
    //}}}

    return 0;
}
