

A range  always span at  least 2  lines (unless it  starts on the  last line).
This implies that if a line match both  the start and end of a range, only the
match for the start is considered; the match for the end is ignored.

---

If a  range starts on  some line,  but no line  matches its end,  it continues
until the  very last  line.  Or  the last line  of the  current block  if it's
specified inside one:

    $ printf '%s\n' a b a c | sed -n '/a/,/a/ { /b/,/x/ p }'
    b
    a

Here, even though `/x/`  fails to match a line, `p` doesn't  print all the lines
until the end of the input – if it  did, it would also print `c`.  It stops at
the second line `a`  because that's the end of the range  applied to the current
block.

---

A range can only match disjoint blocks of lines.  It can't match 2 blocks with
a non-empty intersection:

    $ printf '%s\n' a b a c a | sed -n '/a/,/a/ { /[^a]/ p }'
    b

At first glance, there seems to be two matches.

    a b a c a
      ^   ^

But the  output contains only `b`,  not `c`.  That's because  the range starting
from the first `a` is ended by the second `a`.  So, `c` is outside any range:

      ┌ inside a range
      │   ┌ outside a range
      │   │
    a b a c a
    │   │   │
    │   │   └ starts another range (but it's too late for `c`)
    │   └ ends the range
    └ starts a range

---

A  bang  after a  range  negates  the whole  range;  not  just the  2nd  address
specifier:

                                             v
    $ printf '%s\n' - a + b | sed -n '/-/,/+/! p'
    b

Here, if `!` was only negating `/+/`, the  output would be the same as if `/+/!`
was replaced with `/^[^+]*$/`:

                                          v-------v
    $ printf '%s\n' - a + b | sed -n '/-/,/^[^+]*$/ p'
    -
    a

# How to terminate commands expecting arbitrary argument?

A command which expects an arbitrary argument  (e.g. file name or text) can only
be terminated with a newline, or be written  at the end of an `-e` string on the
shell's  CLI.  In  particular,  neither  a semicolon  nor  a  closing `}`  would
terminate it; they would be consumed as part of the argument.

This applies to the commands: `r`, `R`, `w`, `W`, `a`, `i`, `c`.
This also applies to the `w` flag of the `s` command.

# Regex matching

A regex is  always matched against the *current* contents  of the pattern space;
even when used as an address.  If  the pattern space has been changed (e.g. with
a `s`ubstitute command), the regex is matched against the new text.

---

GNU  `sed(1)` supports  most Vim's  regex  syntaxes; that  includes most  escape
sequences (e.g. `\a` for the BEL  character), as well as equivalence classes and
collating symbols  in bracket expressions.  Even  `//` stands for the  last used
regex (and it doesn't matter where each  of `//` and the last regex are written:
an address, the pattern field of a substitution, or a mix of both).

The most notable differences are:

   - no lookarounds, nor lazy quantifiers

   - most character classes don't have  any equivalent escape sequence (e.g.  no
     `\d` to replace `[0-9]`); the only exceptions  are `\s`, `\S`, `\w`, and
     `\W`

   - `\b` matches a word boundary; not the BS character
   - `\s` can match an embedded newline:

      	  $ printf 'a b\nc' | sed 'N; s/\s/_/g'
      	  a_b_c

   - `\cx` produces or matches CTRL-x
   - `\d012`/`\o012`/`\x12` produce or match the character whose
     decimal/octal/hexadecimal ASCII value is 12 (*)

   - Vim supports `\{n,m\}` and`\{n,m}`; `sed(1)` only supports the former

   - with Vim, you can list `]` anywhere in a bracket expression (by escaping
     it); with `sed(1)` (and some other GNU programs), `]` can only be listed at
     the start (or right after `^` in the complement of a bracket expression)

   - if a capturing  group fails to match, no pattern  using a backreference
     to it can match:

        $ echo 'ab' | sed 's/\(c\)\|\(a\)\1/_/'
        sed: -e expression #1, char 19: Invalid back reference

        $ vim
        :echo substitute('ab', '\(c\)\|\(a\)\1', '_', '')
        _b

(*) Those syntaxes are interpreted everywhere:

   - in a regex used as an address
   - in the pattern field of a substitution
   - in the replacement field of a substitution
   - in the inserted text of an `a`/`i`/`c` command
   - in the file argument of a `w`, `W`, `r`, `R` command

That's because  GNU `sed(1)` processes  escape sequences *before*  executing the
code.

In Vim,  the syntaxes to  produce or match  characters according to  their ASCII
value are more  inconsistent.  To match them, Vim uses  `\%d`, `\%o`, `\%x`.  It
can't  use `\d`,  `\o`, `\x`,  because those  are already  taken by  some digits
classes.  And to  produce such characters, Vim uses  various syntaxes documented
at `:help string`.

