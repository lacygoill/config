# Move snippets which explain some rule/concept or list some common syntaxes into a Wiki.

A snippet should always insert actual usable code.

# ?


Tweak the ultisnips  statusline indicator so that it displays  the number of the
current tabstop, and the number of the last tabstop:

    [Ulti] 12/34

---

Document the `append()` method of the `snip.buffer` object.

It's not documented in the help.
It's just used in a single example:

                                                        v--------v
    pre_expand "del snip.buffer[snip.line]; snip.buffer.append(''); snip.cursor.set(len(snip.buffer)-1, 0)"
    snippet x
    def $1():
            ${2:${VISUAL}}
    endsnippet

---

Learn how to use `pyrasite` to debug python code used in a snippet:

    https://www.reddit.com/r/vim/comments/am8dc9/writing_python_plugins_i_wish_i_had_known_about/
    https://github.com/lmacken/pyrasite

---

Read these PRs:

    pre/post-expand and post-jump actions

            https://github.com/SirVer/ultisnips/pull/507

    Autotrigger

            https://github.com/SirVer/ultisnips/pull/539

And this issue:

    Markdown table snippet breaks on various dimensions

            https://github.com/SirVer/ultisnips/issues/877

And this one:

            https://vi.stackexchange.com/questions/11240/ultisnips-optional-line

---

Watch all gifs from `vim-pythonx` and `vim-snippets`.
Re-read all your snippets (fix/improve).
Re-read this file.
Understand 3 advanced examples:

        https://github.com/SirVer/ultisnips/tree/master/doc/examples/autojump-if-empty
        https://github.com/SirVer/ultisnips/tree/master/doc/examples/snippets-aliasing
        https://github.com/SirVer/ultisnips/tree/master/doc/examples/tabstop-generation

Read documentation.


The following events:

    UltiSnipsEnterFirstSnippet
    UltiSnipsExitLastSnippet

... are NOT fired  when the snippet is  automatically expanded (like with  `fu` in a
vim file).
At least, it seems so.
Make some tests.
Document the results.
It may be a bug.
Report it.

---

https://github.com/reconquest/vim-pythonx/ (1163 sloc, after removing `tests` and all `__init__.py` files)
https://github.com/reconquest/vim-pythonx/issues/11

        Python library

https://github.com/reconquest/snippets

        Snippets

https://github.com/SirVer/ultisnips/pull/507

        PR: pre/post-expand and post-jump actions

https://github.com/seletskiy/dotfiles/blob/8e04f6a47fa1509be96094e5c8923f4b49b22775/.vim/UltiSnips/go.snippets#L11-23

        Interesting snippet.

                “It   covers  all   three   cases   using  one   single-character
                trigger. You don't need to remember three different snippets.”

---

Create   snippets  for   `context`,  `pre_expand`,   `post_expand`,  `post_jump`
statements and for interpolations.
Your goal  should be to  teach them everything  you know about  those statements
(which variables/methods can be used).
This way, no more: “what the fuck was  the name of the variable to refer to last
visual text”?

---

Document the `w` option.
Answer the question:

> By default,  a tab  trigger is  only expanded if  it's a  whole word,  so what
> difference does `w` make?

Answer:
By default, the tab trigger must be preceded by a whitespace.
With `w`, any character outside `'isk'` will do.

---

Every  time  you've  noted  that  something doesn't  work  in  an  interpolation
(inaccessible variable, method), check whether  you can bypass the limitation by
creating a simple helper function.
That's what is done here:

<https://github.com/SirVer/ultisnips/blob/master/doc/examples/snippets-aliasing/README.md>

... to access `vim.current.window.buffer` and `vim.current.window.cursor` inside
an interpolation.

Edit:  In fact, there's no need of a helper function, `vim.current.window` works
directly from an interpolation.
