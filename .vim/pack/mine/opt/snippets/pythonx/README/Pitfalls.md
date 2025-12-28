# I get this error: “line under the cursor was modified, but "snip.cursor" variable is not set”!

This issue arises when  you modify the line of the  tab trigger, without setting
the new position of the cursor.

Invoke one of these:

    snip.cursor.preserve()
    snip.cursor.set(snip.cursor[0], snip.cursor[1])

---

MRE:

    global !p
    def func(snip):
        if 'foobar' in vim.current.buffer.name:
            anon_snip_body = 'hello world'
        else:
            snip.cursor.preserve()
            return

        snip.buffer[snip.line] = ''
        snip.expand_anon(anon_snip_body)
    endglobal

    pre_expand "func(snip)"
    snippet ab "" Abm
    endsnippet

This snippet  expands the tab trigger  `ab` into `hello world` if,  and only if,
the path to the current file contains the word `foobar`.

# I try to compare the output of `vim.eval('VimL expr')` to a number, but it fails!

The output of `vim.eval()` is a string not a number.

You need to convert it into a number using the `int()` function:

       ✘
       v
    if vim.eval('VimL expr') == 123:

       ✔
       v
    if int(vim.eval('VimL expr')) == 123:
