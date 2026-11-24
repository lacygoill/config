vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/goyo.vim'

# Mappings {{{1

# FIXME: If I press `SPC gg` in GUI, tmux status line gets hidden.  It should stay visible.
# FIXME: If I press  `SPC gg` in an  unzoomed tmux pane, then press  it again to
# leave goyo mode, the pane is zoomed.  The zoomed state should be preserved.
nnoremap <unique> <Space>gg <ScriptCmd>goyo.Start()<CR>
nnoremap <unique> <Space>gG <ScriptCmd>goyo.Start(false)<CR>

# Commands {{{1

# TODO: Implement a version of the command in which no text is dimmed.
# All the text is in black; but the  status lines and all the rest of the visual
# clutter is still removed.
# Or, implement a mapping which would cycle between different submodes of the goyo mode:
#
#    - no syntax highlighting, no dimming
#    - no syntax highlighting, dimming
#    - syntax highlighting, no dimming
#    - syntax highlighting, dimming
#    ...
command -nargs=? -bar -bang Goyo goyo.Execute(<bang>0, <q-args>)

# Autocmds {{{1

augroup MyGoyo
    autocmd!
    autocmd User GoyoEnter goyo.Enter()
    autocmd User GoyoLeave goyo.Leave()
    autocmd VimLeave * if exists('#goyo') | goyo.Leave() | endif
augroup END
