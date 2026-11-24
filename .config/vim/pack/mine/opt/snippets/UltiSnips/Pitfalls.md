# I have a very long line in my snippet.  It's hard to read, and it breaks syntax highligting!

Use a VimL interpolation whose return value is an empty string.
It won't add anything to the snippet, but you can break it on several lines:

    some very long line

    ⇒

    some very `!v ''
    `long line

# `\U` doesn't work in the replacement field of a substitution in a mirror!

Use `\E`, even if you don't need it.

    snippet th "Text Header" bm
    .TH $1 ${1/.*/\U$0\E/}
    endsnippet

# I have visual artifacts after expanding a snippet!

MRE:

    snippet foo "" bm
    ${1:a}`!v system('lsb_release -d')`
    endsnippet

Expand `foo`,  press Escape, then  keep pressing `l` to  move the cursor  to the
right: some `l` and digits characters are printed on the screen (text buffer and
status line).

---

Solution:

Does your snippet insert the output of a shell command?
If so, try to save the info in a variable and refer to it in your snippet.
Obviously, this  is only possible for  an info which doesn't  change during your
Vim session.

New snippet:

    snippet foo "" bm
    ${1:a}`!v g:my_ultisnips_info['lsb_release -d']`
    endsnippet

VimL autocmd and function:

    augroup ulti_save_info
        autocmd!
        autocmd User UltiSnipsEnterFirstSnippet call s:save_info()
    augroup END

    fu! s:save_info() abort
        if exists('g:my_ultisnips_info')
            return
        endif
        let g:my_ultisnips_info = {
            \ 'lsb_release -d': matchstr(systemlist('lsb_release -d')[0], '\s\+\zs.*'),
            \ }
    endfu

Here, we save the output of `systemlist('lsb_release -d')` in a global Vim dictionary.
We use a dictionary, because we may need the output of other shell commands in our snippet.
And we delay the creation of the dictionary to the first time we enter a snippet
in order to avoid increasing Vim's startup time.
