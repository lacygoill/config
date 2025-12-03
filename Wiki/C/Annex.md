# Table of (some) operators in descending order of precedence

    ┌───────────┬────────────────────────────┬─────────────────────────┐
    │ Symbol(s) │ Name                       │ Associativity           │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ []        │ Array subscripting         │ Left                    │
    │ ()        │ Function call              │ Left                    │
    │ .  ->     │ Structure and union member │ Left                    │
    │ ++        │ Increment postfix          │ Left                    │
    │ --        │ Decrement postfix          │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ++        │ Increment prefix           │ Right                   │
    │ --        │ Decrement prefix           │ Right                   │
    │ &         │ Address                    │ Right                   │
    │ *         │ Indirection                │ Right                   │
    │ +         │ Unary plus                 │ Right                   │
    │ -         │ Unary minus                │ Right                   │
    │ ~         │ Bitwise complement         │ Right                   │
    │ !         │ Logical negation           │ Right                   │
    │ sizeof    │ Size                       │ Right                   │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ()        │ Cast                       │ Right                   │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ * / %     │ Multiplicative             │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ + -       │ Additive                   │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ <<  >>    │ Bitwise shift              │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ < > <= >= │ Relational                 │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ == !=     │ Equality                   │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ &         │ Bitwise and                │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ^         │ Bitwise exclusive or       │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ |         │ Bitwise inclusive or       │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ &&        │ Logical and                │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ||        │ Logical or                 │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ?:        │ Conditional                │ Right                   │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ =  *= /=  │ Assignment                 │ Right                   │
    │ %= += -=  │                            │                         │
    │ <<= >>=   │                            │                         │
    │ &= ^= |=  │                            │                         │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ,         │ Comma                      │ Left                    │
    └───────────┴────────────────────────────┴─────────────────────────┘

Operators in the same cell have the same precedence.
If you have several operators of  equal precedence adjacent to the same operand,
you need to know  another one of their property to  determine how the operations
will be grouped: their associativity.

