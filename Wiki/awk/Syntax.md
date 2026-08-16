# Comparison between numbers and strings (with/out strnum attribute)

If 2 operands are compared, and at least  one of them is a string, then a string
comparison is performed.  Otherwise, a numeric comparison is performed.

# Regex constant vs Dynamic regex

Often  (always?), where  a  regex  constant is  expected  (`/regex/`), a  string
constant is also accepted; or any expression  which evaluates to a string or can
be coerced  into one.  The  contents of  the string is  then used as  the regex.
Since the  expression can be evaluated  at runtime, such  a regex is said  to be
dynamic.

---

Prefer a regex constant:

   - A string constant is complicated to write and more difficult to read,
     because it's parsed twice (once at the lexical level when awk builds an
     internal copy of the program, and a second time at the runtime level) which
     forces you to escape backslashes used in escape sequences.  Forgetting to
     do so is a common source of error.

   - A regex constant is more efficient.

   - A regex constant better shows your intent; i.e. matching a regex.
