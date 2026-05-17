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

##
# Table of conversion specifiers for `printf()`
## integer types

    ┌──────────────────────────┬──────────┬─────────────────┬───────────┬────────────┐
    │ name                     │ constant │ printf()        │ min       │ max        │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ (signed) char            │ ∅        │ %c | %hh[dioxX] │ SCHAR_MIN │ SCHAR_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ (signed) short (int)     │ ∅        │ %h[dioxX]       │ SHRT_MIN  │ SHRT_MAX   │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ (signed) (int)           │ ∅        │ %[dioxX]        │ INT_MIN   │ INT_MAX    │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ (signed) long (int)      │ L        │ %l[dioxX]       │ LONG_MIN  │ LONG_MAX   │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ (signed) long long (int) │ LL       │ %ll[dioxX]      │ LLONG_MIN │ LLONG_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ unsigned char            │ U        │ %c | %hhu       │ 0         │ UCHAR_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ unsigned short (int)     │ U        │ %hu             │ 0         │ USHRT_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ unsigned (int)           │ U        │ %u              │ 0         │ UINT_MAX   │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ unsigned long (int)      │ UL       │ %lu             │ 0         │ ULONG_MAX  │
    ├──────────────────────────┼──────────┼─────────────────┼───────────┼────────────┤
    │ unsigned long long (int) │ ULL      │ %llu            │ 0         │ ULLONG_MAX │
    └──────────────────────────┴──────────┴─────────────────┴───────────┴────────────┘

To get  the actual  value, `#include <limits.h>`,  then `printf()`  the variable
with the appropriate conversion specification.

---

Note that  there are  only 3 basic  conversion specification:  `%c`, `%[dioxX]`,
`%u`.  But there  are also modifiers: `hh`,  `h`, `l`, `ll` (they  only apply to
`%[dioxX]` and  `%u`, not `%c`).  That's  why there appears more  entries in the
table.

---

There is one extra specifier: `%p` for pointers.
Not sure how it fits in the table though.

---

In ascending amount of space used:

   - char
   - short
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

## floating-point types

    ┌─────────────┬──────────┬──────────────┬──────────┬──────────┐
    │ name        │ constant │ printf()     │ min      │ max      │
    ├─────────────┼──────────┼──────────────┼──────────┼──────────┤
    │ float       │ [fF]     │ %[eEfFgGaA]  │ FLT_MIN  │ FLT_MAX  │
    ├─────────────┼──────────┼──────────────┼──────────┼──────────┤
    │ double      │ ∅        │ %[eEfFgGaA]  │ DBL_MIN  │ DBL_MAX  │
    ├─────────────┼──────────┼──────────────┼──────────┼──────────┤
    │ long double │ [lL]     │ %L[eEfFgGaA] │ LDBL_MIN │ LDBL_MAX │
    └─────────────┴──────────┴──────────────┴──────────┴──────────┘

To get the actual value, `#include <float.h>`, then `printf()` the variable with
the appropriate conversion specification (`%e`, or `%Le` for `*_MIN`; not `%f`).

---

`%[aA]` is for hexadecimal notation.

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
# Table of `printf()` flags

    ┌───────┬──────────────────────────────────────────────────────────────────────────────┐
    │ -     │ the item is left-justified (example: `%-20s`)                                │
    ├───────┼──────────────────────────────────────────────────────────────────────────────┤
    │ +     │ signed values  are displayed  with a  plus sign, if  positive, and  with a   │
    │       │ minus sign if negative (example: `%+6.2f`)                                   │
    ├───────┼──────────────────────────────────────────────────────────────────────────────┤
    │ space │ signed  values  are  displayed  with  a  leading  space  (but  no  sign)  if │
    │       │ positive, and with  a minus sign if  negative; a `+` flag  overrides a space │
    │       │ (example: `% 6.2f`)                                                          │
    ├───────┼──────────────────────────────────────────────────────────────────────────────┤
    │ #     │ Use  an alternative  form  for the  conversion  specification.  Produces  an │
    │       │ initial `0`  for the  `%o` form  and an initial  `0x` or  `0X` for  the `%x` │
    │       │ or  `%X`  form.   For  all  floating-point  forms,  `#`  guarantees  that  a │
    │       │ decimal-point character is printed, even if  no digits follow.  For `%g` and │
    │       │ `%G` forms, it prevents trailing zeros from being removed. (examples: `%#o`, │
    │       │ `%#8.0f`, `%+#10.3E`)                                                        │
    ├───────┼──────────────────────────────────────────────────────────────────────────────┤
    │ 0     │ For numeric  forms, pad the field  width with leading zeros  instead of with │
    │       │ spaces.  This flag is ignored if a `-` flag is present or if, for an integer │
    │       │ form, a precision is specified. (examples: `%010d` and `%08.3f`)             │
    └───────┴──────────────────────────────────────────────────────────────────────────────┘

