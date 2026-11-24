vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# TODO: Try to implement these:{{{
#
#    - kill-region (zle)                ???
#    - quote-region (zle)               M-"
#    - yank-nth-arg                     M-C-y
#
# Source:
# `man zshzle`
# https://www.gnu.org/software/bash/manual/html_node/Bindable-Readline-Commands.html (best?)
# https://cnswww.cns.cwru.edu/php/chet/readline/readline.html
#}}}

import 'lg/mapping.vim'
import autoload '../autoload/readline.vim'
import autoload '../autoload/readline/OperateAndGetNext.vim'

# Autocmds {{{1

augroup InstallAddToUndolist
    autocmd!
    autocmd CmdlineEnter,InsertEnter * {
        execute 'autocmd! InstallAddToUndolist'
        readline.AddToUndolist()
    }
augroup END

augroup OperateAndGetNext
    autocmd!
    # Why a timer?{{{
    #
    # To avoid remembering commands which  we haven't executed manually like the
    # ones in mappings.
    #}}}
    autocmd CmdlineEnter : timer_start(0, (_) => OperateAndGetNext.Remember('onLeave'))
augroup END

# Mappings {{{1
# Try to always preserve breaking undo sequence.{{{
#
# Most of these mappings take care of not breaking the undo sequence (`C-g U`).
# It means we can repeat an edition with the dot command, even if we use them.
# If you add another mapping, try to not break the undo sequence.  Thanks.
#}}}
# Ctrl {{{2
# C-_        undo {{{3

# Why don't you use an `<expr>` mapping?{{{
#
# Using  `<expr>`  would  make  the  code of  `readline.Undo()`  a  little  more
# complicated.
#}}}
cnoremap <unique> <C-_> <C-\>e <SID>readline.Undo()<CR>
inoremap <unique> <C-_> <ScriptCmd>readline.Undo()<CR>

# C-a        beginning-of-line {{{3

noremap! <expr><unique> <C-A> readline.BeginningOfLine()

# `:help c^a` dumps all the matches on the command-line.
# `:help i^a` inserts the previously inserted text.
# They're both overridden  by the previous mapping.  Let's  restore the features
# by mapping the commands to `C-X C-A`.
noremap! <expr><unique> <C-X><C-A> readline.CxCa()

# `:help c^a` can dump too many matches to fit on the screen.
# Let's  define  a custom  `C-x C-d`  to  capture all  of  them  in the  unnamed
# register.
cnoremap <unique> <C-X><C-D> <C-A><ScriptCmd>setreg('"', [getcmdline()], 'l')<CR><C-C>

# C-b        backward-char {{{3

noremap! <expr><unique> <C-B> readline.BackwardChar()

# C-d        delete-char {{{3

cnoremap <unique><expr> <C-D> readline.DeleteChar()
inoremap <unique><expr> <C-D> readline.DeleteChar()

# C-e        end-of-line {{{3

inoremap <expr><unique> <C-E> readline.EndOfLine()
cnoremap <expr><unique> <C-E> wildmenumode() ? '<C-Y><C-E>' : '<C-E>'

# C-f        forward-char {{{3

&cedit = ''
noremap! <expr><unique> <C-F> readline.ForwardChar()

# C-h        backward-delete-char {{{3

noremap! <expr><unique> <C-H> readline.BackwardDeleteChar()

# C-k        kill-line {{{3

noremap! <expr><unique> <C-K> readline.KillLine()

# We lost `:help i^k`; restore the feature on `<C-G><C-D>`.
inoremap <unique> <C-G><C-D> <C-K>
# Do *not* map `<C-G><C-D>` in command-line mode.
# It would  interfere with our `<C-G>`  mapping which lets us  cycle between a
# set of given commands.  We only need the feature in insert mode anyway.

# C-o        operate-and-get-next {{{3

# Also called `accept-line-and-down-history` by zle.
cnoremap <expr><unique> <C-O> OperateAndGetNext.Main()

# C-t        transpose-chars {{{3

noremap! <expr><unique> <C-T> readline.TransposeChars()

# C-u        unix-line-discard {{{3

noremap! <expr><unique> <C-U> readline.UnixLineDiscard()

# C-w        backward-kill-word {{{3

noremap! <expr><unique> <C-W> readline.BackwardKillWord()

# C-x C-e    edit-and-execute-command {{{3

# Restore default C-f on the command-line (using C-x C-e){{{
# Isn't `q:` enough?
#
# No.
# What if  we're in the middle  of a command, and  we don't want to  escape then
# press `q:`? And  what if  we're on  the expression  command-line,  opened from
# insert mode?  There's no default key  binding to access the expression command
# line window (no `q=`).
#}}}
# Why C-x C-e?{{{
#
# To stay consistent with  how we open the editor to edit the  command-line in a
# shell.
#}}}
# Why not simply assigning `"\<C-X>\<C-E>"` to `'cedit'`?{{{
#
# I think this option accepts only 1 key.
# If you give it 2 keys, it will only consider the 1st one.
# So, here's what will happen if you press `C-x`:
#
#   - Vim waits for more keys to be typed because we have mappings beginning with `C-x`
#   - we press `C-g`
#   - assuming `C-x C-g` is not mapped to anything Vim will open the command-line window ✘
#
#     Not because `&cedit = "\<C-X>\<C-G>"` (which  is not the case anyway), but
#     because the 1st key in `&cedit` matches the previous key we pressed.
#
#     This is wrong, Vim should open the command-line window *only* when we press `C-x C-e`.
#}}}
cnoremap <unique> <C-X><C-E> <ScriptCmd>readline.EditAndExecuteCommand()<CR>

