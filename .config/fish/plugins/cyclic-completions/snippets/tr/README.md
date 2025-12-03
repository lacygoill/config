# In `SET1` and `SET2`, most characters stand for themselves.

The only special characters are `[`, `]`, `*`, `-`, and `\`:

   - `[` and `]` are used for character classes, or repeated characters
     (e.g. `[C*123]`)

   - `*` is used for repeated characters
   - `-` is used for ranges

   - `\` is used in a few accepted escape sequences like `\b`, `\n`,
     `\r`, `\t`, `\123` (character by octal ASCII value) and `\\`; also
     it can suppress the special meaning of a character

# The syntax for a range is `M-N`.

Where `M` and `N`  are 2 arbitrary characters such that  `M` collate before `N`.
Note the absence of square brackets; `[a-c]` expands to the characters `[`, `a`,
`b`, `c` `]`.

# The syntax for a class is `[:class:]`; `tr(1)` supports these classes:

   - `alnum`: letters and digits
   - `alpha`: letters
   - `blank`: horizontal whitespace
   - `cntrl`: control characters
   - `digit`: digits
   - `graph`: printable characters, not including space
   - `lower`: lowercase letters
   - `print`: printable characters, including space
   - `punct`: punctuation characters
   - `space`: horizontal or vertical whitespace
   - `upper`: uppercase letters
   - `xdigit`: hexadecimal digits

A  class  is more  portable  than  a range;  but  its  characters expand  in  no
particular order (except  `[:lower:]` and `[:upper:]` which  expand in ascending
order).

# If `SET2` contains a repetition of the  same character, it can be shortened into `[C*N]`.

Where `C`  is the character  and `N`  the number of  times it is  repeated.  For
example, `[C*5]` expands to `CCCCC`.  `N`  can be omitted, in which case, `[C*]`
expands to as many copies of `C` as necessary to make `SET2` as long as `SET1`.

# `--complement` replaces `SET1`  with its complement (all of  the characters that are not in `SET1`).
