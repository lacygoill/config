# When a `return` is inside an `if` clause, the latter should not be terminated with `else`/`elif`.

Usually, there's a difference between these snippets:

    if cond1
        do sth
    if cond2
        do sth else

    if cond1
        do sth
    elif cond2
        do sth else

The difference  happens when  `cond1` and `cond2`  are true  simultaneously.  In
that  case, the  first  snippet  executes both  actions,  while  the second  one
executes only one action.

But this difference disappears when the action is a `return` statement.  In this
case, the first snippet executes only  one action, like the second snippet.  So,
there's no need for an `else` after a `return`:

    if cond1
        return sth
    elif cond2
        return sth else

    ⇔

    if cond1
        return sth
    if cond2
        return sth else

---

This kind of refactoring is useful to  reduce the indentation level of the code,
making  it  more readable.   The  longer  the 2nd  `else`  clause  is, the  more
noticeable the benefit is.

---

See also:

- <https://github.com/soimort/translate-shell/wiki/AWK-Style-Guide>
- <https://softwareengineering.stackexchange.com/questions/157407/best-practice-on-if-return#comment300476_157407>


---

Warning: That doesn't mean that you can refactor this:

    if A
        ...
    elif ...
        return ...
    else
        B

Into this:

    if A
        ...
    elif ...
        return ...
    B

In the 1st snippet, `B` is only run if `A` is false.
In the 2nd snippet, `B` is run unconditionally.

---

It's tricky  to find  such "mistakes".  `return` must be  inside an  `if` clause
(which might have started much earlier); not inside an `else`/`elif`.

Besides, the `return` line might not be  right above the end of the clause.  For
example, there might be  a comment or the returned expression  might be split on
multiple lines.

Leave that to your linter.  For Python, `pylint(1)` can find them.

## Same thing for any statement which makes execution jump to another location, like `break` and `continue`.
