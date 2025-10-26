# What are the 3 types of abbreviations?

    ┌─────────┬───────────────────────────────────────────────┬────────────────┐
    │ type    │ description                                   │ examples       │
    ├─────────┼───────────────────────────────────────────────┼────────────────┤
    │ full-id │ all the characters must be in 'iskeyword'     │ foo   g3   -1  │
    ├─────────┼───────────────────────────────────────────────┼────────────────┤
    │ end-id  │ the last character must be in 'iskeyword',    │ #i   ..f   $/7 │
    │         │ the other ones must NOT                       │                │
    ├─────────┼───────────────────────────────────────────────┼────────────────┤
    │ non-id  │ the last character must NOT be in 'iskeyword' │ def#   4/7$    │
    │         │ the others can be in 'isk' or not             │                │
    └─────────┴───────────────────────────────────────────────┴────────────────┘

#
# Which condition must the character BEFORE an abbreviation satisfy, for the abbreviation to be expanded?

It must be either:

   - a whitespace
   - a beginning of line (yes, it's not a real character then...)
   - outside 'isk' and the abbreviation is full-id
   - in 'isk' and the abbreviation is end-id
   - anything, but the abbreviation is written right after entering insert mode

# Which condition must the character AFTER an abbreviation satisfy, for the abbreviation to be expanded?

It must not be in `'isk'`, or it must be `C-]`.

#
# How to prevent an abbreviation from being expanded?

Insert the trigger literally:

    C-v SPC

# How to clear all buffer-local abbreviations in command-line mode?

    :cabclear <buffer>

##
# When is the triggering space executed?  Before or after the abbreviation has been expanded?

After.

    $ vim -Nu NONE +'inoreabbrev <expr> a "b" .. feedkeys("c", "n")[-1]'
    " press:  i a SPC
    " result: 'b c'

`c` can come after  the space only if the latter had not  been executed when the
abbreviation was expanded.  Otherwise, the result would have been `bc `.

The same is true for a CR which expands a command-line abbreviation:

    $ vim -Nu NONE +'cnoreabbrev ab split'
    :ab Enter
    " Vim correctly splits the window

If the CR had already been executed, then `split` would have been executed while
Vim was in normal  mode, and it would not have split the  window; but the window
*is* split, so the hypothesis is wrong.

## When is it written in the typeahead?

Immediately.

---

It could be written:

   1. immediately
   2. after the RHS of the abbreviation has been written in the typeahead
   3. after the RHS of the abbreviation has been executed from the typeahead

The previous  experiment rules  out `2.` and  `3.` (i.e. if  they were  true, we
would get `bc `).

##
# How to manually expand an existing abbreviation without a space being inserted at the end?

Press `C-]`.

## How to redefine my abbreviation so that it's done automatically?

In the RHS of the abbreviation, consume the space with `getchar()`.

Example:

    function s:eat_space()
       let c = getchar(0)->nr2char()
       return c =~# '\s' ? '' : c
    endfunction
    inoreabbrev <silent> if if ()<left><c-r>=<sid>eat_space()<cr>

Here's what happens:

   - you type `i`; it's written in the typeahead buffer, then executed (i.e. inserted in the user buffer)
   - you type `f`; same thing
   - you type space which should be a non-keyword character:

       * it's written in the typeahead buffer
       * Vim checks whether the text before the cursor matches an abbreviation

       * it finds one; as a result, it removes its LHS from your buffer, and
         inserts its RHS into the typeahead; i.e. `if` is removed from your buffer,
         and `if ()<left><c-r>=<sid>eat_space()<cr>` is inserted in the typeahead
         in front of the space

       * the typeahead is executed, and when `<c-r>=<sid>eat_space()<cr>` is executed,
         `s:eat_space()` consumes the last remaining space from the typeahead (via `getchar()`)

       * the typeahead buffer is now empty, and the space is not executed
         (i.e. inserted in the regular buffer)

You may wonder why `if ()...` is written in the typeahead buffer.
I think  it has  to, because if  you define a  recursive abbreviation  (`iab` vs
`inorea`), mappings are applied; that can only happen in the typeahead buffer.

For more info, see `:helpgrep Eatchar`.

---

You could probably replace this line:

    return c =~# '\s' ? '' : c

With:

    return ''

However, if  you were to  use `s:eat_space()`  in another abbreviation,  and for
some  reason you  wanted to  use it  in  a different  position in  the RHS,  the
function  could wrongly  consume some  non-whitespace character  which would  be
unexpected.   So the  current statement,  while not  necessary here,  is a  good
practice.

---

The  fact  that  `getchar()`  consumes   the  typeahead  buffer  is  not  really
documented, but it's briefly mentioned at `:help :map-<expr> /typeahead`:

   > You can use getchar(), it consumes typeahead if there is any.

Besides, from where else would `getchar()` consume a key?

### Why the `0` argument?

                    v
    let c = getchar(0)->nr2char()

It  prevents `getchar()`  from waiting  for  a character  to be  written in  the
typeahead buffer when the latter is empty:

   - if there's one, it consumes it
   - if there's none, it bails out

It's necessary when you expand an abbreviation via `C-]`.
This suggests that `C-]`  is not written in the typeahead  buffer (but the space
is, which is expected).

### How do you know that the RHS of the abbreviation is *inserted* in the typeahead?

The  only other  alternative would  be  that Vim  uses  the RHS  to replace  the
triggering space in the typeahead.

    SPC
    →
    RHS + SPC

But this is ruled out by this experiment:

    $ vim -Nu NONE +'inoreabbrev <expr> a "b" .. feedkeys("c", "in")[-1]'
    " press: i a SPC
    " result: 'bc '

If the  space was  replaced by  the RHS of  the abbreviation  followed by  a new
space, the typeahead would end up containing `c b SPC`:

    typeahead
    ---------
        SPC    (typed interactively; triggers the expansion of the abbreviation)
    c   SPC    ('c' is inserted by 'feedkeys()' during the evaluation of the RHS)
    c b SPC    (SPC is replaced by the RHS, here 'b', followed by a new space)

This contents contradicts the previous result (i.e. `bc `).
Here is what really happens:

    typeahead
    ---------
        SPC    (typed interactively; triggers the expansion of the abbreviation)
      c SPC    ('c' is inserted by 'feedkeys()' during the evaluation of the RHS)
    b c SPC    (the RHS is inserted)

##
# Why should I avoid installing an abbreviation whose LHS matches a builtin Ex command?

It might be unexpectedly expanded if you  use a recursive mapping which tries to
execute a builtin Ex command.
```vim
vim9script
nmap <F3> :echomsg 'no issue'<CR>
cnoreabbrev echomsg invalid
feedkeys("\<F3>")
```
    Expected: 'no issue'
    Actual: E492: Not an editor command: invalid 'no issue'
