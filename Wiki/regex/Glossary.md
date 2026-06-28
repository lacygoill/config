# b
## BRE vs ERE

Basic and Extended Regular Expression.

They are two variations on the syntax of a pattern.

By default:

   - `grep(1)`, `sed(1)`, and Vim use BRE
   - `bash(1)`, `gawk(1)`, and `mawk(1)` use ERE

Most programs also support various extensions.

One  notable difference  between  BRE and  ERE  is  in the  semantics  of a  few
characters: `?`, `+`, `()`, `{}`, and  `|`. With BRE syntax, these characters do
not have any  special meaning unless prefixed with a  backslash.  While with ERE
syntax, it's  reversed: these  characters are special  unless they  are prefixed
with a backslash.

In some  implementations of some programs,  there is no difference  in available
functionality between  BRE and  ERE (e.g. GNU `grep(1)`  and GNU  `sed(1)`).  In
others, BRE is less powerful.

##
# c
## character classes

See: `info '(grep)Character Classes and Bracket Expressions'`.

---

In what follows, whenever you read  "for some GNU programs", it means `bash(1)`,
`gawk(1)`, `grep(1)`, `sed(1)` (and possibly other programs).

---

Classes cannot match multibyte characters.
Exceptions:

   - in a multibyte locale for some GNU programs

   - in Vim: only `[:print:]`, `[:lower:]`, and `[:upper:]`

---

In practice,  I think  you want  these named classes  to parse  user-input data.
However, to parse  code, you might prefer  to stick to ranges.   For example, in
`bash(1)`, C, Lua, `mawk(1)`/`gawk(1)`, and  Vim, an identifier cannot include a
multibyte character (but it can in fish, Python, and Rust).

---

Python and Lua don't support any of those named character classes.

---

Most programs support  a few escape sequences as synonyms  (that includes Python
and Lua).  For example, `\s` is equivalent to `[[:space:]]`.  Notable exceptions
are `bash(1)` and `mawk(1)`, which don't support any synonyms.

