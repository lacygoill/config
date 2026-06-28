# `[a-z]` is not case sensitive!

POSIX mandates that `[a-z]` uses the  current locale's collation order.  But the
latter  might be  case-insensitive.  For  example, it  might sort  in dictionary
order:

    aAbBcC...xXyYzZ

Solution: Set `LC_ALL` to `C`.

# `[a-z]` matches two characters!

Those are  probably a collation  symbol.  For example,  in a Danish  locale, the
regex `^[a-z]$` matches the string `aa`,  because it's a single collating symbol
that comes after  `a` and before `b`;  `ch`, `ij`, and `ll`  behave similarly in
resp. Czech, Dutch, and Spanish locales.

Solution: Set `LC_ALL` to `C`.

# `.*` does not match everything!

Your  input might  include  invalid multibyte  sequences.   For `sed(1)`,  POSIX
mandates that  such sequences are  *not* matched by `.`  (see `info sed /^'z'`).
`grep(1)`'s behavior is undefined:

   > POSIX does  not specify the  behavior of  ‘grep’ when patterns  or input
   > data contain encoding errors or  null characters, so portable scripts should
   > avoid such usage.

Solution: Set `LC_ALL` to `C`.

# Do *not* set `LC_COLLATE`!

First, it is ineffective if `LC_ALL` is also set.

Second, it  has undefined behavior  if `LC_CTYPE`  (or `LANG`, if  `LC_CTYPE` is
unset) is set to an incompatible value.  For example, you get undefined behavior
if `LC_CTYPE` is `ja_JP.PCK` but `LC_COLLATE` is `en_US.UTF-8`.

If you need  to change the locale's  collation order, or how  some named classes
are interpreted, set `LC_ALL` instead.

See the footnotes at the end of: `info sort`.
