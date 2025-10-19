vim9script

import autoload '../../autoload/snippets.vim'
import autoload $'{$HOME}/.vim/autoload/myfuncs.vim'

# Autocmds {{{1

augroup FormatSnippets
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> {
        # We don't  care about the  trigger of some  snippets, because we  don't use
        # them frequently  enough to  remember it.  Instead,  we use  `vim-fuzzy` to
        # look for some pattern in their description.
        #
        # When we don't care about the trigger, we use `t123`.
        # But we need to make sure:
        #
        #    - it's unique in the current file
        #    - it's chosen so that the triggers are ordered numerically
        #      (otherwise, the file looks untidy)
        snippets.FixNumberedTriggers()
        # Escape backticks if they're used for a commented codespan inside a snippet.{{{
        #
        #     snippet ...
        #     # some \`codespan\`
        #            ^         ^
        #     endsnippet
        #
        # Otherwise, UltiSnips would wrong parse `codespan` as a shell command to run.
        #}}}
        snippets.FixWrongBacktickInterpolations()
        # Execute `:RemoveTabs` in global blocks to avoid "IndentationError: unexpected indent" errors.{{{
        #
        # In a snippet file, we reset `'expandtab'`, because:
        #
        #   1. Tabs have  a special  meaning for UltiSnips  (“increase the
        #      level of indentation of the line“)
        #
        #   2. we sometimes forget to insert a Tab inside a snippet when it's needed
        #
        # So whenever you  press `Tab` to increase the indentation  of a line,
        # you insert a literal `Tab` character.
        # This is what  we want inside a  snippet (`snippet`/`endsnippt`), but
        # *not* in a python function (`global`/`endglobal`), because:
        #
        #   - PEP8 recommends spaces
        #
        #   - we could easily end up mixing tabs and spaces, when we copy
        #     paste some code, which would give an error:
        #
        #         IndentationError: unexpected indent
        #}}}
        snippets.RemoveTabsInGlobalBlocks()
    }
augroup END

# Mappings {{{1

nmap <buffer><nowait> q <Plug>(my-quit)

# Options {{{1

setlocal iskeyword+=#

# We want real tabs  in a snippet file, because they have  a special meaning for
# UltiSnips (“increase the level of indentation of the line“).
&l:expandtab = false
&l:shiftwidth = 4
&l:tabstop = &l:shiftwidth

# Variables {{{1

# Problem: The normal `%` command sometimes fails to work (or is too slow).{{{
#
# MRE1:
#
# Press `%` on the closing bracket of a dictionary:
#
#     snippet ...
#     {'key': 'value'}
#                    ^
#     endsnippet
#
# Expected: The cursor jumps to the opening bracket.
# Actual: The cursor stays on the closing bracket.
#
# MRE2:
#
#     :% delete _
#     :call setline(1, ['${1:xxx}'] + ['(${1:yyy}, ${2:zzz})']->repeat(1000))
#
# Maintain `%` pressed for 1 second while on the 1st character of the 1st line:
#
#     ${1:xxx}
#     ^
#
# Then, try to move the cursor by maintaining `l` pressed.
# You'll have to wait a few seconds before seeing the cursor moving.
#}}}
# Solution: In `b:match_words`, only keep regexes which you're interested in.{{{
#
# The cause of the issue comes from the default filetype plugin:
#
#     ~/.vim/pack/vendor/opt/ultisnips/ftplugin/snippets.vim
#
# It includes some regexes inside the  variable to support constructs which we
# aren't interested in:
#
#     call add(pairs, ['\${\%(\d\|VISUAL\)|\ze.*\\\@<!|}', '\\\@<!|}']) " ${1|baz,qux|}
#     call add(pairs, ['\${\%(\d\|VISUAL\)\/\ze.*\\\@<!\/[gima]*}', '\\\@<!\/[gima]*}']) " ${1/garply/waldo/g}
#     call add(pairs, ['\${\%(\%(\d\|VISUAL\)\:\ze\|\ze\%(\d\|VISUAL\)\).*\\\@<!}', '\\\@<!}']) " ${1:foo}, ${VISUAL:bar}, ... or ${1}, ${VISUAL}, ...
#     call add(pairs, ['\\\@<!`\%(![pv]\|#!\/\f\+\)\%( \|$\)', '\\\@<!`']) " `!p quux`, `!v corge`, `#!/usr/bin/bash grault`, ... (indicators includes a whitespace or end-of-line)
#}}}
b:match_words = '^snippet\>:^endsnippet\>,^global\>:^endglobal\>'

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call snippets#UndoFtplugin()'