Lua supports similar  sequences, using `%` instead of `\`  (e.g. `%s` instead of
`\s`).  With one notable pitfall: `%w`  is not equivalent to `[_[:alnum:]]`, but
to `[[:alnum:]]`.

### `[:alpha:]`

`[:lower:][:upper:]`

In the `C` locale and ASCII character encoding, it's `[A-Za-z]`.

In a multibyte locale, for some GNU programs, it's `[[=a=]...[=z=]]`.

### `[:alnum:]`

`[:alpha:][:digit:]`

### `[:ascii:]`

This character class is provided by some  tools to match characters in the ASCII
table.  But it's non-standard (i.e. not defined by POSIX).

It can be simulated in any tool with `[x00-\x7F]`.
Characters outside the ASCII table can be matched with `[^\x00-\x7F]`.

### `[:blank:]`

In the ASCII character encoding, it's the space and tab characters.

### `[:cntrl:]`

Control characters.

In the ASCII character encoding, it's any non-printable ASCII character.

### `[:digit:]`

`[0-9]`

### `[:graph:]`

`[:alnum:][:punct:]`

### `[:lower:]`

In the `C` locale and ASCII character encoding, it's `[a-z]`.

In  a  multibyte  locale,  for  some GNU  programs,  it  also  matches  accented
characters.

### `[:print:]`

`[:alnum:][:blank:][:punct:]` - Tab

### `[:punct:]`

Punctuation characters.

In the ASCII character encoding, it's ``[!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~]``.

### `[:space:]`

In  the  ASCII  character  encoding,   it's  the  horizontal  and  vertical  tab
characters, new line (or NULL in a  Vim buffer), form feed, carriage return, and
space.

### `[:upper:]`

In the `C` locale and ASCII character encoding, it's `[A-Z]`.

In  a  multibyte  locale,  for  some GNU  programs,  it  also  matches  accented
characters.

### `[:word:]`

`[:alnum:]_`

Not as widely supported as other classes:

   - yes: `bash(1)`, `fish(1)`, Perl
   - no: `grep(1)`, `mawk(1)`/`gawk(1)`, `sed(1)`, Vim

### `[:xdigit:]`

`[0-9A-Fa-f]`

###
### `\d`, `\D`

Synonyms of `[[:digit:]]` and `[^[:digit:]]`.

Not as widely supported as other synonyms.
Notably, `gawk(1)`, `grep(1)`, and `sed(1)` don't support them.

### `\s`, `\S`

Synonyms of `[[:space:]]` and `[^[:space:]]`.

Exception: In Vim, those are synonyms of `[[:blank:]]` and `[^[:blank:]]`.

### `\w`, `\W`

Synonyms of `[_[:alnum:]]` and `[^_[:alnum:]]`.

###
### special characters

Some  characters are  special because  they're matched  by some  named class(es)
while being outside the ASCII table, and not matched by `[[=a=]...[=z=]]`.

See: `man 3 pcrepattern /^\s*U+00A0`.

---

`U+000A` is also special, but for different reasons.

#### `U+000A`

Some programs are line-oriented (e.g. `mawk(1)`/`gawk(1)`, `grep(1)`, `sed(1)`).
For  those,  `[:space:]`  and  `[:cntrl:]`  don't  match  `U+000A`,  unless  you
make  them  split  their  input  on   something  else  than  the  newline  (e.g.
by  passing  `--null-data`  to  `grep(1)`   and  `sed(1)`,  or  `-v RS='\0'`  to
`mawk(1)`/`gawk(1)`).

---

In a Vim *buffer*, `[:space:]` does not match `U+000A`, but `U+0000` (because of
`:help NL-used-for-Nul`).  Note  that it  still works  as expected  when matched
against a string:

          string (!= buffer)
          v------v
    :echo "\u000A" =~ '[[:space:]]'
    1

---

In fish, `U+000A` cannot be matched by anything (not even by `.`).

#### `U+0085`

In a multibyte locale, for some GNU programs, it's matched by `[:cntrl:]`.

#### `U+2028`, `U+2029`

In a multibyte  locale, for some GNU programs, those  are matched by `[:cntrl:]`
and `[:space:]`, but not by `[:print:]`.

In Vim, they're only matched by `[:print:]`.

#### `U+00A0`, `U+180E`, `U+2007`, `U+202F`

In a multibyte  locale, for some GNU programs, those  are matched by `[:punct:]`
and `[:print:]`.

In  Vim, `[:punct:]`  matches none  of them.  `[:print:]` matches  all of  them,
except `U+180E`.

#### `U+1680`, `U+2000-U+2006`, `U+2008`, `U+2009`, `U+200A`, `U+205F`, `U+3000`

In a multibyte  locale, for some GNU programs, those  are matched by `[:blank:]`
and `[:space:]`.

##
## collating symbol

Sequence of characters, bracketed by `[.` and  `].`, that should be treated as a
unit.  It can only be written inside a bracket expression.

---

For  example, when  matching or  sorting string  data in  the czech  locale, the
sequence of characters ‘ch’ must be  treated as a single character which can
be matched with `[.ch.]` in a bracket expression:

    $ sudoedit /etc/locale.gen
    # comment out this line: # cs_CZ.UTF-8 UTF-8
    $ sudo locale-gen
    $ LC_ALL=cs_CZ.UTF-8 grep '^[[.ch.]]o$' <<<'cho'
    cho

It comes after ‘h’ but before ‘i’:

    $ LC_ALL=cs_CZ.UTF-8 grep '^[h-i]o$' <<<'cho'
    cho

See here for more info:
<https://unix.stackexchange.com/questions/254811/what-does-ch-mean-in-a-regex>

---

Here's how the book ‘Sed & Awk’ introduces the concept of collation:

   > Additionally, the standard provides for sequences of characters that should be
   > treated as a single unit when matching and collating (sorting) string data.
   > POSIX also changed what had been common terminology.
   > What we've been calling a "character  class" is called a "bracket expression" in
   > the POSIX standard.

Page 56 of the PDF.

##
# e
## equivalence class

Set of characters that should be considered equivalent, such as `e` and `è`.
It consists of a named element from the locale, bracketed by `[=` and `=]`.
It can only be written inside a bracket expression.

##
# l
## `LC_COLLATE`

It determines how the characters are sorted (aka collation order).  That matters
for ranges like `[a-z]`, and for any tool which needs to compare strings:

   - `comm(1)`
   - `join(1)`
   - `sort(1)`
   - `test(1)`
   - `uniq(1)`

## `LC_CTYPE`

It  determines  the type  of  characters.   For  example, which  characters  are
whitespace,  or  which characters  are  letters;  that  matters for  classes  of
characters like `[:alpha:]`.  It also  determines the character encoding (UTF-8,
ASCII, ...).

##
# m
## meta-character

Character whose meaning is special.

Examples:

    meta-character |        meaning
    -------------------------------------
                 ^ | start of text
                 $ | end of text
                 * | 0 or more quantifier
                 . | any character

## meta-sequence

Sequence of characters whose meaning is special.

Examples:

    meta-sequence |          meaning
    ---------------------------------------
               \1 | backref
          {4, 12} | interval quantifier
            [abc] | character class
           [^abc] | negated character class
##
# p
## PCRE

Perl-compatible regular expressions.

Those support more powerful syntaxes such as:

    ┌──────────┬────────────────────────────────────────┐
    │ (?=...)  │ positive look ahead                    │
    ├──────────┼────────────────────────────────────────┤
    │ (?!...)  │ negative look ahead                    │
    ├──────────┼────────────────────────────────────────┤
    │ (?<=...) │ positive look behind                   │
    ├──────────┼────────────────────────────────────────┤
    │ (?<!...) │ negative look behind                   │
    ├──────────┼────────────────────────────────────────┤
    │ \K       │ reset start of match (like \zs in Vim) │
    └──────────┴────────────────────────────────────────┘

For more info: `man pcresyntax`.
