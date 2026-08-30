# ?

Talk  about  the  biased  representation  as  opposed  to  the  sign-and-modulus
representation, and the 2's complement representation.

# ?

All computers provide hardware instructions for adding integers.
If two  positive integers  are added  together, the result  may give  an integer
greater than or equal to `2^31`.
In this case, we say that integer overflow occurs.
One would hope that this leads to an informative error message for the user, but
whether or  not this happens  depends on  the programming language  and compiler
being used.
In some  cases, the overflow  bits may be discarded  and the programmer  must be
alert to prevent this from happening.
The same problem may occur if two negative integers are added together, giving a
negative integer with magnitude greater than `2^31`.
On  the other  hand, if  two  integers with  opposite sign  are added  together,
integer overflow cannot  occur, although an overflow bit may  arise when the 2's
complement bitstrings are added together.
Consider the operation:

    x + (-y)

where

    0 ≤ x ≤ 2^31 − 1
    1 ≤ y ≤ 2^31

Clearly, it  is possible  to store the  desired result `x  − y`  without integer
overflow.
The result may be positive, negative, or  zero, depending on whether `x > y`, `x = y`,
or `x < y`.

---

Prove that when computing `x − y` via the 2's complement representations for `x`
and `-y`, the result is indeed `x − y`.


Case 1, `x ≥ y`:

`x − y` is computed like so:

      x + (2^32 − y)
    = 2^32 + (x − y)

Since `x ≥ y`, we know that `x − y` is a positive number.
So, the  leftmost bit  of the result  is an overflow  bit, corresponding  to the
power `2^32`, but this bit can be discarded, giving the correct result `x − y`.

If `x <  y`, the result fits  in 32 bits with  no overflow bit, and  we have the
desired  result, since  it  represents the  negative  value `−(y  −  x)` in  2's
complement.


Case 2, `x < y`:

`x − y` is computed like so:

      x + (2^32 − y)
    = 2^32 − (y − x)

Since `x < y`, we know that `y − x` is a positive number.
So, the  result fits in 32  bits with no overflow  bit, and we have  the desired
result, since it represents the negative value `−(y − x)` in 2's complement.


This demonstrates  an important  property of  2's complement  representation: no
special hardware is needed for integer subtraction.
The  addition hardware  can  be used  once  the negative  number  `-y` has  been
represented using 2's complement.