# Table of `printf()` modifiers

    ┌────┬──────────────────────────────────────────────────────────────────────────────┐
    │ h  │ used  with an  integer conversion  specifier  to indicate  a `short int`  or │
    │    │ `unsigned short int` value (examples: `%hu`, `%hx`, `%6.4hd`)                │
    ├────┼──────────────────────────────────────────────────────────────────────────────┤
    │ hh │ used with  an integer conversion  specifier to  indicate a signed  `char` or │
    │    │ `unsigned char` value (examples: `%hhu`, `%hhx`, `%6.4hhd`)                  │
    ├────┼──────────────────────────────────────────────────────────────────────────────┤
    │ j  │ used  with an  integer conversion  specifier  to indicate  an `intmax_t`  or │
    │    │ `uintmax_t` value;  these are types  defined in `stdint.h`  (examples: `%jd` │
    │    │ and `%8jX`)                                                                  │
    ├────┼──────────────────────────────────────────────────────────────────────────────┤
    │ l  │ used  with an  integer  conversion  specifier to  indicate  a `long int`  or │
    │    │ `unsigned long int` (examples: `%ld` and `%8lu`)                             │
    ├────┼──────────────────────────────────────────────────────────────────────────────┤
    │ ll │ used with an  integer conversion specifier to indicate  a `long long int` or │
    │    │ `unsigned long long int` (examples: `%lld` and `%8llu`)                      │
    ├────┼──────────────────────────────────────────────────────────────────────────────┤
    │ L  │ used with a floating-point conversion  specifier to indicate a `long double` │
    │    │ value (examples: `%Lf` and `%10.4Le`)                                        │
    ├────┼──────────────────────────────────────────────────────────────────────────────┤
    │ t  │ used with an  integer conversion specifier to indicate  a `ptrdiff_t` value; │
    │    │ this  is the  type  corresponding  to the  difference  between two  pointers │
    │    │ (examples: `%td` and `%12ti`)                                                │
    ├────┼──────────────────────────────────────────────────────────────────────────────┤
    │ z  │ used with an integer conversion specifier to indicate a `size_t` value; this │
    │    │ is the type returned by `sizeof()` (examples: `%zd` and `%12zx`)             │
    └────┴──────────────────────────────────────────────────────────────────────────────┘

##
# Table of conversion specifiers for `scanf()`

    ┌─────────────┬───────────────────────────────────────────────────────────────────────────┐
    │ %c          │ character                                                                 │
    ├─────────────┼───────────────────────────────────────────────────────────────────────────┤
    │ %[di]       │ signed decimal integer                                                    │
    ├─────────────┼───────────────────────────────────────────────────────────────────────────┤
    │ %o          │ signed octal integer                                                      │
    ├─────────────┼───────────────────────────────────────────────────────────────────────────┤
    │ %[xX]       │ signed hexadecimal integer                                                │
    ├─────────────┼───────────────────────────────────────────────────────────────────────────┤
    │ %u          │ unsigned decimal integer                                                  │
    ├─────────────┼───────────────────────────────────────────────────────────────────────────┤
    │ %[efgaEFGA] │ floating-point number                                                     │
    ├─────────────┼───────────────────────────────────────────────────────────────────────────┤
    │ %p          │ pointer                                                                   │
    ├─────────────┼───────────────────────────────────────────────────────────────────────────┤
    │ %s          │ string; input begins with the first non-whitespace character and includes │
    │             │ everything up to the next whitespace character                            │
    └─────────────┴───────────────────────────────────────────────────────────────────────────┘

---

If the format includes a whitespace, `scanf()` skips over consecutive whitespace
in the input.  The only exception to this is `%c`: `scanf()` reads the very next
character, even if  that character is whitespace.  But there  is a special case:
` %c` (notice the space before `%c`) reads the first non-whitespace.

---

