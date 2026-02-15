# What's the purpose of this directory?

From `:help pythonx`:

   > If you want to use a module, you can put it in the `{rtp}/pythonx` directory.
   > See `|pythonx-directory|`.

So, it can be used to store custom python modules, in which you define functions
that you will invoke from your snippets.

# If I modify a function, does Vim catch the change immediately?

No, you have to restart the session.

# Does UltiSnips pre-import some modules in the scope of a custom python module?

No.

If you need a particular module in one of your helper function, import it at the
beginning of the file.

# How to access the `snip` object from a function?

You must pass it as an argument from the snippet definition:

                      `snip` is passed to `func()` as an argument
                      v
    post_expand "func(snip)"
    snippet foo "" bm
    endsnippet

# How to capture the value of a variable in `g:d_ebug`?

    vim.command('let g:d_ebug = ' + '"' + str(var) + '"')

`str()` must be invoked to cast `var` into a string.

Contrary to  Vim's `string()`, if `var`  is already a string,  `str()` won't add
quotes inside it.
A double invocation won't have any effect:

    str(str(var))
    ✘

Which is why, here, you need to concatenate two double quotes.

    '"' + str(var) + '"'
    ✔

# How to dump the value of a variable in a file?

    with open('/tmp/debug','w') as f:
        f.write(str(var))

This command seems more reliable compared to the previous one.
Probably because  a variable  can contain  double quotes,  which break  the VimL
expression in the value of the `:let g:d_ebug` assignment.

# Is it possible to prevent UltiSnips from consuming the tab trigger?

Only  if you  use a  `pre_expand`  statement, and  from the  expression/function
invoked by the latter, you invoke one of these:

   - snip.cursor.preserve()

   - snip.expand_anon()

# How to remove the tab trigger if UltiSnips didn't do it?   (assuming it's alone on the line)

    snip.buffer[snip.line] = ''
