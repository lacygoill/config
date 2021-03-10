let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
argglobal
%argdel
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabnew
tabrewind
edit ~/wiki/awk/sed.md
set splitbelow splitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt ~/wiki/awk/sed.md
let s:l = 72 - ((71 * winheight(0) + 6) / 13)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 72
normal! 0
lcd ~/wiki/awk
tabnext
edit ~/.vim/plugged/vim-cheat/ftplugin/cheat.vim
set splitbelow splitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt ~/.vim/plugged/vim-cheat/ftplugin/cheat.vim
let s:l = 1 - ((0 * winheight(0) + 6) / 13)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 0
lcd ~/.vim/plugged/vim-cheat
tabnext
edit ~/Desktop/ask.md
set splitbelow splitright
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/Desktop/ask.md
let s:l = 899 - ((7 * winheight(0) + 5) / 11)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 899
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/wiki/vim/config.md") | buffer ~/wiki/vim/config.md | else | edit ~/wiki/vim/config.md | endif
balt ~/Desktop/ask.md
let s:l = 1733 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1733
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/vim/complete.md") | buffer ~/wiki/vim/complete.md | else | edit ~/wiki/vim/complete.md | endif
balt ~/Desktop/ask.md
let s:l = 139 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 139
normal! 0
lcd ~/wiki/vim
wincmd w
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/.vim/plugged/vim-vim/after/ftplugin/vim.vim
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/.vim/plugged/vim-vim/after/ftplugin/vim.vim
let s:l = 86 - ((52 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 86
normal! 0
lcd ~/.vim/plugged/vim-vim
wincmd w
argglobal
if bufexists("~/Desktop/vim.vim") | buffer ~/Desktop/vim.vim | else | edit ~/Desktop/vim.vim | endif
balt ~/.vim/plugged/vim-vim/after/ftplugin/vim.vim
let s:l = 69 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 69
normal! 0
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/.vim/plugin/README/matchup.md
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/.vim/plugin/README/matchup.md
let s:l = 947 - ((54 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 947
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/.vim/plugin/matchup.vim") | buffer ~/.vim/plugin/matchup.vim | else | edit ~/.vim/plugin/matchup.vim | endif
balt ~/.vim/plugin/README/matchup.md
let s:l = 91 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 91
normal! 0
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/Desktop/cwd.md
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/Desktop/cwd.md
let s:l = 219 - ((11 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 219
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-fex/ftplugin/fex.vim") | buffer ~/.vim/plugged/vim-fex/ftplugin/fex.vim | else | edit ~/.vim/plugged/vim-fex/ftplugin/fex.vim | endif
balt ~/Desktop/cwd.md
let s:l = 4 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 4
normal! 0
lcd ~/.vim/plugged/vim-fex
wincmd w
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/.vim/plugged/vim-unix/autoload/unix.vim
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/.vim/plugged/vim-unix/autoload/unix.vim
let s:l = 53 - ((5 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 53
normal! 0
lcd ~/.vim/plugged/vim-unix
wincmd w
argglobal
if bufexists("~/wiki/vim/shell.md") | buffer ~/wiki/vim/shell.md | else | edit ~/wiki/vim/shell.md | endif
balt ~/.vim/plugged/vim-unix/autoload/unix.vim
let s:l = 21 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 21
normal! 0
lcd ~/wiki/vim
wincmd w
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/wiki/vim/config.md
set splitbelow splitright
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/.vim/plugged/vim-completion/plugin/completion.vim
let s:l = 1537 - ((152 * winheight(0) + 5) / 11)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1537
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/vim/complete.md") | buffer ~/wiki/vim/complete.md | else | edit ~/wiki/vim/complete.md | endif
balt ~/.vim/plugged/vim-completion/plugin/completion.vim
let s:l = 451 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 451
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-completion/autoload/completion/util.vim") | buffer ~/.vim/plugged/vim-completion/autoload/completion/util.vim | else | edit ~/.vim/plugged/vim-completion/autoload/completion/util.vim | endif
balt ~/.vim/plugged/vim-completion/plugin/completion.vim
let s:l = 58 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 58
normal! 0
lcd ~/.vim/plugged/vim-completion
wincmd w
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/Desktop/refactor.md
set splitbelow splitright
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/Desktop/refactor.md
let s:l = 45 - ((5 * winheight(0) + 5) / 11)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 45
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-vim/autoload/vim/refactor/substitute.vim") | buffer ~/.vim/plugged/vim-vim/autoload/vim/refactor/substitute.vim | else | edit ~/.vim/plugged/vim-vim/autoload/vim/refactor/substitute.vim | endif
balt ~/Desktop/refactor.md
let s:l = 105 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 105
normal! 0
lcd ~/.vim/plugged/vim-vim
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-vim/test/refactor/substitute.vim") | buffer ~/.vim/plugged/vim-vim/test/refactor/substitute.vim | else | edit ~/.vim/plugged/vim-vim/test/refactor/substitute.vim | endif
balt ~/Desktop/refactor.md
let s:l = 2 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2
normal! 0
lcd ~/.vim/plugged/vim-vim
wincmd w
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/.vim/plugged/vim-quickhl/autoload/quickhl.vim
set splitbelow splitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt ~/.vim/plugged/vim-quickhl/autoload/quickhl.vim
let s:l = 81 - ((57 * winheight(0) + 6) / 13)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 81
normal! 0
lcd ~/.vim/plugged/vim-quickhl
tabnext
edit ~/wiki/vim/sign.md
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/wiki/vim/sign.md
let s:l = 78 - ((58 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 78
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/vim/popup.md") | buffer ~/wiki/vim/popup.md | else | edit ~/wiki/vim/popup.md | endif
balt ~/wiki/vim/sign.md
let s:l = 444 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 444
normal! 0
lcd ~/wiki/vim
wincmd w
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/Vcs/zsh/Misc/vcs_info-examples
set splitbelow splitright
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/Vcs/zsh/Misc/vcs_info-examples
let s:l = 155 - ((4 * winheight(0) + 5) / 11)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 155
normal! 0
lcd ~/Vcs/zsh
wincmd w
argglobal
if bufexists("~/Desktop/git-prompt.md") | buffer ~/Desktop/git-prompt.md | else | edit ~/Desktop/git-prompt.md | endif
balt ~/Vcs/zsh/Misc/vcs_info-examples
let s:l = 128 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 128
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/bin/prompt.zsh") | buffer ~/bin/prompt.zsh | else | edit ~/bin/prompt.zsh | endif
balt ~/Vcs/zsh/Misc/vcs_info-examples
let s:l = 1 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 0
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/wiki/vim/mapping.md
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/wiki/vim/mapping.md
let s:l = 2719 - ((5 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2719
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/vim/vimscript.md") | buffer ~/wiki/vim/vimscript.md | else | edit ~/wiki/vim/vimscript.md | endif
balt ~/wiki/vim/mapping.md
let s:l = 160 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 160
normal! 0
lcd ~/wiki/vim
wincmd w
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/wiki/vim/todo/todo.md
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/wiki/vim/todo/todo.md
let s:l = 3 - ((2 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 3
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/Desktop/filez") | buffer ~/Desktop/filez | else | edit ~/Desktop/filez | endif
balt ~/wiki/vim/todo/todo.md
let s:l = 21 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 21
normal! 0
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/.vim/plugged/vim-lg-lib/import/lg.vim
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/.vim/plugged/vim-lg-lib/import/lg.vim
let s:l = 179 - ((72 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 179
normal! 0
lcd ~/.vim/plugged/vim-lg-lib
wincmd w
argglobal
if bufexists("~/.vim/autoload/myfuncs.vim") | buffer ~/.vim/autoload/myfuncs.vim | else | edit ~/.vim/autoload/myfuncs.vim | endif
balt ~/.vim/plugged/vim-lg-lib/import/lg.vim
let s:l = 46 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 46
normal! 0
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 12 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/.vim/plugged/vim-stacktrace/test/compile_time.vim
set splitbelow splitright
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
argglobal
balt ~/.vim/plugged/vim-stacktrace/test/compile_time.vim
let s:l = 8 - ((7 * winheight(0) + 5) / 11)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 8
normal! 0
lcd ~/.vim/plugged/vim-stacktrace
wincmd w
argglobal
if bufexists("~/wiki/vim/vim9.md") | buffer ~/wiki/vim/vim9.md | else | edit ~/wiki/vim/vim9.md | endif
balt ~/.vim
let s:l = 1233 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1233
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/bug/vim.md") | buffer ~/wiki/bug/vim.md | else | edit ~/wiki/bug/vim.md | endif
balt ~/wiki/vim/vim9.md
let s:l = 697 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 697
normal! 0
lcd ~/wiki/bug
wincmd w
exe '1resize ' . ((&lines * 11 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/pp.log
set splitbelow splitright
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 1 + 16) / 33)
exe '2resize ' . ((&lines * 1 + 16) / 33)
exe '3resize ' . ((&lines * 9 + 16) / 33)
argglobal
balt ~/pp.log
let s:l = 2 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2
normal! 0
lcd ~/vim-scriptease
wincmd w
argglobal
if bufexists("~/vim-scriptease/plugin/scriptease.vim") | buffer ~/vim-scriptease/plugin/scriptease.vim | else | edit ~/vim-scriptease/plugin/scriptease.vim | endif
balt ~/pp.log
let s:l = 12 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 12
normal! 0
lcd ~/vim-scriptease
wincmd w
argglobal
if bufexists("~/vim-scriptease/autoload/scriptease.vim") | buffer ~/vim-scriptease/autoload/scriptease.vim | else | edit ~/vim-scriptease/autoload/scriptease.vim | endif
balt /tmp/a.vim
let s:l = 86 - ((23 * winheight(0) + 4) / 9)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 86
normal! 053|
lcd ~/vim-scriptease
wincmd w
exe '1resize ' . ((&lines * 1 + 16) / 33)
exe '2resize ' . ((&lines * 1 + 16) / 33)
exe '3resize ' . ((&lines * 9 + 16) / 33)
tabnext
edit ~/.vim/plugged/vim-exchange/autoload/exchange.vim
set splitbelow splitright
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
3wincmd k
wincmd w
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 0 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
exe '4resize ' . ((&lines * 27 + 16) / 33)
argglobal
balt ~/.vim/plugged/vim-exchange/autoload/exchange.vim
let s:l = 289 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 289
normal! 0
lcd ~/.vim/plugged/vim-exchange
wincmd w
argglobal
if bufexists("~/wiki/vim/vimscript.md") | buffer ~/wiki/vim/vimscript.md | else | edit ~/wiki/vim/vimscript.md | endif
balt ~/.vim/plugged/vim-exchange/autoload/exchange.vim
let s:l = 2069 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2069
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/vim/vimscript.md") | buffer ~/wiki/vim/vimscript.md | else | edit ~/wiki/vim/vimscript.md | endif
balt ~/.vim/plugged/vim-exchange/autoload/exchange.vim
let s:l = 332 - ((1 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 332
normal! 028|
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/.vim/tmp/websearch") | buffer ~/.vim/tmp/websearch | else | edit ~/.vim/tmp/websearch | endif
balt ~/wiki/vim/vimscript.md
let s:l = 1 - ((0 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 0
lcd ~/.vim
wincmd w
4wincmd w
exe '1resize ' . ((&lines * 0 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
exe '4resize ' . ((&lines * 27 + 16) / 33)
tabnext 18
badd +1 ~/wiki/awk/sed.md
badd +1 ~/.vim/plugged/vim-cheat/ftplugin/cheat.vim
badd +1 ~/Desktop/ask.md
badd +1 ~/.vim/plugged/vim-vim/after/ftplugin/vim.vim
badd +1 ~/.vim/plugin/README/matchup.md
badd +1 ~/Desktop/cwd.md
badd +294 ~/.vim/plugged/vim-unix/autoload/unix.vim
badd +1 ~/Desktop/refactor.md
badd +1 ~/.vim/plugged/vim-quickhl/autoload/quickhl.vim
badd +1 ~/wiki/vim/sign.md
badd +1 ~/Vcs/zsh/Misc/vcs_info-examples
badd +1 ~/wiki/vim/mapping.md
badd +1 ~/wiki/vim/todo/todo.md
badd +1 ~/.vim/plugged/vim-lg-lib/import/lg.vim
badd +1 ~/.vim/plugged/vim-stacktrace/test/compile_time.vim
badd +1 ~/pp.log
badd +289 ~/.vim/plugged/vim-exchange/autoload/exchange.vim
badd +814 ~/wiki/vim/config.md
badd +11 ~/wiki/vim/complete.md
badd +69 ~/Desktop/vim.vim
badd +3 ~/.vim/plugin/matchup.vim
badd +60 ~/.vim/plugged/vim-fex/ftplugin/fex.vim
badd +119 ~/wiki/vim/shell.md
badd +55 ~/.vim/plugged/vim-completion/autoload/completion/util.vim
badd +84 ~/.vim/plugged/vim-vim/autoload/vim/refactor/substitute.vim
badd +8 ~/.vim/plugged/vim-vim/test/refactor/substitute.vim
badd +3 ~/wiki/vim/popup.md
badd +128 ~/Desktop/git-prompt.md
badd +88 ~/bin/prompt.zsh
badd +0 ~/wiki/vim/vimscript.md
badd +1 ~/Desktop/filez
badd +1535 ~/.vim/autoload/myfuncs.vim
badd +2906 ~/wiki/vim/vim9.md
badd +698 ~/wiki/bug/vim.md
badd +6 ~/vim-scriptease/plugin/scriptease.vim
badd +48 ~/vim-scriptease/autoload/scriptease.vim
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToOSacFIsW
set winminheight=0 winminwidth=0
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
