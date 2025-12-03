vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/configgrep.vim'
import autoload '../autoload/fzgrep.vim'
import autoload '../autoload/grep.vim'
import autoload '../autoload/mangrep.vim'
import autoload '../autoload/vimgrep.vim' as _vimgrep

# Mappings {{{1

# grep word under cursor, recursively in all the files of CWD
nnoremap <expr> <Bar>g grep.Operator()

# same thing for visual selection
# Do not use `!g` for the `LHS`.{{{
#
# It would  introduce some  lag whenever  we press `!`  to filter  some visual
# selection.  We  would need  to wait,  or press the  second character  of our
# command to see the bang on the command-line.
#}}}
xnoremap <expr> <Bar>g grep.Operator()

# Commands {{{1
# `:ConfigGrep` {{{2

# Search for a pattern inside all our configuration files.
# Usage:
#
#     :ConfigGrep \<test\>
#     :ConfigGrep -filetype=bash \<esac\>
command -nargs=1 -complete=custom,configgrep.Complete ConfigGrep configgrep.Main(<q-args>)
cnoreabbrev <expr> cg getcmdtype() == ':' && getcmdpos() == 3 ? 'ConfigGrep' : 'cg'
#                  ^^
# Consistent   with   our  `cg`   shell   abbreviation   which  expands   into
# `config grep`; the latter serves a similar purpose.

# `:FzGrep` {{{2

# Don't install a mapping for this command.
# It can be too slow when we don't supply a pattern.
command -nargs=1 -complete=custom,grep.Complete FzGrep fzgrep.Main(<q-args>)
cnoreabbrev <expr> fg getcmdtype() == ':' && getcmdpos() == 3 ? 'FzGrep' : 'fg'

# `:Grep` {{{2

# Usage: `:Grep 'pat' file ...` (like `grep(1)`).
# I have an improvement idea!  I just need to tweak the definitions of the commands...{{{
#
# OK, but remember:
#
#    1. The new synopsis should be identical to the one of `grep(1)`.
#
#       I.e.:
#       It should let us pass a quoted pattern, or an unquoted one.
#       It should let us pass the files/directories which we want to `grep(1)`.
#
#    2. If you hesitate between several implementations, have a look at how
#       `:CFind` is implemented in `vim-eunuch`.
#}}}
# How to search for a pattern containing a single quote?{{{
#
# Like with `grep(1)`.
# For example, if you want to grep `a'b"c`, run:
#
#     :Grep 'a'\''b"c'
#}}}
command -nargs=1 -complete=custom,grep.Complete Grep grep.Main(<q-args>)
cnoreabbrev <expr> G getcmdtype() == ':' && getcmdpos() == 2 ? 'Grep' : 'G'
#                  ^
# Don't use `g`.  It would be triggered when we want to execute `g/pat/cmd`.

# `:ManGrep` {{{2

command -nargs=? -complete=custom,mangrep.Complete ManGrep mangrep.Main(<q-args>)

cnoreabbrev <expr> mg getcmdtype() =~ '[:>]' && getcmdpos() == 3 ? 'ManGrep' : 'mg'
augroup ManGrep
    autocmd!
    autocmd FileType fish {
        cnoreabbrev <buffer><expr> mg getcmdtype() =~ '[:>]' && getcmdpos() == 3 ? 'ManGrep --apropos=fish' : 'mg'
    }
augroup END

# `:VimGrep` {{{2

# This is a wrapper around `:vimgrep` to make it async.
# Where did you get the inspiration?{{{
#
# https://github.com/mhinz/vim-grepper/issues/5#issuecomment-260379947
#}}}
# Do *not* give the attribute `-complete=file` to your commands!{{{
#
# It would cause Vim to expand `%` and `#` (possibly others) into the current or
# alternate filename.   This is especially  troublesome for `\%` which  is often
# used  in  regexes,  because  the  backslash would  be  removed  (it  would  be
# interpreted as meaning: “take the following special character as a literal one”).
#
#     :command -nargs=* -complete=file Cmd echomsg <q-args>
#     :Cmd a\%b
#     a%b
#}}}
command -nargs=* VimGrep _vimgrep.Main(<q-args>)
cnoreabbrev <expr> vg getcmdtype() == ':' && getcmdpos() == 3 ? 'VimGrep' : 'vg'
# }}}1
# Functions {{{1
def g:ConfigFileTypes() # {{{2
# Generate the cache mapping filetypes to config files.

    if $CONFIG_FILETYPES == ''
        return
    endif

    # turn off various features to speed up buffers' loading
    filetype plugin indent off
    syntax off
    &eventignore = 'BufEnter,BufWinEnter,FileType'
    &swapfile = false

    var filetype_detection: dict<list<string>>
    for file: string in systemlist('config ls-files')
        var buf: number = file->bufadd()
        buf->bufload()
        var filetype = getbufvar(buf, '&filetype')
        bwipeout!

        if filetype == ''
            continue
        endif

        if !filetype_detection->has_key(filetype)
            filetype_detection[filetype] = []
        endif
        if filetype_detection[filetype]->index(file) == -1
            filetype_detection[filetype]->add(file)
        endif
    endfor

    [filetype_detection
        ->json_encode()]
        ->writefile($CONFIG_FILETYPES)

    quitall!
enddef
