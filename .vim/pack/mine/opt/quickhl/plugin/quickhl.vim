vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# Forked from: http://github.com/t9md/vim-quickhl

import 'lg/mapping.vim'
import autoload '../autoload/quickhl.vim'
import autoload 'submode.vim'

# TODO: Make highlights persistent across Vim restarts.
# TODO: Don't highlight *all* the matches.  Just the one under the cursor.
# TODO: Implement a “global” command which would extend the last highlighting to *all* the matches.{{{
#
# In fact, it should toggle between *all* the matches, and the single match under the cursor.
# `M-m M-m` would be a good fit as a mapping.
# But what would we use for highlighting a line?  `M-m _`?  `M-m M`?
#}}}
# TODO: Implement an “undo” command which would undo the last highlighting.
# FIXME: Press `M-m ^` on the first line of a file.
# Sometimes, nothing is highlighted; sometimes the second line is highlighted.

# TODO: We have no way to expand a match.{{{
#
# I.e. we can highlight a line:
#
#     M-m _
#
# We can highlight another:
#
#     M-m _
#
# But they will be colored differently.
#
# Find another prefix to add/remove a match to/from another?
#}}}
# TODO: Add a command to populate the loclist with the positions matching the first character of all the matches.{{{
#
# It would  be handy to jump  from one to another  if they are far  away, and to
# find a subset of matches we want to clear.
#
# Also, try to save the loclists across Vim restarts, and use the location lists
# created by the quickhl plugin to save the matches/highlights.
# Install a command  which would be local  to a location window  and which would
# restore the highlights  (use the context key  of each entry in  the loclist to
# distinguish a match/highlight from another).
# This way, we could restore our highlights even after quitting Vim.
#
# Edit: The location  list is unreliable,  because it doesn't follow  the text
# after an edit.  Try to use text properties in Vim.
#}}}
# TODO: Make `<M-M>c` dot repeatable.{{{
#
# It might look like it already is, but it's not.
# Press `<M-M>iw` on 3 different words, then delete a line by pressing `dd`.
# Press `<M-M>c` on a highlighted word, then press dot on another one.
# The highlight on the second word is not removed; instead a line is removed.
#}}}
# TODO: Allow the user to choose the color used for the next highlight.{{{
#
# In mappings, we could use a count.
# For example, if we press `2<M-M>_`, the current line would be highlighted in blue.
# But if we had pressed `3<M-M>_`, the current line would have been highlighted in green.
#}}}

# Settings {{{1

g:quickhl_manual_colors =<< trim END
    cterm=bold ctermfg=16 ctermbg=153 gui=bold guifg=#ffffff guibg=#0a7383
    cterm=bold ctermfg=7  ctermbg=1   gui=bold guibg=#a07040 guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=2   gui=bold guibg=#4070a0 guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=3   gui=bold guibg=#40a070 guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=4   gui=bold guibg=#70a040 guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=5   gui=bold guibg=#0070e0 guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=6   gui=bold guibg=#007020 guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=21  gui=bold guibg=#d4a00d guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=22  gui=bold guibg=#06287e guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=45  gui=bold guibg=#5b3674 guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=16  gui=bold guibg=#4c8f2f guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=50  gui=bold guibg=#1060a0 guifg=#ffffff
    cterm=bold ctermfg=7  ctermbg=56  gui=bold guibg=#a0b0c0 guifg=black
END

# Mappings {{{1

noremap <Plug>(quickhl-jump-to-next-hl) <ScriptCmd>quickhl.Next('s')<CR>
noremap <Plug>(quickhl-jump-to-prev-hl) <ScriptCmd>quickhl.Prev('s')<CR>

# highlight:{{{
#
#    - word under cursor
#    - word under cursor, adding boundaries (`\<word\>`)
#    - visual selection
#    - text covered by a motion or text-object
#    - current line
#}}}
execute mapping.Meta('nnoremap <unique> <M-M>g* <ScriptCmd>quickhl.Word("n")<CR>')
execute mapping.Meta('nnoremap <unique> <M-M>* <ScriptCmd>quickhl.WholeWord()<CR>')
execute mapping.Meta('xnoremap <unique> <M-M> <C-\><C-N><ScriptCmd>quickhl.Word("v")<CR>')
execute mapping.Meta('nnoremap <expr><unique> <M-M> quickhl.Op()')
execute mapping.Meta('nnoremap <expr><unique> <M-M><M-M> quickhl.Op() .. "_"')

# clear all highlights
execute mapping.Meta('nnoremap <unique> <M-M>C <ScriptCmd>quickhl.Reset()<CR>')
# clear highlight of the word under the cursor
execute mapping.Meta('nnoremap <unique> <M-M>c <ScriptCmd>quickhl.ClearThis("n")<CR>')
# clear highlight of the visual selection
# TODO: I don't like this RHS (`m<M-M>`).{{{
#
# Besides, it seems the whole mapping is useless.
# You can press `M-m` on the same visual selection to clear a highlight.
# What's the point of `quickhl.ClearThis()` in visual mode?
#}}}
execute mapping.Meta('xnoremap <unique> m<M-M> <C-\><C-N><ScriptCmd>quickhl.ClearThis("v")<CR>')
# toggle global lock
execute mapping.Meta('nnoremap <unique> co<M-M> <ScriptCmd>quickhl.LockToggle()<CR>')
execute mapping.Meta('nnoremap <unique> <M-M>? <ScriptCmd>quickhl.ShowHelp()<CR>')
# Don't map these keys with `:map`; it would cause an unexpected timeout for
# `<M-M>` in visual mode.
execute submode.Enter('quickhl-jump', 'n', 'r', '<F24>j', '<Plug>(quickhl-jump-to-next-hl)')
execute submode.Enter('quickhl-jump', 'n', 'r', '<F24>k', '<Plug>(quickhl-jump-to-prev-hl)')

# Commands {{{1

command -bar QuickhlManualEnable quickhl.Enable()
command -bar QuickhlManualDisable quickhl.Disable()

command -bar QuickhlManualList quickhl.List()
command -bar QuickhlManualReset quickhl.Reset()
command -bar QuickhlManualColors quickhl.Colors()

# Don't use `-bar` for commands whose argument might contain a `|` or `"`
# (which is the case when the argument is a regex).
command -bang -nargs=1 QuickhlManualAdd quickhl.Add(<q-args>, <bang>0)
command -bang -nargs=* QuickhlManualDelete quickhl.Del(<q-args>, <bang>0)
command -bar QuickhlManualLock quickhl.Lock()

command -bar QuickhlManualUnlock quickhl.Unlock()
command -bar QuickhlManualLockToggle quickhl.LockToggle()
command -bar QuickhlManualLockWindow quickhl.LockWindow()
command -bar QuickhlManualUnlockWindow quickhl.UnlockWindow()
command -bar QuickhlManualLockWindowToggle quickhl.LockWindowToggle()

command -bar -nargs=? QuickhlManualNext quickhl.Next(<f-args>)
command -bar -nargs=? QuickhlManualPrev quickhl.Prev(<f-args>)