`scanf()` automatically skips  over whitespace when trying to match  a `%` item.
So, there's  no need to include  a whitespace in front  of a `%` item.   OTOH, a
whitespace  in front  of a  non-`%`  item is  significant (e.g.  ` ,`); it  lets
`scanf()` skips over whitespace before matching the non-whitespace (`,`).

---

Note  that `printf()`  uses `%[feEgG]`  for `float`  *and* `double`  types.  But
`scanf()` uses them  just for `float`, requiring the `l`  modifier for `double`.
So, for example, for a `double`, you  would write `%f` with `printf()`, but `lf`
with `scanf()`.

# Table of `scanf()` modifiers

    ┌──────────┬───────────────────────────────────────────────────────────────────────────────────────────┐
    │ *        │ suppress assignment; skip over input (example: "%*d")                                     │
    ├──────────┼───────────────────────────────────────────────────────────────────────────────────────────┤
    │ digit(s) │ Maximum field width.  Input stops when the maximum field width is reached or              │
    │          │ when the first  whitespace character is encountered,  whichever comes first.              │
    │          │ (example: "%10s")                                                                         │
    ├──────────┼───────────────────────────────────────────────────────────────────────────────────────────┤
    │ [hlL]    │ %hh[di] = signed char                                                                     │
    │          │ %h[di] = short int                                                                        │
    │          │ %[diox] = int                                                                             │
    │          │ %l[di] = long                                                                             │
    │          │ %ll[di] = long long                                                                       │
    │          │ %hhu = unsigned char                                                                      │
    │          │ %h[oxu] = unsigned short int                                                              │
    │          │ %[oxu] = unsigned int                                                                     │
    │          │ %l[oxu] = unsigned long                                                                   │
    │          │ %ll[oxu] = unsigned long long                                                             │
    │          │ %[efg] = float                                                                            │
    │          │ %l[efg] = double                                                                          │
    │          │ %L[efg] = long double                                                                     │
    ├──────────┼───────────────────────────────────────────────────────────────────────────────────────────┤
    │ j        │ when followed by an integer specifier, indicates using the `intmax_t` or `uintmax_t` type │
    │          │ (examples: "%jd", "%ju")                                                                  │
    ├──────────┼───────────────────────────────────────────────────────────────────────────────────────────┤
    │ z        │ when followed by an integer specifier, indicates using the type returned by `sizeof()`    │
    │          │ (examples: "%zd", "%zo")                                                                  │
    ├──────────┼───────────────────────────────────────────────────────────────────────────────────────────┤
    │ t        │ when followed by an integer specifier, indicates using the type used to represent the     │
    │          │ difference between two pointers (examples: "%td", "%tx")                                  │
    └──────────┴───────────────────────────────────────────────────────────────────────────────────────────┘

##
# Type conversion rules
## promotion

   1.  When appearing in an expression, `char` and `short`, both `signed` and
       `unsigned`, are automatically converted to `int` or, if necessary, to
       `unsigned int`.  (If `short` is the same size as `int`, `unsigned short`
       is larger than `int`; in that case, `unsigned short` is converted to
       `unsigned int`.) Under K&R C, but not under current C, `float` is
       automatically converted to `double`.  Because they are conversions to
       larger types, they are called **promotions**.

   2. In any operation involving two types, both values are converted to the
      higher ranking of the two types.

   3. The ranking of types, from highest to lowest, is:

        - `long double`
        - `double`
        - `float`
        - `unsigned long long`
        - `long long`
        - `unsigned long`
        - `long`
        - `unsigned int`
        - `int`

      One possible  exception is  when `long`  and `int` are  the same  size, in
      which case `unsigned int` outranks `long`. `short` and `char` don't appear
      in this  list because they  would have been  already promoted to  `int` or
      perhaps `unsigned int`.

   4. In an assignment statement, the final result of the calculations is
      converted to the type of the variable being assigned a value.  This
      process can result in promotion, as described in rule 1, or demotion, in
      which a value is converted to a lower-ranking type.

   5. When passed as function arguments, `char` and `short` are converted to
      `int`, and `float` is converted to `double`.  This automatic promotion is
      overridden by function prototyping.

## demotion

