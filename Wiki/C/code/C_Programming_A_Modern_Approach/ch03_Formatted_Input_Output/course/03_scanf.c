// Purpose: study scanf()
// Reference: page 42 (paper) / 67 (ebook)

#include <stdio.h>

    int
main(void)
{
    int a, b;
    float x, y;

    // In a `scanf()` *format*, when finding:
    // whitespace, whitespace is skipped in the input.{{{
    //
    // In a `scanf()` format, you only need a whitespace in front of an ordinary
    // non-whitespace character;  and only  if you  want to  let the  user input
    // whitespace before inputting that character.
    //
    //     scanf("x%d", &a);
    //     printf("%d\n", a);
    //               space
    //               v
    //     // input: ▫x3
    //     // output: 12345
    //                ^---^
    //                random integer
    //                      ✘
    //
    //            v
    //     scanf(" x%d", &a);
    //     printf("%d\n", a);
    //     // input: ▫▫▫x3
    //               ^^^
    //     // output: 3
    //                ^
    //                ✔
    //}}}
    // a conversion specification, whitespace is skipped in the input.{{{
    //
    //     scanf("%d", &a);
    //     printf("%d\n", a);
    //               vvv
    //     // input: ▫▫▫3
    //     // output: 3
    //                ^
    //                ✔
    //}}}
    //   but an input whitespace is not entirely ignored (it can still terminate an input item).{{{
    //
    //     scanf("%d", &a);
    //     printf("%d\n", a);
    //     // input: 1 2
    //     // output: 1
    //}}}
    // ordinary non-whitespace, a character is either discarded or put back in the input.{{{
    //
    // Either:
    //
    //    - it matches the next input character, it's discarded, and `scanf()`
    //      goes on processing the rest of the format
    //
    //                v
    //         scanf("x%d", &a);
    //         printf("%d\n", a);
    //                   x is discarded because it matches the `x` in the format
    //                   v
    //         // input: x3
    //         // output: 3
    //
    //    - it does *not* match the next input character, and is put back into
    //      the input buffer, right before `scanf()` returns; which stops the
    //      processing of the format, and the reading of the input (until
    //      another possible call to `scanf()`)
    //
    //                v
    //         scanf("x%d", &a);
    //         printf("%d\n", a);
    //                   y is not discarded because it does not match the `x` in the format
    //                   v
    //         // input: y3
    //         // output: 12345
    //                    ^---^
    //                    random integer
    //                          ✘
    //
    //
    //
    //                v
    //         scanf("x%d", &a);
    //                v
    //         scanf("y%d", &a);
    //         printf("%d\n", a);
    //                   y is discarded because it matches the `y` in the format of the 2nd `scanf()`
    //                   v
    //         // input: y3
    //         // output: 3
    //                    ^
    //                    ✔
    //}}}


    // `scanf()` peeks at a character, and "puts it back" if it doesn't match the conversion specification.{{{
    //
    // That's possible because  `scanf()` does not read the  input directly; the
    // latter is first written into a buffer.
    //}}}
    //   A "put back" character can be read:{{{
    //
    //    - during the scanning of the next input item (since the next scanning
    //      will read from the same input buffer)
    //
    //         int a, b;
    //         scanf("%d%d");
    //         printf("a = %d, b = %d");
    //                    this minus sign is put back while scanning the first %d
    //                    (because an integer cannot contain a minus sign in the middle);
    //                    it's read again while scanning the second %d
    //                    v
    //         // input: 1-2
    //         // output: a = 1 b = -2
    //
    //    - by a subsequent call to `scanf()`
    //}}}
    //   Even the trailing/validating newline is peeked at.{{{
    //
    // It will be left for the next call of `scanf()`.
    //
    //     int a, b;
    //     scanf("%d", &a);
    //     scanf("x%d", &b);
    //     printf("a = %d, b = %d\n", a, b);
    //     // input: 1
    //     // output: a = 1, b = 12345
    //                           ^---^
    //                           random integer
    //                                 ✘
    //
    // Here, the  second `scanf()` does  not ask you  for any input  because the
    // validating newline of  the first `scanf()` is still in  the input buffer,
    // and does not match the leading  `x` from the format.  Also, remember that
    // `scanf()` does  not skip whitespace  (such as  a newline) when  trying to
    // match an ordinary non-whitespace (such as `x`).
    //}}}
    // `scanf()` returns as soon as it fails to read an item; ignoring subsequent ones.{{{
    //
    // That's why, if you input `1!2`:
    //
    //    - `b` is not initialized with `2`
    //
    //    - the second call to `scanf()` does not prompt you for anything;
    //      because `!` is still at the start of the input buffer (it was put
    //      back by the previous `scanf()`),  but it doesn't match  the start
    //      of  the `%d%d%f%f` format,  which is `%d`
    //}}}
    // Warning: Do *not* put a trailing newline in your format.{{{
    //
    // It would cause your program to hang:
    //
    //              ✘
    //              vv
    //     scanf("%d\n", &a);
    //     printf("%d", a);
    //     // input: 1
    //     // output: the program hangs
    //
    // Same pitfall with any whitespace.
    //
    // Rationale: A whitespace tells `scanf()` to look for a non-whitespace.
    // Until you give one, `scanf()` will keep asking for more input.
    //}}}

    //       to skip possible whitespace before the ordinary non-whitespace `/`
    //       v
    scanf("%d /%d", &a, &b);
    printf("a = %d, b = %d\n", a, b);


    // `scanf()` can include several conversion specifications.
    // `%f`, `%e`, `%g` are interchangeable.{{{
    //
    // Whatever  you write,  `scanf()`  always uses  the same  rules  to read  a
    // floating-point number.  It looks for (in that order):
    //
    //    - a plus or minus sign (optional)
    //    - a series of digits (possibly containing a decimal point)
    //    - an exponent (optional):
    //      it must start with `e` or `E`, then an optional sign, then one or more digits
    //}}}
    scanf("%d%d%f%f", &a, &b, &x, &y);
    printf("a = %d, b = %d, x = %f, y = %f\n", a, b, x, y);
    // Q: What will `printf()` print if you input `1-20.3-4.0e3`?{{{
    //
    //     a = 1, b = -20, x = 0.300000, y = -4000.000000
    //
    // When `scanf()` reads an integer for `a`, it stops before the first minus:
    //
    //     1-20.3-4.0e3
    //      ^
    //
    // The minus is only  peeked at.  And since it can't be in  the middle of an
    // integer, it's put back for the next input item.
    //
    // Similarly, when reading an integer for `b`, the dot is only peeked at:
    //
    //     1-20.3-4.0e3
    //         ^
    //
    // Same thing when reading a floating-point number for `x`; the second minus
    // is also only peeked at:
    //
    //     1-20.3-4.0e3
    //           ^
    //}}}

    return 0;
}
