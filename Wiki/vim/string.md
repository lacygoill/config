# What's a newline?

Any character or set of characters used to represent a new line:

    ┌───────┬─────────┐
    │ CR LF │ Windows │
    ├───────┼─────────┤
    │ LF    │ Unix    │
    └───────┴─────────┘

# What's the only option which alters the behavior of `match()` and `matchstr()`?

`'ignorecase'`

If your pattern might be influenced by it, use `\c` or `\C`.

##
# Positions
## What's the meaning of the number given by `virtcol('.')`?

It's the index of the screen cell under the cursor.

Note that  if the cursor is  on a multicell character,  like a tab or  a literal
control character, then the reported index is the one of the *last* cell:
```vim
vim9script
setline(1, "foo\tbar")
setline(2, "foo\<c-a>bar")
norm! 1G4|
echom virtcol('.')
norm! 2G4|
echom virtcol('.')
```
    8
    5

Because the cursor is on the last cell; unless virtual edit is enabled, in which
the cursor could be on any cell:
```vim
vim9script
set ve=all
setline(1, "foo\tbar")
setline(2, "foo\<c-a>bar")
norm! 1G4|
echom virtcol('.')
norm! 2G4|
echom virtcol('.')
```
    4
    4

### Which options does it unexpectedly ignore?

The ones which deal with the conceal mechanism:

   - `'conceallevel'`
   - `'concealcursor'`

---

The same is true for `strdisplaywidth()` btw:
```vim
vim9script
setline(1, 'a bbbbbb c')
matchadd('Conceal', 'b\+')
set cole=3 cocu=n
norm! $
echo virtcol('.')
echo getline('.')->strdisplaywidth()
```
    10
    10

Here,  the  output is  10  while  you might  expect  4,  because the  "b"'s  are
concealed, and only 4 cells are visible:

    a  c
    ^--^

### Which options can unexpectedly alter its value?

The ones which deal with soft-wrapping:

   - `'wrap'`
   - `'linebreak'`
   - `'breakat'`
   - `'breakindent'`
   - `'showbreak'`

But only when you're  on a long soft-wrapped line, and the  cursor is beyond the
last character of the first screen line.

That's because  `virtcol()` takes into into  account *all* the cells  on a line;
from the first character up to the last one.
This includes empty cells  between the end of a soft-wrapped  line and the right
border of the window, even if they don't match any whitespace in the file.
That can only happen if `'linebreak'` is set (and `'breakat'` contains the space
character, which it does by default).

Example:
```vim
vim9script
lefta :25vnew
setl wrap lbr
setline(1, 'the quick brown fox jumps over the lazy dog')
norm! 19l
echom virtcol('.')
norm! 029l
echom virtcol('.')
```
    25
    35

`25` is unexpected, because when `virtcol('.')` is evaluated the cursor is here:

    the quick brown fox      |
                       ^

That's the cell 20, not 25; but  `virtcol('.')` gives 25 because it counts those
five cells:

    the quick brown fox      |
                        ^---^

`35` is unexpected, because when `virtcol('.')` is evaluated the cursor is here:

    the quick brown fox      |
    jumps over the lazy dog  |
             ^

That's the  cell 30, not 35;  but `virtcol('.')` gives  35 because – again  – it
counts those five cells:

    the quick brown fox      |
                        ^---^

Similarly, `virtcol('.')` counts the virtual character displayed at the start of
a soft-wrapped line when `'showbreak'` is set:
```vim
vim9script
lefta :25vnew
setl wrap showbreak=+
setline(1, 'the quick brown fox jumps over the lazy dog')
norm! 29l
echom virtcol('.')
```
    31

`31` is unexpected, because the cursor is here:

    the quick brown fox jumps|
    + over the lazy dog      |
         ^

If we ignore the  cell displaying the virtual `+`, the cursor is  on the cel 30,
not 31.  But `virtcol('.')` does take into account the virtual `+`.

A similar issue exists with `'breakindent'`.

---

All of  this is inconsistent  with `:help virtcol()`  which says that  the position
should be computed like if the line was of unlimited width:

   > That is, the last screen position occupied by the character at that
   > position, when the screen would be of unlimited width.

IOW, whether the line is soft-wrapped or not, and how it is soft-wrapped, should
not matter.  It's a known issue; from `:help todo /virtcol`:

   > Value returned by virtcol() changes depending on how lines wrap.  This is
   > inconsistent with the documentation.

See also github issue #5713.

#### When is it still ok to use it?

When you use its value in a `\%v` atom:
```vim
vim9script
lefta :25vnew
setl wrap lbr showbreak=+
setline(1, 'the quick brown fox jumps over the lazy dog')
norm! 29l
var vcol = virtcol('.')
norm! 0
search('\%' .. vcol .. 'v')
```
    the cursor is back on the "r" in "over"

Or in a normal `|` command:
```vim
vim9script
lefta :25vnew
setl wrap lbr showbreak=+
setline(1, 'the quick brown fox jumps over the lazy dog')
matchadd('Conceal', 'brown')
set cole=3 cocu=n
norm! 29l
var vcol = virtcol('.')
norm! 0
exe 'norm! ' .. vcol .. '|'
```
    the cursor is back on the "r" in "over"

That's because  `virtcol()`, `\%v` and  `|` *all* agree  that all cells  must be
counted;  including  unexpected  ones.   They  also  *all*  ignore  the  conceal
mechanism entirely.

###
### Which options alter the cursor position on a multicell character (and thus `virtcol('.')` too)?

`'list'` and `'virtualedit'`.

If `'list'`  is true, the cursor  is always on  the *first* cell of  a multicell
character.
If `'virtualedit'`  has the  value `all`,  the cursor can  be on  any cell  of a
multicell character; otherwise, it's always on the *last* cell.

##
### I'm using `virtcol('.')` in a `\%v` atom.  It doesn't match anything!
```vim
vim9script
setline(1, "the\tquick\tbrown\tfox")
norm! 22|
var vcol: number = virtcol('.')
norm! 0
exe ':/\%' .. vcol .. 'v'
```
    E486: Pattern not found: \%24v

#### Why?

`\%v` can only  match the *first* cell of a  character, but `virtcol('.')` gives
the index of the last one.

Usually, that's  not an issue,  because most characters  occupy only 1  cell, in
which case there's no difference between the  first and last cells; they are the
same.  But it *is* an issue if your cursor is on a multicell character.

#### How to work around this issue?