# Table of integer types

    ┌──────────────────────────┬──────────┬─────────────────┬──────────────┬───────────┬────────────┐
    │ name                     │ constant │ printf()        │ scanf()      │ min       │ max        │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ (signed) char            │ ∅        │ %c | %hh[dixXo] │ %c | %hh[di] │ SCHAR_MIN │ SCHAR_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ (signed) short (int)     │ ∅        │ %[#]h[dixXo]    │ %h[di]       │ SHRT_MIN  │ SHRT_MAX   │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ (signed) (int)           │ ∅        │ %[#][dixXo]     │ %[di]        │ INT_MIN   │ INT_MAX    │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ (signed) long (int)      │ L        │ %[#]l[dixXo]    │ %l[di]       │ LONG_MIN  │ LONG_MAX   │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ (signed) long long (int) │ LL       │ %[#]ll[dixXo]   │ %ll[di]      │ LLONG_MIN │ LLONG_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ unsigned char            │ U        │ %c | %hhu       │ %c | %hhu    │ 0         │ UCHAR_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ unsigned short (int)     │ U        │ %hu             │ %hu          │ 0         │ USHRT_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ unsigned (int)           │ U        │ %u              │ %u           │ 0         │ UINT_MAX   │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ unsigned long (int)      │ UL       │ %lu             │ %lu          │ 0         │ ULONG_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼──────────────┼───────────┼────────────┤
    │ unsigned long long (int) │ ULL      │ %llu            │ %llu         │ 0         │ ULLONG_MAX │
    └──────────────────────────┴──────────┴─────────────────┴──────────────┴───────────┴────────────┘

To get  the actual  value, `#include <limits.h>`,  then `printf()`  the variable
with the appropriate conversion specification.

---

In ascending amount of space used:

   - char
   - short int
   - int
   - long
   - long long

In  principle, these  five types  could represent  five distinct  sizes, but  in
practice at least some of the types normally overlap.

---

When you write  an integer constant, it  is stored as the first  possible of (in
that order):

   - int
   - long int
   - unsigned long
   - long long
   - unsigned long long

# Table of floating-point types

    ┌─────────────┬──────────┬──────────────┬──────────────┬──────────┬──────────┐
    │ name        │ constant │ printf()     │ scanf()      │ min      │ max      │
    ├─────────────┼──────────┼──────────────┼──────────────┼──────────┼──────────┤
    │ float       │ [fF]     │ %[eEfFgGaA]  │ %[eEfFgGaA]  │ FLT_MIN  │ FLT_MAX  │
    ├─────────────┼──────────┼──────────────┼──────────────┼──────────┼──────────┤
    │ double      │ ∅        │ %[eEfFgGaA]  │ %l[eEfFgGaA] │ DBL_MIN  │ DBL_MAX  │
    ├─────────────┼──────────┼──────────────┼──────────────┼──────────┼──────────┤
    │ long double │ [lL]     │ %L[eEfFgGaA] │ %L[eEfFgGaA] │ LDBL_MIN │ LDBL_MAX │
    └─────────────┴──────────┴──────────────┴──────────────┴──────────┴──────────┘

To get the actual value, `#include <float.h>`, then `printf()` the variable with
the appropriate conversion specification (`%e`, or `%Le` for `*_MIN`; not `%f`).

`%La` is for hexadecimal notation.

---

`float.h` provides more symbolic constants:

    ┌────────────────┬─────────────────────────────────────────────────────────────────────┐
    │ FLT_MANT_DIG   │ number of bits in the mantissa of a float                           │
    ├────────────────┼─────────────────────────────────────────────────────────────────────┤
    │ FLT_DIG        │ minimum number of significant decimal digits for a float            │
    ├────────────────┼─────────────────────────────────────────────────────────────────────┤
    │ FLT_MIN_10_EXP │ minimum base-10 negative exponent for a float                       │
    │                │ with a full set of significant figures                              │
    ├────────────────┼─────────────────────────────────────────────────────────────────────┤
    │ FLT_MAX_10_EXP │ maximum base-10 positive exponent for a float                       │
    ├────────────────┼─────────────────────────────────────────────────────────────────────┤
    │ FLT_EPSILON    │ difference between 1.00 and the least float value greater than 1.00 │
    └────────────────┴─────────────────────────────────────────────────────────────────────┘

Additional  constants  exist  for  `double`   (replace  `FLT`  with  `DBL`)  and
`long double` (replace `FLT` with `LDBL`).

##
# Portable types
## Table of portable exact-width types

These  are aliases  describing properties  of types  more clearly  than standard
names.  For example, type  `int` might be 16 bits, 32 bits, or  64 bits, but the
`int32_t` type is always exactly 32 bits.

The `inttypes.h` header file defines macros  that can be used with `scanf()` and
`printf()` to read and write integers of  these types (they are strings that can
be  concatenated with  other strings  to produce  the proper  format).  It  also
provides the  actual type  definitions using `typedef`.   For example,  a system
with a 32-bit `int` might use this definition:

    typedef int int32_t;

The format specifiers are defined using the `#define` directive.  For example, a
system using the previous definition for `int32_t` might have this definition:

    #define PRId32 "d"  // output specifier
    #define SCNd32 "d"  // input specifier

Using these definitions, you could declare an extended integer variable, input a
value, and display it as follows:

    int32_t cd_sales; // 32-bit integer
    scanf("%" SCNd32, &cd_sales);
    printf("CD sales = %10" PRId32 " units\n", cd_sales);

String concatenation then combines strings, if  needed, to get the final format.
Thus, the previous code gets converted to the following:

    int cd_sales; // 32-bit integer
    scanf("%d", &cd_sales);
    printf("CD sales = %10d units\n", cd_sales);

If you moved the original code to a  system with a 16-bit int, that system might
define `int32_t` as `long`, `PRId32` as `"ld"`, and `SCNd32` as `"ld"`.  But you
could use the same code, knowing that it uses a 32-bit integer.

    ┌──────────┬──────────┬─────────┬───────────┬────────────┐
    │ name     │ printf() │ scanf() │ min       │ max        │
    ├──────────┼──────────┼─────────┼───────────┼────────────┤
    │ int8_t   │ PRId8    │ SCNd8   │ INT8_MIN  │ INT8_MAX   │
    ├──────────┼──────────┼─────────┼───────────┼────────────┤
    │ int16_t  │ PRId16   │ SCNd16  │ INT16_MIN │ INT16_MAX  │
    ├──────────┼──────────┼─────────┼───────────┼────────────┤
    │ int32_t  │ PRId32   │ SCNd32  │ INT32_MIN │ INT32_MAX  │
    ├──────────┼──────────┼─────────┼───────────┼────────────┤
    │ int64_t  │ PRId64   │ SCNd64  │ INT64_MIN │ INT64_MAX  │
    ├──────────┼──────────┼─────────┼───────────┼────────────┤
    │ uint8_t  │ PRIu8    │ SCNu8   │ 0         │ UINT8_MAX  │
    ├──────────┼──────────┼─────────┼───────────┼────────────┤
    │ uint16_t │ PRIu16   │ SCNu16  │ 0         │ UINT16_MAX │
    ├──────────┼──────────┼─────────┼───────────┼────────────┤
    │ uint32_t │ PRIu32   │ SCNu32  │ 0         │ UINT32_MAX │
    ├──────────┼──────────┼─────────┼───────────┼────────────┤
    │ uint64_t │ PRIu64   │ SCNu64  │ 0         │ UINT64_MAX │
    └──────────┴──────────┴─────────┴───────────┴────────────┘

Note:

   - PRI = print()
   - SCN = scan()

Also, for the unsigned  types, you can substitute `u` with `o`  or `x` to obtain
the `%o` or `%x`  specifier instead of `%u`.  For example,  you can use `PRIx32`
(instead of `PRIu32`) to print a `uint32_t` type value in hexadecimal format.

## Table of portable minimum-width types

The minimum-width types  guarantee a type that  is at least a  certain number of
bits in  size.  For example,  a system that does  not support 8-bit  units could
define `int_least8_t` as a 16-bit type.

    ┌────────────────┬─────────────┬─────────────┬─────────────────┬──────────────────┐
    │ name           │ printf()    │ scanf()     │ min             │ max              │
    ├────────────────┼─────────────┼─────────────┼─────────────────┼──────────────────┤
    │ int_least8_t   │ PRILEASTd8  │ SCNLEASTd8  │ INT_LEAST8_MIN  │ INT_LEAST8_MAX   │
    ├────────────────┼─────────────┼─────────────┼─────────────────┼──────────────────┤
    │ int_least16_t  │ PRILEASTd16 │ SCNLEASTd16 │ INT_LEAST16_MIN │ INT_LEAST16_MAX  │
    ├────────────────┼─────────────┼─────────────┼─────────────────┼──────────────────┤
    │ int_least32_t  │ PRILEASTd32 │ SCNLEASTd32 │ INT_LEAST32_MIN │ INT_LEAST32_MAX  │
    ├────────────────┼─────────────┼─────────────┼─────────────────┼──────────────────┤
    │ int_least64_t  │ PRILEASTd64 │ SCNLEASTd64 │ INT_LEAST64_MIN │ INT_LEAST64_MAX  │
    ├────────────────┼─────────────┼─────────────┼─────────────────┼──────────────────┤
    │ int_least64_t  │ PRILEASTd64 │ SCNLEASTd64 │ INT_LEAST64_MIN │ INT_LEAST64_MAX  │
    ├────────────────┼─────────────┼─────────────┼─────────────────┼──────────────────┤
    │ uint_least8_t  │ PRILEASTu8  │ SCNLEASTu8  │ 0               │ UINT_LEAST8_MAX  │
    ├────────────────┼─────────────┼─────────────┼─────────────────┼──────────────────┤
    │ uint_least16_t │ PRILEASTu16 │ SCNLEASTu16 │ 0               │ UINT_LEAST16_MAX │
    ├────────────────┼─────────────┼─────────────┼─────────────────┼──────────────────┤
    │ uint_least32_t │ PRILEASTu32 │ SCNLEASTu32 │ 0               │ UINT_LEAST32_MAX │
    ├────────────────┼─────────────┼─────────────┼─────────────────┼──────────────────┤
    │ uint_least64_t │ PRILEASTu64 │ SCNLEASTu64 │ 0               │ UINT_LEAST64_MAX │
    └────────────────┴─────────────┴─────────────┴─────────────────┴──────────────────┘

## Table of portable fastest minimum-width types

For a particular system, some integer representations can be faster than others.
For example, `int_least16_t` might be implemented as short, but the system might
do arithmetic faster using type `int`.  So `inttypes.h` also defines the fastest
type for representing at least a certain number of bits.

    ┌───────────────┬────────────┬────────────┬────────────────┬─────────────────┐
    │ name          │ printf()   │ scanf()    │ min            │ max             │
    ├───────────────┼────────────┼────────────┼────────────────┼─────────────────┤
    │ int_fast8_t   │ PRIFASTd8  │ SCNFASTd8  │ INT_FAST8_MIN  │ INT_FAST8_MAX   │
    ├───────────────┼────────────┼────────────┼────────────────┼─────────────────┤
    │ int_fast16_t  │ PRIFASTd16 │ SCNFASTd16 │ INT_FAST16_MIN │ INT_FAST16_MAX  │
    ├───────────────┼────────────┼────────────┼────────────────┼─────────────────┤
    │ int_fast32_t  │ PRIFASTd32 │ SCNFASTd32 │ INT_FAST32_MIN │ INT_FAST32_MAX  │
    ├───────────────┼────────────┼────────────┼────────────────┼─────────────────┤
    │ int_fast64_t  │ PRIFASTd64 │ SCNFASTd64 │ INT_FAST64_MIN │ INT_FAST64_MAX  │
    ├───────────────┼────────────┼────────────┼────────────────┼─────────────────┤
    │ uint_fast8_t  │ PRIFASTu8  │ SCNFASTu8  │ 0              │ UINT_FAST8_MAX  │
    ├───────────────┼────────────┼────────────┼────────────────┼─────────────────┤
    │ uint_fast16_t │ PRIFASTu16 │ SCNFASTu16 │ 0              │ UINT_FAST16_MAX │
    ├───────────────┼────────────┼────────────┼────────────────┼─────────────────┤
    │ uint_fast32_t │ PRIFASTu32 │ SCNFASTu32 │ 0              │ UINT_FAST32_MAX │
    ├───────────────┼────────────┼────────────┼────────────────┼─────────────────┤
    │ uint_fast64_t │ PRIFASTu64 │ SCNFASTu64 │ 0              │ UINT_FAST64_MAX │
    └───────────────┴────────────┴────────────┴────────────────┴─────────────────┘

## Table of portable maximum-width types

Sometimes you may want the largest integer type available.

    ┌───────────┬──────────┬─────────┬────────────┬─────────────┐
    │ name      │ printf() │ scanf() │ min        │ max         │
    ├───────────┼──────────┼─────────┼────────────┼─────────────┤
    │ intmax_t  │ PRIdMAX  │ SCNdMAX │ INTMAX_MIN │ INTMAX_MAX  │
    ├───────────┼──────────┼─────────┼────────────┼─────────────┤
    │ uintmax_t │ PRIuMAX  │ SCNuMAX │ 0          │ UINTMAX_MAX │
    └───────────┴──────────┴─────────┴────────────┴─────────────┘

These  types could  be bigger  than  `long long` and  `unsigned long` because  C
implementations are permitted to define types beyond the required ones.

## Integers that can hold pointer values

    ┌───────────┬──────────┬─────────┬────────────┬─────────────┐
    │ name      │ printf() │ scanf() │ min        │ max         │
    ├───────────┼──────────┼─────────┼────────────┼─────────────┤
    │ intptr_t  │ PRIdPTR  │ SCNdPTR │ INTPTR_MIN │ INTPTR_MAX  │
    ├───────────┼──────────┼─────────┼────────────┼─────────────┤
    │ uintptr_t │ PRIuPTR  │ SCNuPTR │ 0          │ UINTPTR_MAX │
    └───────────┴──────────┴─────────┴────────────┴─────────────┘

## Extended Integer Constants

You can indicate a long constant with the `L` suffix, as in `445566L`.

Q: How do you indicate that a constant is type `int32_t`?

A: Use   macros  defined   in   `inttypes.h`.   For   example,  the   expression
`INT32_C(445566)` expands to a type  `int32_t` constant.  Essentially, the macro
is a type cast to the underlying type  — that is, to the fundamental type that
represents `int32_t` in a particular implementation.  The macro names are formed
by  taking the  type name,  replacing the  `_t` with  `_C`, and  making all  the
letters  uppercase.   For  example,  to  make  `1000`  a  type  `uint_least64_t`
constant, use the expression `UINT_LEAST64_C(1000)`.