Here are the rules for when the  assigned value doesn't fit into the destination
type:

   1. When the destination is some form of unsigned integer (any kind; e.g.
      `unsigned long`) and the assigned value is an integer (any kind; e.g.
      `long long`), the extra bits that make the value too big are ignored.  For
      instance, if the destination is 8-bit `unsigned char`, the assigned value
      is the original value modulus 256.

   2. If the destination type is a signed integer (e.g. `long`) and the assigned
      value is an integer (e.g. `long long`), the result is
      implementation-dependent.

   3. If the destination type is an integer and the assigned value is floating
      point, the behavior is undefined (if the float value's integral part
      overflows the integer type's range).

---

When floating types are demoted to integer types, they are truncated, or rounded
toward zero.  That means 23.12 and 23.99 both are truncated to 23 and that -23.5
is truncated to -23.

##
# The `ctype.h` character-testing functions

    ┌────────────┬──────────────────────────────────────────────────────────────────────┐
    │ Name       │ True If the Argument Is                                              │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ isalnum()  │ alphanumeric (alphabetic or numeric)                                 │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ isalpha()  │ alphabetic                                                           │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ isblank()  │ a standard blank character (space, horizontal tab, or newline)       │
    │            │ or any additional locale-specific character so specified             │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ iscntrl()  │ a control character, such as Ctrl+B                                  │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ isdigit()  │ a digit                                                              │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ isgraph()  │ any printing character other than a space                            │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ islower()  │ a lowercase character                                                │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ isprint()  │ a printing character                                                 │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ ispunct()  │ a punctuation character (any printing character other than a space   │
    │            │ or an alphanumeric character)                                        │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ isspace()  │ a whitespace character (a space, newline, formfeed, carriage return, │
    │            │ vertical tab, horizontal tab, or, possibly, other locale-defined     │
    │            │ character                                                            │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ isupper()  │ an uppercase character                                               │
    ├────────────┼──────────────────────────────────────────────────────────────────────┤
    │ isxdigit() │ a hexadecimal-digit character                                        │
    └────────────┴──────────────────────────────────────────────────────────────────────┘

    ┌───────────┬──────────────────────────────────────────────────────────────────────┐
    │ Name      │ Action                                                               │
    ├───────────┼──────────────────────────────────────────────────────────────────────┤
    │ tolower() │ If the argument is an uppercase character, this function returns the │
    │           │ lowercase version; otherwise, it just returns the original argument. │
    ├───────────┼──────────────────────────────────────────────────────────────────────┤
    │ toupper() │ If the argument is an lowercase character, this function returns the │
    │           │ uppercase version; otherwise, it just returns the original argument. │
    └───────────┴──────────────────────────────────────────────────────────────────────┘

# Alternative Representations of Logical Operators

    ┌─────────────┬──────────┐
    │ Traditional │ iso646.h │
    ├─────────────┼──────────┤
    │ &&          │ and      │
    ├─────────────┼──────────┤
    │ &=          │ and_eq   │
    ├─────────────┼──────────┤
    │ &           │ bitand   │
    ├─────────────┼──────────┤
    │ |           │ bitor    │
    ├─────────────┼──────────┤
    │ ~           │ compl    │
    ├─────────────┼──────────┤
    │ !           │ not      │
    ├─────────────┼──────────┤
    │ !=          │ not_eq   │
    ├─────────────┼──────────┤
    │ ||          │ or       │
    ├─────────────┼──────────┤
    │ |=          │ or_eq    │
    ├─────────────┼──────────┤
    │ ^           │ xor      │
    ├─────────────┼──────────┤
    │ ^=          │ xor_eq   │
    └─────────────┴──────────┘

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

These types could be bigger  than `long long` and `unsigned long long` because C
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

##
# List of basic operations that can be performed with or on pointer variables

   - Assignment.  The assigned value can be an array name, a variable preceded by
     address operator (`&`), or another second pointer

   - Value finding (aka dereferencing).  The `*` operator gives the value stored
     in the pointed-to location

   - Taking a pointer address.  Like all variables, a pointer variable has an
     address and a value.  The `&` operator tells you where the pointer itself
     is stored.

   - Adding an integer to a pointer.  You can use the `+` operator to add an
     integer to a pointer.  The integer is multiplied by the number of bytes in
     the pointed-to type, and the result is added to the original address. This
     makes `ptr + 4` the same as `&array[4]`.

   - Incrementing a pointer.  Incrementing a pointer to an array element makes
     it move to the next element of the array.

   - Subtracting an integer from a pointer.  You can use the `-` operator to
     subtract an integer from a pointer.  The integer is multiplied by the
     number of bytes in the pointed-to type, and the result is subtracted from
     the original address.  If `ptr` points to `&array[5]`, this makes `ptr - 2`
     the same as `&array[3]`.

   - Decrementing a pointer.  Decrementing a pointer to an array element makes
     it move to the previous element of the array.

   - Differencing.  You can find the difference between two pointers.  Normally,
     you do this for two pointers to elements that are in the same array to find
     out how far apart they are.  The result is in the same units as the type
     size.  For example, if `ptr1` points to `array[2]` and `ptr2` points to
     `array[5]`, then `ptr2 - ptr1` is 3 (`5 - 2`), meaning that these pointers
     point to objects separated by two elements, not by 3 bytes.

   - Comparisons.  You can use the relational operators to compare the values of
     two pointers, provided the pointers are of the same type.

##
# Array syntaxes

    ┌──────────────────────────────────────────────────┬────────────────────────────────────────────────────┐
    │ int array[123] = {...};                          │ declare array of integers                          │
    │ int array[] = {...};                             │                                                    │
    │                                                  │                                                    │
    │ int array[123];                                  │                                                    │
    │ for (i = 0; i < 123; i++)                        │                                                    │
    │     array[i] = ...;                              │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ sizeof(array) / sizeof(array[0])                 │ get number of elements in array                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ int array[12] = {[3] = 4};                       │ initialize given element of array                  │
    │ int array[] = {[3] = 4};                         │ (aka designated initializer)                       │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ int array[12][34] = {{...}};                     │ declare 2-dimensional array of integers            │
    │ int array[12][34] = {...};                       │                                                    │
    │ int array[][34] = {{...}};                       │                                                    │
    │ int array[][34] = {...};                         │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ int * ptr;                                       │ assign array to pointer variable                   │
    │ int array[] = {...};                             │                                                    │
    │ ptr = array;                                     │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ int (*ptr)[subarray size];                       │ assign 2-dimensional array to pointer variable     │
    │ array = {{...}};                                 │                                                    │
    │ ptr = array;                                     │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ array                                            │ address of first element of array                  │
    │ &array[0]                                        │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ array                                            │ address of first element of array of arrays        │
    │ array[0]                                         │                                                    │
    │ &array[0][0]                                     │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ array + N - 1                                    │ address of N-th element out of array               │
    │ &array[N - 1]                                    │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ *array + N - 1                                   │ address of N-th sub-element out of array of arrays │
    │                                                  │ (across subarrays)                                 │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ *(array + N - 1)                                 │ N-th element out of array                          │
    │ array[N - 1]                                     │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ array[i][j]                                      │ j-th element out of i-th subarray                  │
    │ *(*(array + i) + j)                              │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ func(const int * array, ...)                     │ prevent function from modifying array              │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ const int * ptr = array;                         │ declare pointer to constant array                  │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ int * const ptr = array;                         │ declare constant pointer                           │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ const int * const ptr = array;                   │ declare constant pointer-to-constant               │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ func(int *, int);                                │ declare function accepting array as argument       │
    │ func(int [], int);                               │                                                    │
    │ func(int * array, int rows)                      │                                                    │
    │ func(int array[], int rows)                      │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ func(int (*)[COLS], int);                        │ declare function accepting 2-dimensional           │
    │ func(int [][COLS], int);                         │ array as argument                                  │
    │ func(int (*ptr)[COLS], int rows)                 │                                                    │
    │ func(int ptr[][COLS], int rows)                  │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ int rows = ...;                                  │ declare VLA                                        │
    │ int cols = ...;                                  │                                                    │
    │ int array[rows][cols];                           │                                                    │
    │ for (r = 0; r < rows; rows++)                    │ assign VLA                                         │
    │      for (c = 0; c < cols; cols++)               │                                                    │
    │          array[r][c] = ...;                      │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ func(int, int, int [*][*]);                      │ (prototype) pass VLA as function's argument        │
    │ func(int rows, int cols, int array[rows][cols]); │                                                    │
    │                                                  │                                                    │
    │ func(int rows, int cols, int array[rows][cols])  │ (declaration)                                      │
    │ func(12, 34, array)                              │ (call)                                             │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ (int [123]){...}                                 │ one-dimensional compound literal                   │
    │ (int []){...}                                    │                                                    │
    ├──────────────────────────────────────────────────┼────────────────────────────────────────────────────┤
    │ (int [12][34][56]){...}                          │ three-dimensional compound literal                 │
    │ (int [][34][56]){...}                            │                                                    │
    └──────────────────────────────────────────────────┴────────────────────────────────────────────────────┘

This table  assumes that the arrays  contain `int`s.  Obviously, in  the general
case, they could contain any other type (e.g. `char`, `double`, ...).

Also, you can  represent individual elements by using array  notation or pointer
notation with either an array name or a pointer:

    array[m][n] == *(*(array + m) + n)
    ptr[m][n] == *(*(ptr + m) + n)

# String syntaxes

    ┌──────────────────────────────────────────┬──────────────────────────────────────────────────┐
    │ char array[] = "some string";            │ declare a string                                 │
    │ const char * ptr = "some string";        │                                                  │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ const char *array[number of strings] = { │ declare an array of pointers to strings          │
    │     "some string",                       │                                                  │
    │     ...                                  │                                                  │
    │ };                                       │                                                  │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ char array[number of strings]            │ declare an array of strings                      │
    │           [longest string length] = {    │                                                  │
    │     "some string",                       │                                                  │
    │     ...                                  │                                                  │
    │ };                                       │                                                  │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strlen(string)                           │ get length of string                             │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ puts(string);                            │ put a string; `string` can be:                   │
    │                                          │                                                  │
    │                                          │ - a literal constant: "..."                      │
    │                                          │ - a symbolic constant: #define STR "..."         │
    │                                          │ - a string in an array: char str[123]            │
    │                                          │ - a pointer to a string: const char * str        │
    │                                          │ - the address of a string character: &str[3]     │
    │                                          │ - pointer arithmetic with a string: str + 3      │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ char array[N];                           │ read a word                                      │
    │ scanf("%Ns", array);                     │                                                  │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ char array[N];                           │ read input up to N-1 characters or the newline,  │
    │ fgets(array, N, stdin);                  │ whichever comes first, into array (-1 for null); │
    │                                          │ when passed as an argument, array decays into a  │
    │                                          │ pointer to its first element (here `char *`);    │
    │                                          │ the return type is `char *`                      │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ char array[N] = "...";                   │ display contents of string in array              │
    │ fputs(array, stdout);                    │                                                  │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strcat(string1, string2);                │ concatenate 2 strings                            │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strncat(string1, string2, N);            │ concatenate 2 strings adding string2 to string1  │
    │                                          │ stopping when reaching N additional characters   │
    │                                          │ or the null character, whichever comes first;    │
    │                                          │ make sure N is greater or equal to:              │
    │                                          │ (declared size of string1) - strlen(string1) - 1 │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strcmp(string1, string2);                │ compare whether 2 strings are the same           │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strncmp(string1, string2, N);            │ compare strings until they differ or until       │
    │                                          │ a given number of characters                     │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strcpy(destination, source);             │ copy a source string to a destination string;    │
    │                                          │ make sure: strlen(destination) >= strlen(source) │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strcpy(destination + N-1, replacement);  │ replace part of string, from N-th character till │
    │                                          │ the end; make sure: N <= strlen(destination)     │
    │                                          │ && strlen(destination) - N >= strlen(replacement)│
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ char destination[N];                     │ copy a source string to a destination string,    │
    │ strncpy(destination, source, N - 1);     │ up to N characters or the null character,        │
    │ destination[N - 1] = '\0';               │ whichever comes first                            │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ sprintf(var, "format", expressions);     │ printf()-like function writing to a string       │
    │                                          │ variable rather than display                     │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strchr(string, N);                       │ get pointer to first location in string holding  │
    │ strchr(string, 'character');             │ given character; N is the integer value of the   │
    │                                          │ searched character as given by:                  │
    │                                          │ `printf("%d", 'character');`                     │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strpbrk(string1, string2);               │ get pointer to first location in string1 that    │
    │                                          │ holds any character in string2                   │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strrchr(string, N);                      │ get pointer to last location of given character  │
    │ strrchr(string, 'character');            │ in given string                                  │
    ├──────────────────────────────────────────┼──────────────────────────────────────────────────┤
    │ strstr(string1, string2);                │ get pointer to first occurrence of string2 in    │
    │                                          │ string1                                          │
    └──────────────────────────────────────────┴──────────────────────────────────────────────────┘

In these syntaxes,  you can replace `char array[N]` with  `char * ptr`, but only
if `ptr` was assigned an array with  a given size.  No matter what, the compiler
has to know in advance the size of a string.