# C-y        yank {{{3

# Whenever we delete some multi-character text, with:
#
#    - M-d
#    - C-w
#    - C-k
#    - C-u
#
# ... we should be able to paste it with `C-y`, like in readline.

noremap! <expr><unique> <C-Y> readline.Yank()

# Tab {{{3

# By default, when you search for a  pattern, `C-G` and `C-T` allow you to cycle
# through all  the matches,  without leaving the  command-line.  We  remap these
# commands to `Tab` and `S-Tab` on the search command-line.

# Also, on the Ex command-line, `Tab` can expand wildcards.
# But sometimes there are  too many suggestions, and we want to  get back to the
# command-line prior to the expansion, and refine the wildcards.
# We use our  `Tab` mapping to save  the command-line prior to  an expansion, so
# that `C-_` can restore it on-demand.
cnoremap <expr><unique> <Tab> readline.Tab()
cnoremap <expr><unique> <S-Tab> readline.Tab(false)
# }}}2
# Meta {{{2
# M-b/f      forward-word    backward-word {{{3

# We can't use this:
#
#     cnoremap <M-B> <S-Left>
#     cnoremap <M-F> <S-Right>
#
# Because it seems to consider `-` as part of a word.
# `M-b`, `M-f` would move too far compared to readline.

# `SPC C-h` closes the wildmenu if it's open
var rhs: string = ' (wildmenumode() ? "<Space><C-H>" : "") .. readline.MoveByWords(false)'

execute mapping.Meta('cnoremap <expr><unique> <M-B> ' .. rhs)
execute mapping.Meta('cnoremap <expr><unique> <M-F> '
    .. rhs->substitute('false', 'true', '')
          ->substitute('left', 'right', ''))

execute mapping.Meta('inoremap <expr><unique> <M-B> readline.MoveByWords(false)')
execute mapping.Meta('inoremap <expr><unique> <M-F> readline.MoveByWords()')

# M-i        capitalize-word {{{3

# If you want to use `M-u` as a prefix, remember to `<Nop>` it.{{{
#
#     nnoremap <M-U> <Nop>
#     noremap! <M-U> <Nop>
#     xnoremap <M-U> <Nop>
#}}}

execute mapping.Meta('cnoremap <unique> <M-I>'
    .. ' <C-\>e <SID>readline.MoveByWords(v:true, v:true)<CR>')

execute mapping.Meta('inoremap <silent><unique>'
    .. ' <M-I>'
    .. ' <C-R>=<SID>readline.MoveByWords(v:true, v:true)<CR>')

execute mapping.Meta('nnoremap <expr><unique> <M-I> readline.MoveByWords(true, true)')
execute mapping.Meta('xnoremap <unique> <M-I>'
    .. ' <C-\><C-N><ScriptCmd>silent keepjumps keeppatterns'
    .. ' :* substitute/\%V.\{-}\zs\(\k\)\(\k*\%V\k\=\)/\u\1\L\2/ge<CR>')

# M-u M-o    change-case-word {{{3

execute mapping.Meta('cnoremap <unique> <M-O> <C-\>e <SID>readline.ChangeCaseWord()<CR>')

execute mapping.Meta('inoremap <silent><unique>'
    .. ' <M-O>'
    .. ' <C-R>=<SID>readline.ChangeCaseWord()<CR>')

execute mapping.Meta('xnoremap <unique>'
    .. ' <M-O>'
    .. ' <C-\><C-N><ScriptCmd>silent keepjumps keeppatterns :* substitute/\%V[A-Z]/\l&/ge<CR>')

execute mapping.Meta('nnoremap <expr><unique> <M-O> readline.ChangeCaseWord()')

execute mapping.Meta('cnoremap <unique> <M-U> <C-\>e <SID>readline.ChangeCaseWord(v:true)<CR>')

execute mapping.Meta('inoremap <silent><unique>'
    .. ' <M-U>'
    .. ' <C-R>=<SID>readline.ChangeCaseWord(v:true)<CR>')

execute mapping.Meta('xnoremap <unique> <M-U> U')
# Do *not* install a mapping for `M-u` in normal mode.{{{
#
# It would not work, or it would break another mapping which we already install in:
#
#     ~/.vim/pack/mine/opt/window/plugin/window.vim
#
# Don't worry; the latter is able to uppercase a word.
#}}}

# M-d        kill-word {{{3

# Delete until the beginning of the next word.
# In bash, M-d does the same, and is bound to the function kill-word.

execute mapping.Meta('noremap! <expr><unique> <M-D> readline.KillWord()')

# M-n/p      history-search-forward/backward {{{3

execute mapping.Meta('cnoremap <expr><unique> <M-N> wildmenumode() ? "<Right>" : "<Down>"')
execute mapping.Meta('cnoremap <expr><unique> <M-P> wildmenumode() ? "<Left>" : "<Up>"')

# M-t        transpose-words {{{3

execute mapping.Meta('cnoremap <unique> <M-T> <C-\>e <SID>readline.TransposeWords()<CR>')

execute mapping.Meta('inoremap <silent><unique>'
    .. ' <M-T>'
    .. ' <C-R>=<SID>readline.TransposeWords()<CR>')

execute mapping.Meta('nnoremap <expr><unique>'
    .. ' <M-T>'
    .. ' readline.TransposeWords()')

# M-y        yank-pop {{{3

execute mapping.Meta('noremap! <expr><unique> <M-Y> readline.Yank(true)')