Make sure to compute the index of the *first* cell:

    # ✘
    virtcol('.')

    # ✔
    virtcol([line('.'), col('.') - 1]) + 1
    ^--------------------------------^
    index of the last cell of the previous character

Test:
```vim
vim9script
setline(1, "the\tquick\tbrown\tfox")
norm! 22|
var vcol: number = virtcol([line('.'), col('.') - 1]) + 1
norm! 0
exe ':/\%' .. vcol .. 'v'
```
    no error

##
## ?

Have we  used a useless and  costly quantifier, where a  simple `\%>123c` and/or
`\%<123c` would have sufficed (and been faster)?

    # slow
    getline('.') =~ '\%12c.\{-}\S.\{-}\%34c'

    # fast
    getline('.') =~ '\%>11c\%<35c\S'

Look for this pattern (I guess):

    \\{-\|\.\*\|\.\\+

We've stopped somewhere in our readline plugin.

---

Look for this pattern:

    \\%[<>]

Each time, check whether there is some rule to infer.
Note it in an "antipattern" or "optimization" section in `vim/regex.md`.

## ?

Have we used `charcol()` + `line()` when `getcharpos()` would have been simpler/faster?

## ?

Did we  use `matchstr()`  with a  (slow) regex  to get  the character  under the
cursor (or right before/after), while we could have used sth simpler like:

    getline('.')[charcol('.') - 1]

Look for this pattern:

    \C\<matchstr(\%(&l:cms\|.*<SNR>\)\@!\|\<strpart(

---

Same issue with all the text after the cursor:

    getline('.')[charcol('.') - 1 :]

And with all the text before the cursor:

    getline('.')->strpart(0, col('.') - 1)

## ?

Have we used a slow `matchstr()`:
```vim
vim9script
var str = 'the,quick,brown,fox,jumps,over,the,lazy,dog'
def Func()
    for i in range(100'000)
        matchstr(str, '.*,\zs.*')
    endfor
enddef
var time = reltime()
Func()
(reltime(time)
    ->reltimestr()
    ->matchstr('.*\..\{,3}')
        .. ' seconds for matchstr() to get "' .. matchstr(str, '.*,\zs.*') .. '"'
)->setline(1)
```
    0.871 seconds for matchstr() to get "dog"

when `strridx()` would have been much faster:
```vim
vim9script
var str = 'the,quick,brown,fox,jumps,over,the,lazy,dog'
def Func()
    for i in range(100'000)
        str->strpart(strridx(str, ',') + 1)
    endfor
enddef
var time = reltime()
Func()
(reltime(time)
    ->reltimestr()
    ->matchstr('.*\..\{,3}')
        .. ' seconds for strpart() to get "' .. str->strpart(strridx(str, ',') + 1) .. '"'
)->setline(1)
```
    0.046 seconds for strpart() to get "dog"

---

Same issue with `stridx()`:
```vim
vim9script
var str = 'the,quick,brown,fox,jumps,over,the,lazy,dog'
def Func()
    for i in range(100'000)
        matchstr(str, ',\zs.*')
    endfor
enddef
var time = reltime()
Func()
(reltime(time)
    ->reltimestr()
    ->matchstr('.*\..\{,3}')
        .. ' seconds for matchstr() to get "' .. matchstr(str, ',\zs.*') .. '"'
)->setline(1)
```
    0.511 seconds for matchstr() to get "quick,brown,fox,jumps,over,the,lazy,dog"

→
```vim
vim9script
var str = 'the,quick,brown,fox,jumps,over,the,lazy,dog'
def Func()
    for i in range(100'000)
        str->strpart(stridx(str, ',') + 1)
    endfor
enddef
var time = reltime()
Func()
(reltime(time)
    ->reltimestr()
    ->matchstr('.*\..\{,3}')
        .. ' seconds for strpart() to get "' .. str->strpart(stridx(str, ',') + 1) .. '"'
)->setline(1)
```
    0.047 seconds for strpart() to get "quick,brown,fox,jumps,over,the,lazy,dog"

---

Same issue with `match()`.
```vim
vim9script
var str = 'the,quick;brown,fox;jumps,over;the,lazy;dog'
def Func()
    for i in range(100'000)
        matchstr(str, '[,;]\zs.*')
    endfor
enddef
var time = reltime()
Func()
(reltime(time)
    ->reltimestr()
    ->matchstr('.*\..\{,3}')
        .. ' seconds for matchstr() to get "' .. matchstr(str, '[,;]\zs.*') .. '"'
)->setline(1)
```
    0.529 seconds for matchstr() to get "quick;brown,fox;jumps,over;the,lazy;dog"
```vim
vim9script
var str = 'the,quick;brown,fox;jumps,over;the,lazy;dog'
def Func()
    for i in range(100'000)
        str->strpart(match(str, '[;,]') + 1)
    endfor
enddef
var time = reltime()
Func()
(reltime(time)
    ->reltimestr()
    ->matchstr('.*\..\{,3}')
        .. ' seconds for strpart() to get "' .. str->strpart(match(str, '[;,]') + 1) .. '"'
)->setline(1)
```
    0.182 seconds for strpart() to get "quick;brown,fox;jumps,over;the,lazy;dog"

---

So, which conditions must be satisfied for an optimization to be possible?

Answer: you're  using `matchstr()`  to extract  a substring  for which  both the
start  and the  end are  the first  occurrence of  a "simple"  pattern (i.e.  no
quantifier; e.g.  a collection), or  the last  occurrence of a  character.  Note
that a simple pattern can be `^` or `$`.

The index  of the  first occurrence  of a  simple pattern  can be  obtained with
`match()` or `stridx()`.  The index of the last occurrence of a character can be
obtained with `strridx()`.

Note that for `match()`, `stridx()`, `strridx()`  to be usable, there must be no
extra requirement; for example:

    matchstr(s, '^\s*X\zs.*')
                 ^---^

This is *not* the first occurrence of any  X.  This is the first occurence of an
X which is only preceded by whitespace.  So, you couldn't write this:

    strpart(s, match(s, 'X') + 1)

Edit: Actually, that's a bit more complex.
The 2 solutions are not always equivalent.
```vim
vim9script
var str = 'the quick brown fox'
echo matchstr(str, '.*,\zs.*') == ''
```
    true
```vim
vim9script
var str = 'the quick brown fox'
echo str->strpart(strridx(str, ',') + 1)
```
    the quick brown fox

You must handle the case where your simple pattern doesn't match separately:
```vim
vim9script
var str = 'the quick brown fox'
var i = strridx(str, ',')
echo i == - 1 ? "''" : str->strpart(i + 1)
str = 'the,quick,brown,fox'
i = strridx(str, ',')
echo i == - 1 ? '' : str->strpart(i + 1)
```
    ''
    fox

All in all, it seems quite complex to replace `matchstr()`...
Consider doing it only when you need to optimize some code.

Note that what really makes Vim slow  is *not* `matchstr()` itself; it's the `*`
quantifier (and possibly other ones) which you  often have to use when passing a
regex to `matchstr()`.

##
## How to get the length of the longest line in the current buffer?

    echo getline(1, '$')->map('strcharlen(v:val)')->max()

Or:

    " 'nowrap' needs to be off
    echo range(1, line('$'))->map('virtcol([v:val, "$"])')->max() - 1
                                                                  ^^^

Note that the reason for `-1` is explained at `:help virtcol()`:

   > $       the end of the cursor line (the result is the
   >         number of displayed characters in the cursor line
   >         **plus one**)

##
## `'\%' .. col('.') .. 'c'` matches a character on the current line.  It does not match anything on a different line!

There is probably at least one multibyte character on one of those lines.
```vim
vim9script
setline(1, 'aei')
search('i')
var col: number = col('.')
setline(1, 'aéi')
norm! 0
exe ':/\%' .. col .. 'c.'
```
    E486: Pattern not found: \%3c.

On the `aéi` line:

   - the first byte of the first character has the index 1
   - the first byte of the second character has the index 2
   - the first byte of the third character has the index 4

There's no character whose first byte has the index 3.

Bottom line: There is never the guarantee  that `\%123c.` matches a character on
a line, even if it does match one on another line.
You only have this guarantee if you use it on the *same* line from where you got
the byte index `123`, *and* if that line didn't change in the meantime.

##
# Coercion
## I have an expression containing a math operator (`+`, `<`, ...) and a string.

    'hello' + 123
    'hello' < 123
    ...

### How is the string evaluated when it begins with
#### a letter?

    0

---

    echo 'hello' + 123
    123˜

#### an integer?

This integer.

---

    echo '12hello' + 3
    15˜

#### a float?

Its integer part.

---

    echo '12.34hello' + 5
    17˜

##### how to fix this broken coercion?

Use `str2float()`:

    echo str2float(str)

---

    echo str2float('1.2') + 3
    4.2˜

    echo str2float('1.2foo') + 3
    4.2˜

##
## Can I use a number as a key in a dictionary?

Yes.

          v
    echo {1: 'one'}
    {'1': 'one'}˜

                      v
    echo {'1': 'one'}[1]
    one˜

Whether you use  the number when you  define the dictionary, or when  you try to
access some of its value, Vim will coerce it into a string.

##
## What's one pitfall of Vim's builtin coercion of strings into numbers?

If the  number inside the  string begins  with `0`, and  if its digits  don't go
beyond `7`, it will be interpreted as octal.

    echo '017' + 1
    16˜

To fix this, use `str2nr()`:

    echo str2nr('017') + 1
    18˜

---

`str2nr()` takes  a string containing  a number as  input, and converts  it into
decimal.

It accepts a second optional argument which stands for the input base (which can
be 2, 8, 10 or 16).
Without it, `str2nr()` assumes that your input number is decimal; which explains
the output of:

    echo str2nr('017')
    17˜

### When should I be conscious of it?

Whenever you work on user data.
User data is unpredictable; you have to assume a decimal number might begin with `0`.

As an example, when you perform a  substitution, and you use `submatch()` in the
replacement part to refer to a capturing group matching a number.

##
# Special notations
## Why is the caret notation of
### a null `^@`?

It has  been decided to  represent the  first control character  (codepoint `1`)
with the first letter of the alphabet; so, the caret notation of `SOH` (Start Of
Heading) is `^A`.

The null is a special control character whose codepoint is `0`.
To go  on using the same  scheme, it has been  decided to represent it  with the
character which comes before `A` in the ascii table; that is `@`.

### escape `^[`?

The codepoint of escape is `27`.
The previous codepoints are represented with `A-Z`.
To go on using  the same scheme, it has been decided  to represent `Escape` with
the first character after `Z` in the ascii table, which is `[`.

###
## What's the caret notation of the delete character?

    ^?

### Which key produces it?

The backspace key.

Don't confuse the delete character with the delete key.
<https://en.wikipedia.org/wiki/Delete_character>

---

Although, according to `:help Linux-backspace`, this is wrong:

   > Note about Linux: By default the backspace key
   > produces CTRL-?, which is wrong.  You can fix it by
   > putting this line in your rc.local:

   > echo "keycode 14 = BackSpace" | loadkeys

The backspace key should emit the backspace character.

See also: <http://tldp.org/HOWTO/Keyboard-and-Console-HOWTO-5.html>

   > Why doesn't the Backspace key generate BackSpace by default?
   >
   > (i) Because the VT100 had a Delete key above the Enter key.
   >
   > (ii) Because Linus decided so.

You could fix that at the OS level, by using `loadkeys` in the console and `xkb`
in Xorg; but I'm not sure it's worth it, and I don't know whether there would be
undesired side effects.

BTW, for the console, you would have to write in `~/.config/keyboard/VT.conf`:

    # It seems the case is important.
    # If you write `backspace`, the console login doesn't start.
    keycode 14 = BackSpace

For Xorg, I've tried to write in `~/.config/xkb/symbols/programming`:

    key <BKSP> { [ BackSpace ] };

But the backspace key still produces `^?`.
The statement is correct: if you replace `BackSpace` with `eacute`, for example,
the backspace key produces `é`.
The issue is that the `BackSpace` keysym produces `^?`.

I don't know which keysym I should write.
In a console, I've tried `$ dumpkeys /tmp/dumpkeys`, and looked at its contents.
The only relevant keysym seems `BackSpace`...

It seems we should write:

    key <BKSP> { [ Delete ] };
    key <DELE> { [ BackSpace ] };

To reverse the keysyms produced by the backspace and delete key.
But in practice, it breaks the backspace key.
The shell probably needs to be configured too...

##
## Which escape sequences can I use to encode an arbitrary character?  (3)

    \x..
    \u....
    \U........

The dots stand for hexadecimal digits,  and must match the hex/unicode codepoint
of the character.

---

    echo "a \x26 b"
    echo "a \u26 b"
    echo "a \U26 b"
    a & b˜

In this string, you can use 2 digits only, even with `\u` and `\U`.
But that's only because the next character is a space, which is not a hex digit.
If the next character *was* a hex digit, you would have to add a padding of `0`'s:

    echo "a \u00261b"
    echo "a \U000000261b"
    a &1b˜

##
# echo
## What's the output of
### `:echo "ab\rc"`?

    cb˜

`:echo`  has printed  `ab`,  then `\r`  made  it  move the  cursor  back to  the
beginning of the line, then it has printed `c`.

### `:echom "ab\rc"`?

    ab^Mc˜

`:echom` never interprets anything, so `\r` doesn't make it move the cursor.

##
## How to print two messages without adding any character between them?

Use `:echon`:

    echon 'foo' 'bar'
    foobar˜

    echon 'foo' | echon 'bar'
    foobar˜

---

In contrast, `:echo` would add a space or a newline:

    :echo 'foo' 'bar'
    foo bar˜

    :echo 'foo' | echo 'bar'
    foo˜
    bar˜

##
# Extract characters
## How to get the `n`-th
### byte of a string?

Use `strpart()`:

    strpart(str, n - 1, 1)
                 ├───┘  │
                 │      └ {len}
                 └ {start}

In legacy Vim script, you can also use a subscript:

    str[n - 1]

### character of a string?

In Vim9, use a subscript:

    str[n - 1]

In legacy, use `slice()` (also works in Vim9):

    slice(str, n - 1, n)

---
```vim
vim9script
var str: string = 'résumé'
echo str[3 - 1]
echo slice(str, 3 - 1, 3)

str = "\u0061\u0300\u0065\u0301\u0075\u0302"
echo str[3 - 1]
echo slice(str, 3 - 1, 3)
```
    s
    s
    û
    û

---

You could also use `strcharpart()`:

    strcharpart(str, n - 1, 1, true)
                     ├───┘  │  │
                     │      │  └ {skipcc}: don't count composing characters separately
                     │      └ {len}
                     └ {start}

But that's more complex than it needs to be.

Same thing for `strgetchar()` + `nr2char()`:

    strgetchar(str, n - 1)->nr2char()
                    ├───┘
                    └ {index}

Note  that this  one doesn't  even  work as  expected when  the string  contains
composing characters  (because `strgetchar()`  counts them separately,  which is
most probably not what you want).

##
## How to get the last characters of a string, from the `n`-th one?

In Vim9, use a `[]` slice:

    str[n :]

In legacy, use `slice()` (also works in Vim9):

    slice(str, n - 1)

Without `{end}`, `slice()` goes until the end.

Example:

    vim9 echo 'résumé'[2 :]
    sumé˜

    echo slice('résumé', 2)
    sumé˜

###
## How to get the character
### under the cursor?

In Vim9 script:

    getline('.')[charcol('.') - 1]
                              ^^^
                              to make up for the fact that "charcol()" starts indexing from 1
                              while Vim starts indexing a string from 0

In Vim script legacy:

                                           the previous length counts characters; not bytes
                                           v----v
    getline('.')->strpart(col('.') - 1, 1, v:true)
    getline('.')->strpart(col('.') - 1)->slice(0, 1)
                                   ^^^
                                   to make up for the fact that "col()" starts indexing from 1
                                   while "strpart()" starts indexing from 0

#### Why the difference between Vim9 and legacy?

In Vim script legacy, an index used in a string slice refers to a *byte*.
In Vim9 script, an index used in a string slice refers to a *character*.

From `:help expr-[]`:

   > In Vim9 script:
   > If expr8 is a String this results in a String that contains the expr1'th
   > single character from expr8.  To use byte indexes use |strpart()|.

###
### after the cursor?

In Vim9 script:

    # in normal mode
    getline('.')[charcol('.')]

    # in insert mode
    getline('.')[charcol('.') - 1]

In Vim script legacy:

    # in normal mode
    getline('.')->slice(charcol('.'), charcol('.') + 1)

    # in insert mode
    getline('.')->slice(charcol('.') - 1, charcol('.'))

### before the cursor?

In Vim9:

    charcol('.') == 1 ? '' : getline('.')[charcol('.') - 2]
    ^---------------^
    special case which can't be handled with a subscript

In legacy:

    getline('.')->slice(charcol('.') - 2, charcol('.') - 1)

---

In Vim9, you could also write this:

    getline('.')->strpart(0, col('.') - 1)[-1]
                                      ^^^
                                      to exclude the first byte of the character under the cursor

But it might be slower on very long lines.

#
## What's the evaluation of `getline('.')[col('.')]`?

The character right *after* the cursor.
If the  latter is multibyte,  then, the expression  evaluates to its  first byte
instead.

### Why is it not the character under the cursor?

`col('.')` adds `1` to the byte index of the character under the cursor;
probably because `0` is already used for an error:

   > The first column is 1.  0 is returned for an error.

---

The same is true for `\%123c`.
To match the first character on a line, you must use `\%1c.` and not `\%0c.`.

### Why can't the expression be tweaked to get it?

Because it could be a multibyte character.

So you can't know how much you must remove from `col('.')`.

As an example, position your cursor on the first `é` in this text:

    résumé
     ^

And execute:

                               vvv
    echo getline('.')[col('.') - 1]
    <c3>˜

##
## Negative index
### How is a negative index argument interpreted by
#### most functions handling a string?

`0`

#### `slice()`?

It matches a character from the end of the string:

    echo slice(str, -i)
    ⇔
    echo str[-i]

---

If you pass  a second index to  `slice()`, while the first one  is negative, the
second one must also be negative.  Otherwise, you get an empty string.

#### `strcharpart()`?

It's *not* replaced by `0`; but  `strcharpart()` considers that no character can
be matched by a negative index:

    echo strcharpart('abcd', -2, 4)
    ab˜

   - character of index -2 = ''
   - character of index -1 = ''
   - character of index 0  = 'a'
   - character of index 1  = 'b'

###
### What's the evaluation of
#### `str[-i]`?

An empty string.

From `:help expr-[]`:

   > A negative index always results in an empty string (reason: backward
   > compatibility).

#### `str[-i : -j]` with `0 < i < j`?

An empty string.

When you do a slicing, the first index must be lower than the second one.

#### `str[-i : -j]` with `0 < j < i`?

The last bytes of the string.

    echo 'abc'[-2:-1]
    'bc'˜

##
# Getting info
## How to get a substring matching a pattern
### the search starting `{start}` bytes after the beginning of the original string?

Use the third optional argument of `matchstr()`:

    echo matchstr(str, pat, start)

---

    echo matchstr('-a -b -c', '-.', 3)
    -b˜

Here, we start the search 3 bytes after the beginning of the string:

    -a -b -c
       ^
       the search start here

#### and only the `{count}`-th occurrence of a match?

Use the fourth optional argument: `{count}`:

    echo matchstr(str, pat, start, count)

---

    echo matchstr('-a -b -c', '-.', 3, 2)
    -c˜

Here, the  first match  is `-b`, but  we ask  for the second  match, so  `-c` is
returned.

##
## Which other functions accept the optional arguments `{start}` and `{count}`?  (4)

   - `match()`
   - `matchend()`
   - `matchlist()`
   - `matchstrpos()`

---

    echo match('-a -b -c', '-.', 3, 2)
    6˜

Here, we ignore the first 3 bytes (index 0, 1 and 2), and the first match (`-b`).

###
## How to get the byte index position of
### the start of a text described by a regex inside a string?

Use `match()`:

    echo match(str, pat)

---

    echo match('Starting point', '\cstart')
    0˜

`start` was found at the very beginning.

#### its end?

Use `matchend()`:

    echo matchend(str, pat)

---

    echo matchend('Starting point', '\cstart')
    5˜

####
### the first occurrence of a literal text inside a string?

Use `stridx()`:

    echo stridx(str, substr)

---

    echo stridx('Starting point', 'start')
    -1˜

`start` was not found.

#### and ignore the first `n` bytes?

Use the optional third argument, `{start}`:

    echo stridx(substr, str, start)

---

    echo stridx('abc abc', 'b')
    1˜

    echo stridx('abc abc', 'b', 2)
    5˜

###
### the last occurrence of a literal text inside a string?

Use `strridx()`:

    echo strridx(str, substr)

---

    echo strridx('a:b:c', ':')
    3˜

#### and ignore the bytes after the `n`-th one?

Use the optional third argument, `{start}`:

    echo strridx(substr, str, start)

#### its last but one occurrence?

Use `strridx()` twice.
The first time to get the position of the last occurrence.
The second time, you can use this info to ignore the last occurrence.

    let str = 'a:b:c:d'
    let colon_last = strridx(str, ':')
    let colon_before_last = strridx(str, ':', colon_last - 1)
    echo colon_before_last
    3˜

###
## How to get the byte index of the start and end of a match inside a string?

Use `matchstrpos()`:

    echo matchstrpos(str, pat)

---

    echo matchstrpos('-a -b -c', '-.')
    ['-a', 0, 2]˜

    echo matchstrpos('-a -b -c', '-.', 3)
    ['-b', 3, 5]˜

    echo matchstrpos('-a -b -c', '-.', 3, 2)
    ['-c', 6, 8]˜

---

The last number in the output is the byte index of the end of the match **plus** `1`.

###
## How to get the number of times a substring appears in a string?

    echo count(str, substr)

---

    echo count('-a -b -c', '-')
    3˜

### Can it work with a regex?

No.

    echo count('-a -b -c', '-.')
    0˜

### How to ignore the case?

Pass a non-zero value as a third optional argument:

    echo count(str, val, 1)
                         ^

---

    echo count('abA', 'a')
    1˜

    echo count('abA', 'a', 1)
    2˜

### What happens if the string contains overlapping occurrences of the substring?

`count()` only considers *non* overlapping occurrences.

    echo count('aaa', 'aa')
    1˜

    echo count('aaaa', 'aa')
    2˜

###
## How to get the number of characters stored in a string?

    echo strcharlen(str)

---

Don't use `strchars()`.
The latter counts composing characters separately by default.
Unless you provide it a second non-zero (or true) argument:

    echo strchars('Ë͙͙̬̹͈͔̜́̽D̦̩̱͕͗̃͒̅̐I̞̟̣̫ͯ̀ͫ͑ͧT̞Ŏ͍̭̭̞͙̆̎̍R̺̟̼͈̟̓͆')
    51˜

    echo strchars('Ë͙͙̬̹͈͔̜́̽D̦̩̱͕͗̃͒̅̐I̞̟̣̫ͯ̀ͫ͑ͧT̞Ŏ͍̭̭̞͙̆̎̍R̺̟̼͈̟̓͆', 1)
    6˜

##
## The cursor being on a character, how to get the index of
### its last cell?

    virtcol('.')

That's because –  when `'virtualedit'` is empty  (which it is by  default) – the
cursor is always on the last cell of a multicell character.

---

Remember that `virtcol()` starts indexing from 1 (not 0).

### its first cell?

    virtcol([line('.'), col('.') - 1]) + 1

Here, `virtcol(...)` gives the index of the last cell of the previous character.
And the last `+ 1` gets us what we  really want, the index of the next cell i.e.
the first cell of the character under the cursor.

##
## How to get the number of cells a character occupy?

    echo strwidth(char)

### What if this number can change depending on where the character is put on the current line?

    echo strdisplaywidth(char, virtcol)

`virtcol` must be the index of the screen cell where `char` starts.
It can be omitted, in which case 0 is assumed.
The first screen cell is indexed with 0 (not 1).

#### How to get the length of a tab which would be inserted at the current cursor position?

    strdisplaywidth("\t", virtcol([line('.'), col('.') - 1]))

The  second argument  must  be the  index  of  the *first*  screen  cell of  the
character under the cursor (the count start from 0).

Here, `virtcol()` gives us  the index of the *last* screen  cell of the previous
character; so, we should add 1.
But `strdisplaywidth()`  indexes cells  from 0,  while `virtcol()`  indexes them
from `1`; so, we should remove 1.
Both operations cancel themselves, so we don't need to apply any offset.

##
## I have a string and a pattern.  How to get the list of substrings matching the capturing groups?

Use `matchlist()`:

    echo matchlist(str, pat)

---

    echo matchlist('abcd', '\v(.(.))(.)')
    ['abc', 'ab', 'b', 'c', '', '', '', '', '', '']˜
      │      │     │    │
      │      │     │    └ \3
      │      │     └ \2
      │      └ \1
      └ \0

##
# execute()
## Does the second argument of `execute()` has an influence
### on its output?

Most of the time, no.

However, there's one exception.
If you use `silent!`, the error messages won't be included in the output.

    echo execute('abcd', 'silent!') == ''
    1˜

### during the evaluation of the first argument?

Yes.
It can be used to allow or prevent Vim from printing any message:

    :call execute('echom "hello"', '')
    hello˜

    :call execute('echom "hello"', 'silent')
    :call execute('echom "hello"', 'silent!')
    ∅˜

##
## In which context is `execute()` run?

The current one.

### What does it entail?

`execute()` can access variables in the current scope:

    :call execute('let var = 12') | echo g:var
    12˜

    fu Func()
        call execute('let var = 34')
        echo var
    endfu
    call Func()
    34˜

##
## How to make `execute()` execute several commands, without any bar?

Pass it a list of commands:

    echo execute([cmd1, cmd2, ...])

---

    echo execute(['echo "foo"', 'echo "bar"'])

## How to eliminate the newline at the beginning of `execute('ls')`?

    echo execute('ls')[1:]

##
## To which other function can everything documented in this section also apply?

`win_execute()`

##
# Time
## How to get the local time in seconds since the epoch?

    echo localtime()
    1548170168˜

### How to make it human-readable?

    echo strftime('%c', localtime())

Here,  you  don't  need  `localtime()`,   because  without  a  second  argument,
`strftime()` assumes the current time:

    echo strftime('%c')

#### with the format `year-month-day`?  (2)

    echo strftime('%F')
    echo strftime('%Y-%m-%d')
    2019-01-22˜

#### with the format `hour:min:sec`?  (2)

    echo strftime('%T')
    echo strftime('%H:%M:%S')
    16:16:28˜

#### Where can I find all the possible formats?

    man strftime

#
## How to get a human-readable date of the epoch?

    echo strftime('%c', 0)
    Thu 01 Jan 1970 01:00:00 AM CET˜

---

The hour is not `00:00:00` because of our timezone; where we live, we must add 1 hour:

                   ┌ The +hhmm or -hhmm numeric timezone (that is, the hour and minute offset from UTC
                   ├┐
    echo strftime('%z')
    +0100˜

##
## How to get more precision (up to a millionth of a second)?

    echo reltime()
    [1548170958, 895512]˜
     ├────────┘  ├────┘
     │           └ millionths of a second
     └ seconds since epoch

### The output is a list.  How to get a string instead?

Use `reltimestr()`:

    echo reltime()->reltimestr()

##
## How to get the time passed between
### now and a previous date?

`reltime()`  accepts an  optional  argument,  `{start}`, which  must  be a  list
representing a date.

When provided, `reltime()` computes the time passed between this date and now.

    echo reltime(date)

---

    let date = reltime()
    let duration = reltime(date)
    echo reltimestr(duration)
    0.000009˜

### two dates?

`reltime()` accepts  a second optional argument,  `{end}`, which must be  a list
representing a date.

When provided, `reltime()` computes the time passed between `{start}` and `{end}`.

    echo reltime(date1, date2)

---

    let date1 = reltime()
    let date2 = reltime()
    let duration = reltime(date1, date2)
    echo reltimestr(duration)
    0.000007˜

##
## How to get the date of the last modification of `file`?

    echo getftime('file')
    1548170113˜

    echo strftime('%c', getftime('file'))
    Tue 22 Jan 2019 04:18:26 PM CET˜

##
# Transforming
## Splitting
### How to get the list of words on the line?

    echo getline('.')->split('\%(\k\@!.\)\+')

### Is the output of `split()` different if the pattern matches at the very beginning/end of the string?

By default, no.

But it can be if you add the optional argument `{keepempty}`:

                            v
    echo split(':a:b', ':', 1)
    ['', 'a', 'b']˜

    echo split('a:b:', ':', 1)
    ['a', 'b', '']˜

    echo split(':a:b:', ':', 1)
    ['', 'a', 'b', '']˜

### Why do `join()` and `split()` process `\n` differently, when passed as a second argument?

    echo split("a\nb", '\n')
    ['a', 'b']˜

    echo join(['a', 'b'], '\n')
    a\nb˜

Theory:

`split()` expects a regex, so `'\n'` is fine.
`join()` expects a literal string, so `'\n'` doesn't work.

### How to split `abXcd` into `['ab', 'X', 'cd']`?

    ✘
    echo split('abXcd', 'X\zs\|\zeX')
    ['abX', 'cd']˜
    echo split('abXcd', '\zeX\|X\zs')
    ['ab', 'Xcd']˜

    ✔
    echo split('abXcd', 'X\@<=\|\zeX')
    ['ab', 'X', 'cd']˜
    echo split('abXcd', '\zeX\|X\@<=')
    ['ab', 'X', 'cd']˜

##
## Translating
### How to replace a set of characters with another set in a given string?

Use `tr()`:

    echo tr()

---

    echo tr('big bad wolf', 'bw', 'BW')
    Big Bad Wolf˜

    echo tr('<blob>', '<>', '{}')
    {blob}˜

### How to make Vim translate special sequences such as `\<tab>` or `\x26` in a literal string?

Concatenate double quotes at the beginning and end of the string.
Then use `eval()`.

    let string = 'foo \x26 bar'
    echo eval('"'.string.'"')
    foo & bar˜

    let string = 'foo\<tab>bar'
    echo eval('"'.string.'"')
    foo    bar˜

---

`eval()` expects a string as argument.
`"string"` is *still* a string, so our concatenations didn't cause an issue.

`eval()` looks at what is inside its string argument, and evaluates it.
For example, if it was `&ft`, it would return `markdown`.

Here, it  finds `"string"`, whose  evaluation is the  same string, but  with the
surrounding quotes removed and the special characters translated.

### How to translate all unprintable characters in a string, into printable characters?

    echo strtrans(str)

---

    echo strtrans("a\nb")
    a^@b˜

### How to convert an ascii codepoint into its corresponding character?  (2)

Use `nr2char()` or `printf()` + `%c`.

    echo printf('this char is %c', 97)
    this char is a˜

    echo 'this char is '.nr2char(97)
    this char is a˜

##
## Formatting with `printf()`
### What's its signature?

    printf({fmt}, {expr1}, ...)
                           ^^^
                           up to 18 expressions

###
### What are its 3 main usages?

It can be used to transform a string:

   - by truncating a substring or a float

   - by adding a padding of spaces or zeros

   - by converting a number from a base into another

###
### Which number conversions can it perform?

The input and output base can be:

   - binary (`0b1111`, `%b`)
   - octal (`0123`, `%o`)
   - decimal (`123`, `%d`)
   - hexadecimal (`0x123`, `%x`, `%X`)

This makes 9 possible conversions (`4*4 - 4 - 3`):

    echo printf('%b', 0123)
    1010011˜
    echo printf('%b', 123)
    1111011˜
    echo printf('%b', 0x123)
    100100011˜

    echo printf('%o', 0b1111)
    17˜
    echo printf('%o', 123)
    173˜
    echo printf('%o', 0x123)
    443˜

    echo printf('%x', 0b1111)
    f˜
    echo printf('%x', 0123)
    53˜
    echo printf('%X', 123)
    7B˜

Why only 9? Why `-4` and `-3`?

`-4` because there's nothing to convert if the input and output bases are identical.
`-3` because there's no need of `printf()` for a conversion into decimal:

    echo printf('%d', 0b1111)
    ⇔
    echo 0b1111
    15˜

    echo printf('%d', 0123)
    ⇔
    echo 0123
    83˜

    echo printf('%d', 0x123)
    ⇔
    echo 0x123
    291˜

#### `str2nr()` can also convert numbers from one base to another.  How is it different?  (2)

   - `str2nr()` can only do 3 conversions, all toward decimal:

         " bin → dec
         echo str2nr('101010', 2)
         42˜

         " oct → dec
         echo str2nr('123', 8)
         83˜

         " hex → dec
         echo str2nr('123', 16)
         291˜

   - `printf()`  interprets  a  number  differently depending  on  whether  it's
     prefixed by `0` or `0x`.

     `str2nr()` doesn't care about the prefix; it cares about its second argument:

         " the octal prefix is ignored
         echo str2nr('0101010')
         101010˜

         " the octal prefix is ignored
         echo str2nr('0101010', 2)
         42˜

         " the second argument needs to be 8 for the number to be recognized as octal
         echo str2nr('0101010', 8)
         33288˜

####
### Can it coerce an expression into another type?

Yes.

When necessary, it can perform 4 conversions:

   - integer   ↔   string
   - integer   →   float
   - float     →   string

---

    " the integer `123` is initially coerced into the string `'123'`
    echo printf('%s',  123)
    123˜

    " the string `'123'` is initially coerced into the integer `123`
    echo printf('%d', '123')
    123˜

    " the integer `123` is initially coerced into the float `123.0`
    echo printf('%f',  123)
    123.000000˜

    " the float `123.456` is initially coerced into the string `'123.456'`
    echo printf('%s',  123.456)
    123.456˜

###
### What's the purpose of a `%` character?

It starts a conversion specification, which ends  with a type (such as `d` for a
decimal number or `s` for a string).

### What's the purpose of a `%` item?

It formats the corresponding expression.
The first  `%` item formats  the first expression,  the second item  formats the
second expression...

`printf()` returns  `{fmt}` where each item  has been replaced by  the formatted
form of its associated expression.

#### What's its syntax?

`%` expects one mandatory argument (the conversion specifier, aka type).
And it accepts up to three optional arguments:

   - flags
   - field-width
   - precision

The arguments must follow this order:

    %  [flags]  [field-width]  [.precision]  type
        │        │               │
        │        │               └ useful to truncate the expression
        │        │
        │        └ useful to add padding
        │
        └ an optional set of one or more characters
          to tweak the padding or the prefix of a number

###
### How do these items format an expression?
#### `%s`

As a string.

`field-width` and `.precision` are interpreted as numbers of **bytes**.

#### `%S`

As a string.

`field-width` and `.precision` are interpreted as numbers of **display cells**.

#### `%f`

As a float:

    echo printf('%f', 123)
    123.000000˜

#### `%e`

As a float written in scientific notation:

    echo printf('%e', 123.456)
    1.234560e+02˜

#### `%E`

Same thing as `%e`, but the exponent is `E` instead of `e`:

    echo printf('%E', 123.456)
    1.234560E+02˜

#### `%g`

As a float, either like `%f` or like `%e`.

Like `%f`, if the number verifies:

    10^-3 <= n < 10^7

Like `%e` otherwise.

#### `%G`

Like `%g`, but uses `E` instead of `e` in scientific notation.

###
### What's the effect of these flags?
#### `-`

Move the padding, if any, to the right (instead of the left).

#### `0`

Instead of using spaces to build a padding, zeros are used.

                  v
    echo printf('%05d', '123')
    00123˜

---

This works only when the padding is on the left, not on the right.

                  vv
    echo printf('%-05d', '123')
    123˜

#### `#`

Combined with the types `o`, `x` and `X`, it prefixes the number with `0`, `0x` or `0X`.

    echo printf('%#o', 123)
    0173˜

    echo printf('%#x', 123)
    0x7b˜

    echo printf('%#X', 123)
    0X7B˜

This lets you make the base of the number explicit.

#### `+`

Prefix a positive number with `+`:

    echo printf('%+d', 123)
    +123˜

    echo printf('%+.2f', 12.34)
    +12.34˜

#### ` ` (space)

Prefix a positive number with a space:

    echo printf('% d', 123)
     123˜
    ^

---

In case of conflict with `+`, the latter wins:

                  vv
    echo printf('%+ .2f', 12.34)
    +12.34˜
    ^

###
### How is the `field-width` argument interpreted?

The size in bytes of the converted value of the expression.

Exception:
`%S` interprets `field-width` as a size in display cells.

#### How is it useful?

To add a padding.

####
#### How to assign it a variable value?

Use the special value `*`, and pass to `printf()` 2 arguments instead of 1.
The first one being the width of  the field, the second one being the expression
to format.

---

    let width = 15
    echo printf('%d: %*s', 123, width, 'hello world')
    123:     hello world˜

####
#### When is a string aligned in its field?

When you used `%123s` and the weight of the converted value is lower than `123`.

When you used `%123S` and the converted value occupies less than `123` display cells.

    echo printf('%10S', 'ççç')

#### What happens if `field-width` is lower than the weight of the converted value?

Nothing.
The value is *not* truncated.

###
### How is the `.precision` argument interpreted?

It depends on the type with which it's used.

For integers, it's the minimum number of digits.
If necessary, a padding of zeros is added to the left.

For strings, it's the maximum of bytes/display cells.
If necessary, characters are removed on the right.

For floats, it's the maximum number of digits after the decimal point.
If necessary, digits are removed on the right.

#### How is it useful?

You can use it to truncate a converted value.

---

You can also  use it to add a padding  of zeros to an integer, but  the flag `0`
and `field-width` seem more appropriate in this case.

    echo printf('%.6d', 123)
    000123˜

    ⇔

    echo printf('%06d', 123)
    000123˜

This  way,  you  can  consider that  `field-width`  (padding)  and  `.precision`
(truncation) have completely distinct usages.

####
#### What happens if
##### I omit it?

If you don't use a float, nothing.

---

If you use a float, and the decimal part has more than 6 digits, only 6 are kept.

    echo printf('%f', 123.456789123)
    123.456789˜

---

If you use  a type of float different  than `%g` and `%G`, and  the decimal part
has less than 6 digits, trailing zeros are added:

    echo printf('%f', 123.456)
    123.456000˜
           ^^^

---

If you use `%g` or `%G`, and the decimal part has less than 6 digits, nothing happens:

    echo printf('%g', 123.456)
    123.456˜

Unless the decimal part has trailing zeros; in this case they're removed:

    echo printf('%g', 123.456000)
    123.456˜

But a single trailing zero is kept if necessary to prevent a float from becoming an integer:

    echo printf('%g', 123.000)
    123.0˜

##### I use it, but without any value (e.g. `%.s` or `%.f`)?

`0` is assumed.

For a string, it means that it's made empty (total truncation).
For a float, it means that it becomes an integer.

    echo printf('%.s', 'foobar') == ''
    1˜

    echo printf('%.f', 123.456)
    123˜

##### I use it with a value which is bigger than the size of the expression (e.g. `%.4f` and `1.23`)?

Trailing zeros are added.

    echo printf('%.4f', 1.23)
    1.2300˜

As you can see, `.precision` does not always truncate.
But this is an exception; usually `.precision` can only truncate:

    echo printf('%.10s', 'hello')
    hello˜
         ^---^
         no trailing spaces are added

So, truncation is probably the main usage of `.precision`.

####
#### How to assign it a variable value?

Like for `field-width`.
Use the special value `*`, and pass to `printf()` 2 arguments instead of 1.
The  first one  being the  precision,  the second  one being  the expression  to
format.

---

    let prec = 9
    echo printf('%.*f', prec, 1/3.0)
    0.333333333˜

---

You could also use a string concatenation, but it would be less readable.

    let prec = 9
    echo printf('%.' .. prec .. 'f', 1/3.0)
    0.333333333˜

##
### Which syntax can replace `string(dict)` or `string(list)` in a string concatenation?

The `%s` item of `printf()` can do that automatically.

    let dict = {'a': 1, 'b': 2}
    echo 'my dictionary is ' .. string(dict)
                                ^----^
    ⇔

    let dict = {'a': 1, 'b': 2}
    echo printf('my dictionary is %s', dict)
         ^----^                   ^^

From `:help printf-s`:

   > If the argument is not a String type, it is
   > automatically converted to text with the same format
   > as ":echo".

---

This is especially useful when you have several `string()` invocations which all
have the purpose of converting a non-string data into a string so that it can be
concatenated with other strings.

It can make the code more readable, and works with most (any?) type of data:

    let F = function('len')
    let b = 0zaabbcc
    echo printf('my funcref is %s, and my blob is %s', F, b)

The latter is more readable than:

    let F = function('len')
    let b = 0zaabbcc
    echo 'my funcref is ' .. function('len')->string() .. ', and my blob is ' .. string(0zaabbcc)

#### What's the limitation of this syntax?

`printf()` and `%s` merely  allow you to include any type of  data into a string
concatenation; they don't magically convert its contents into a valid command.

Example:

    fu Func(str)
        echom 'the string ' .. a:str .. ' contains ' .. strcharlen(a:str) .. ' characters'
    endfu
    let arg = 'test'
    let cmd = 'call Func(' .. string(arg) .. ')'
    exe cmd

Here, you could be tempted to replace this line:

    let cmd = 'call Func(' .. string(arg) .. ')'

With this line:

    let cmd = printf('call Func(%s)', arg)

But it won't work; it will raise:

    E121: Undefined variable: test

You still need `string()`:

    let cmd = string(arg)->printf('call Func(%s)')
              ^----^

In this example, `arg`  still has to be quoted when  passed to `Func()`, because
the latter expects a string, not a variable name.

##
# Antipatterns
## `matchstr()` + `strlen()` might be inefficient.

    getline('.')->matchstr('.*\%' .. col('.') .. 'c.')->strlen()

### How should I refactor the previous snippet?

↣
    col('.')
↢

NOTE: Yeah, it's  obvious.  But  apparently, lucidity is  not our  strong point,
because I think we wrote such code in the past.

### How about this one?

    matchstr(string, '^some pattern')->strlen()

↣
    matchend(string, '^some pattern')
↢

Again, it's faster, and more readable.

Note that the 2 are not entirely  equivalent.  If the pattern doesn't match, the
first expression returns 0; the second one returns -1.

##
## `matchstr()` invoked multiple times to extract a bunch of substrings out of a string might be inefficient.
```vim
vim9script
var text = 'hello world'
var word1 = matchstr(text, '^\S\+')
var word2 = matchstr(text, '^\S\+\s\+\zs\S\+')
```
### How could I refactor the previous snippet?
```vim
vim9script
var text = 'hello world'
var matchlist = matchlist(text, '^\(\S\+\)\s\+\(\S\+\)')
var word1: string
var word2: string
if matchlist == []
    [word1, word2] = ['', '']
else
    [word1, word2] = matchlist
endif
```
---

As you can see, it makes the code more verbose.
Use `matchlist()` only if it improves the performance of your code significantly.
There's no easy way to know that in advance, so you'll have to make some quick tests.

---

Note that being able to use `matchlist()` requires that:

   - the substrings are all extracted from the same string

   - they can't overlap

   - they are always ordered in the same way
     (otherwise writing a pattern gets too complex)

##
# Pitfalls
## `:echo 'hello' " some comment` raises `E114`!

    echo 'hello' " some comment
    E114: Missing quote: " some comment˜

`:echo[m]` sees a double quote as part of its argument.
Therefore, you can't append a comment like you could with other commands:

    :y_ " some comment

You need a bar to explicitly tell  `:echo[m]` that what follows is *not* part of
its argument; see `:help :comment`.

    echo 'hello' | " some comment
    hello˜
