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
set stal=2
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
arglocal
%argdel
let s:l = 936 - ((106 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
936
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
arglocal
%argdel
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
exe '1resize ' . ((&lines * 1 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
exe '4resize ' . ((&lines * 26 + 16) / 33)
arglocal
%argdel
let s:l = 484 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
484
normal! 0
lcd ~/.vim
wincmd w
arglocal
%argdel
if bufexists("~/wiki/vim/config.md") | buffer ~/wiki/vim/config.md | else | edit ~/wiki/vim/config.md | endif
let s:l = 1542 - ((12 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1542
normal! 0
lcd ~/wiki/vim
wincmd w
arglocal
%argdel
if bufexists("~/wiki/vim/complete.md") | buffer ~/wiki/vim/complete.md | else | edit ~/wiki/vim/complete.md | endif
let s:l = 163 - ((150 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
163
normal! 0
lcd ~/wiki/vim
wincmd w
arglocal
%argdel
if bufexists("~/.vim/plugged/vim-lg-lib/autoload/lg/window.vim") | buffer ~/.vim/plugged/vim-lg-lib/autoload/lg/window.vim | else | edit ~/.vim/plugged/vim-lg-lib/autoload/lg/window.vim | endif
let s:l = 350 - ((306 * winheight(0) + 13) / 26)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
350
normal! 0
lcd ~/.vim/plugged/vim-lg-lib
wincmd w
exe '1resize ' . ((&lines * 1 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
exe '4resize ' . ((&lines * 26 + 16) / 33)
tabnext
edit ~/Desktop/answer.md
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
exe '1resize ' . ((&lines * 1 + 16) / 33)
exe '2resize ' . ((&lines * 28 + 16) / 33)
arglocal
%argdel
let s:l = 183 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
183
normal! 0
lcd ~/.vim
wincmd w
arglocal
%argdel
if bufexists("~/Desktop/vim.vim") | buffer ~/Desktop/vim.vim | else | edit ~/Desktop/vim.vim | endif
let s:l = 66 - ((13 * winheight(0) + 14) / 28)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
66
normal! 021|
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 1 + 16) / 33)
exe '2resize ' . ((&lines * 28 + 16) / 33)
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
exe '1resize ' . ((&lines * 1 + 16) / 33)
exe '2resize ' . ((&lines * 28 + 16) / 33)
arglocal
%argdel
let s:l = 39 - ((0 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
39
normal! 0
lcd ~/.vim/plugged/vim-vim
wincmd w
arglocal
%argdel
if bufexists("~/.vim/plugged/vim-vim/autoload/vim/refactor/method.vim") | buffer ~/.vim/plugged/vim-vim/autoload/vim/refactor/method.vim | else | edit ~/.vim/plugged/vim-vim/autoload/vim/refactor/method.vim | endif
let s:l = 20 - ((15 * winheight(0) + 14) / 28)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
20
normal! 011|
lcd ~/.vim/plugged/vim-vim
wincmd w
exe '1resize ' . ((&lines * 1 + 16) / 33)
exe '2resize ' . ((&lines * 28 + 16) / 33)
tabnext
edit ~/.vim/plugin/matchup.vim
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
exe '1resize ' . ((&lines * 27 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
exe '4resize ' . ((&lines * 0 + 16) / 33)
arglocal
%argdel
let s:l = 8 - ((7 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
8
normal! 0
lcd ~/.vim
wincmd w
arglocal
%argdel
if bufexists("~/.vim/plugin/README/matchup.md") | buffer ~/.vim/plugin/README/matchup.md | else | edit ~/.vim/plugin/README/matchup.md | endif
let s:l = 897 - ((64 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
897
normal! 023|
lcd ~/.vim
wincmd w
arglocal
%argdel
if bufexists("/usr/local/share/vim/vim81/pack/dist/opt/matchit/doc/matchit.txt") | buffer /usr/local/share/vim/vim81/pack/dist/opt/matchit/doc/matchit.txt | else | edit /usr/local/share/vim/vim81/pack/dist/opt/matchit/doc/matchit.txt | endif
let s:l = 80 - ((13 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
80
normal! 0
lcd ~/.vim
wincmd w
arglocal
%argdel
if bufexists("/tmp/vim.vim") | buffer /tmp/vim.vim | else | edit /tmp/vim.vim | endif
let s:l = 3 - ((2 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
3
normal! 0
lcd ~/.vim
wincmd w
exe '1resize ' . ((&lines * 27 + 16) / 33)
exe '2resize ' . ((&lines * 0 + 16) / 33)
exe '3resize ' . ((&lines * 0 + 16) / 33)
exe '4resize ' . ((&lines * 0 + 16) / 33)
tabnext
edit ~/wiki/git/git.md
set splitbelow splitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
arglocal
%argdel
let s:l = 1962 - ((26 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1962
normal! 0
lcd ~/wiki/git
tabnext 7
set stal=1
badd +936 ~/wiki/awk/sed.md
badd +0 ~/.vim/plugged/vim-cheat/ftplugin/cheat.vim
badd +484 ~/Desktop/ask.md
badd +183 ~/Desktop/answer.md
badd +39 ~/.vim/plugged/vim-vim/after/ftplugin/vim.vim
badd +6 ~/.vim/plugin/matchup.vim
badd +1542 ~/wiki/vim/config.md
badd +163 ~/wiki/vim/complete.md
badd +350 ~/.vim/plugged/vim-lg-lib/autoload/lg/window.vim
badd +66 ~/Desktop/vim.vim
badd +20 ~/.vim/plugged/vim-vim/autoload/vim/refactor/method.vim
badd +897 ~/.vim/plugin/README/matchup.md
badd +3 /tmp/vim.vim
badd +1961 ~/wiki/git/git.md
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToOSacFIsW
set winminheight=0 winminwidth=0
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
