let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
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
tabrewind
edit ~/wiki/awk/sed.md
set splitbelow splitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
let s:l = 79 - ((78 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
79
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
let s:l = 1 - ((0 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
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
exe '1resize ' . ((&lines * 1 + 8) / 16)
argglobal
let s:l = 228 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
228
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/wiki/vim/config.md") | buffer ~/wiki/vim/config.md | else | edit ~/wiki/vim/config.md | endif
let s:l = 1692 - ((10 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1692
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/vim/complete.md") | buffer ~/wiki/vim/complete.md | else | edit ~/wiki/vim/complete.md | endif
let s:l = 139 - ((8 * winheight(0) + 6) / 13)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
139
normal! 0
lcd ~/wiki/vim
wincmd w
exe '1resize ' . ((&lines * 1 + 8) / 16)
tabnext
edit ~/.vim/plugged/vim-vim/after/ftplugin/vim.vim
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
exe '1resize ' . ((&lines * 1 + 8) / 16)
argglobal
let s:l = 80 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
80
normal! 0
lcd ~/.vim/plugged/vim-vim
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-vim/autoload/vim/refactor/method.vim") | buffer ~/.vim/plugged/vim-vim/autoload/vim/refactor/method.vim | else | edit ~/.vim/plugged/vim-vim/autoload/vim/refactor/method.vim | endif
let s:l = 41 - ((20 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
41
normal! 0
lcd ~/.vim/plugged/vim-vim
wincmd w
argglobal
if bufexists("~/Desktop/vim.vim") | buffer ~/Desktop/vim.vim | else | edit ~/Desktop/vim.vim | endif
let s:l = 69 - ((3 * winheight(0) + 6) / 13)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
69
normal! 0
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 1 + 8) / 16)
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
argglobal
let s:l = 947 - ((4 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
947
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/.vim/plugin/matchup.vim") | buffer ~/.vim/plugin/matchup.vim | else | edit ~/.vim/plugin/matchup.vim | endif
let s:l = 88 - ((82 * winheight(0) + 7) / 15)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
88
normal! 0
lcd ~/.vim
wincmd w
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
argglobal
let s:l = 219 - ((13 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
219
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-fex/ftplugin/fex.vim") | buffer ~/.vim/plugged/vim-fex/ftplugin/fex.vim | else | edit ~/.vim/plugged/vim-fex/ftplugin/fex.vim | endif
let s:l = 4 - ((3 * winheight(0) + 7) / 15)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
4
normal! 0
lcd ~/.vim/plugged/vim-fex
wincmd w
tabnext
edit ~/.vim/plugged/vim-unix/autoload/unix.vim
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
exe '1resize ' . ((&lines * 1 + 8) / 16)
argglobal
let s:l = 56 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
56
normal! 0
lcd ~/.vim/plugged/vim-unix
wincmd w
argglobal
if bufexists("~/wiki/vim/shell.md") | buffer ~/wiki/vim/shell.md | else | edit ~/wiki/vim/shell.md | endif
let s:l = 21 - ((10 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
21
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/.vim/autoload/myfuncs.vim") | buffer ~/.vim/autoload/myfuncs.vim | else | edit ~/.vim/autoload/myfuncs.vim | endif
let s:l = 15 - ((9 * winheight(0) + 6) / 13)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
15
normal! 0
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 1 + 8) / 16)
tabnext
edit ~/.vim/plugged/vim-completion/plugin/completion.vim
set splitbelow splitright
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
4wincmd k
wincmd w
wincmd w
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 1 + 8) / 16)
exe '2resize ' . ((&lines * 0 + 8) / 16)
exe '3resize ' . ((&lines * 0 + 8) / 16)
exe '5resize ' . ((&lines * 0 + 8) / 16)
argglobal
let s:l = 107 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
107
normal! 0
lcd ~/.vim/plugged/vim-completion
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-completion/autoload/completion.vim") | buffer ~/.vim/plugged/vim-completion/autoload/completion.vim | else | edit ~/.vim/plugged/vim-completion/autoload/completion.vim | endif
let s:l = 301 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
301
normal! 0
lcd ~/.vim/plugged/vim-completion
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-completion/autoload/completion/util.vim") | buffer ~/.vim/plugged/vim-completion/autoload/completion/util.vim | else | edit ~/.vim/plugged/vim-completion/autoload/completion/util.vim | endif
let s:l = 39 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
39
normal! 0
lcd ~/.vim/plugged/vim-completion
wincmd w
argglobal
if bufexists("~/wiki/vim/config.md") | buffer ~/wiki/vim/config.md | else | edit ~/wiki/vim/config.md | endif
let s:l = 1495 - ((941 * winheight(0) + 12) / 25)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1495
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/vim/complete.md") | buffer ~/wiki/vim/complete.md | else | edit ~/wiki/vim/complete.md | endif
let s:l = 451 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
451
normal! 0
lcd ~/wiki/vim
wincmd w
exe '1resize ' . ((&lines * 1 + 8) / 16)
exe '2resize ' . ((&lines * 0 + 8) / 16)
exe '3resize ' . ((&lines * 0 + 8) / 16)
exe '5resize ' . ((&lines * 0 + 8) / 16)
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
exe '1resize ' . ((&lines * 1 + 8) / 16)
argglobal
let s:l = 45 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
45
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-vim/autoload/vim/refactor/substitute.vim") | buffer ~/.vim/plugged/vim-vim/autoload/vim/refactor/substitute.vim | else | edit ~/.vim/plugged/vim-vim/autoload/vim/refactor/substitute.vim | endif
let s:l = 80 - ((19 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
80
normal! 0
lcd ~/.vim/plugged/vim-vim
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-vim/test/refactor/substitute.vim") | buffer ~/.vim/plugged/vim-vim/test/refactor/substitute.vim | else | edit ~/.vim/plugged/vim-vim/test/refactor/substitute.vim | endif
let s:l = 2 - ((1 * winheight(0) + 6) / 13)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
2
normal! 0
lcd ~/.vim/plugged/vim-vim
wincmd w
exe '1resize ' . ((&lines * 1 + 8) / 16)
tabnext
edit ~/Desktop/text-properties.md
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
argglobal
let s:l = 398 - ((21 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
398
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/.vim/plugged/vim-quickhl/autoload/quickhl.vim") | buffer ~/.vim/plugged/vim-quickhl/autoload/quickhl.vim | else | edit ~/.vim/plugged/vim-quickhl/autoload/quickhl.vim | endif
let s:l = 69 - ((61 * winheight(0) + 7) / 15)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
69
normal! 0
lcd ~/.vim/plugged/vim-quickhl
wincmd w
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
argglobal
let s:l = 78 - ((58 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
78
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/vim/popup.md") | buffer ~/wiki/vim/popup.md | else | edit ~/wiki/vim/popup.md | endif
let s:l = 411 - ((77 * winheight(0) + 7) / 15)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
411
normal! 0
lcd ~/wiki/vim
wincmd w
tabnext
edit ~/bin/prompt.zsh
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
exe '1resize ' . ((&lines * 1 + 8) / 16)
argglobal
let s:l = 82 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
82
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/.zshrc") | buffer ~/.zshrc | else | edit ~/.zshrc | endif
let s:l = 523 - ((60 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
523
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/Desktop/git-prompt.md") | buffer ~/Desktop/git-prompt.md | else | edit ~/Desktop/git-prompt.md | endif
let s:l = 1 - ((0 * winheight(0) + 6) / 13)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 1 + 8) / 16)
tabnext
edit ~/wiki/vim/vimL.md
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
exe '2resize ' . ((&lines * 0 + 8) / 16)
argglobal
let s:l = 243 - ((241 * winheight(0) + 14) / 29)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
243
normal! 0
lcd ~/wiki/vim
wincmd w
argglobal
if bufexists("~/wiki/vim/mapping.md") | buffer ~/wiki/vim/mapping.md | else | edit ~/wiki/vim/mapping.md | endif
let s:l = 2822 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
2822
normal! 0
lcd ~/wiki/vim
wincmd w
exe '2resize ' . ((&lines * 0 + 8) / 16)
tabnext
edit ~/Desktop/bug.md
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
exe '1resize ' . ((&lines * 0 + 8) / 16)
argglobal
let s:l = 330 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
330
normal! 0
lcd ~/.vim
wincmd w
argglobal
if bufexists("~/wiki/vim/vim9.md") | buffer ~/wiki/vim/vim9.md | else | edit ~/wiki/vim/vim9.md | endif
let s:l = 22 - ((20 * winheight(0) + 14) / 29)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
22
normal! 02|
lcd ~/wiki/vim
wincmd w
exe '1resize ' . ((&lines * 0 + 8) / 16)
tabnext
set splitbelow splitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
tabnext 15
badd +1005 ~/wiki/awk/sed.md
badd +1 ~/.vim/plugged/vim-cheat/ftplugin/cheat.vim
badd +1 ~/Desktop/ask.md
badd +1 ~/.vim/plugged/vim-vim/after/ftplugin/vim.vim
badd +1 ~/.vim/plugin/README/matchup.md
badd +1 ~/Desktop/cwd.md
badd +1 ~/.vim/plugged/vim-unix/autoload/unix.vim
badd +1 ~/.vim/plugged/vim-completion/plugin/completion.vim
badd +1 ~/Desktop/refactor.md
badd +1 ~/Desktop/text-properties.md
badd +1 ~/wiki/vim/sign.md
badd +1 ~/bin/prompt.zsh
badd +2594 ~/wiki/vim/vimL.md
badd +330 ~/Desktop/bug.md
badd +891 ~/wiki/vim/config.md
badd +317 ~/wiki/vim/complete.md
badd +9 ~/.vim/plugged/vim-vim/autoload/vim/refactor/method.vim
badd +1 ~/Desktop/vim.vim
badd +121 ~/.vim/plugin/matchup.vim
badd +16 ~/.vim/plugged/vim-fex/ftplugin/fex.vim
badd +1 ~/wiki/vim/shell.md
badd +88 ~/.vim/autoload/myfuncs.vim
badd +104 ~/.vim/plugged/vim-completion/autoload/completion.vim
badd +45 ~/.vim/plugged/vim-completion/autoload/completion/util.vim
badd +42 ~/.vim/plugged/vim-vim/autoload/vim/refactor/substitute.vim
badd +5 ~/.vim/plugged/vim-vim/test/refactor/substitute.vim
badd +271 ~/.vim/plugged/vim-quickhl/autoload/quickhl.vim
badd +739 ~/wiki/vim/popup.md
badd +31 ~/.zshrc
badd +1 ~/Desktop/git-prompt.md
badd +4285 ~/wiki/vim/mapping.md
badd +679 ~/wiki/vim/vim9.md
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
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
