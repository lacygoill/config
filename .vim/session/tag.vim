let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +29 ~/Desktop/preview.md
badd +823 ~/Dropbox/wiki/vim/config.md
argglobal
silent! argdel *
edit ~/Desktop/preview.md
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winminheight=1 winheight=1 winminwidth=1 winwidth=1
exe '1resize ' . ((&lines * 29 + 16) / 33)
exe '2resize ' . ((&lines * 1 + 16) / 33)
argglobal
setlocal fdm=expr
setlocal fde=fold#md#stacked()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
28
normal! zo
let s:l = 29 - ((28 * winheight(0) + 14) / 29)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
29
normal! 0
wincmd w
argglobal
if bufexists('~/Dropbox/wiki/vim/config.md') | buffer ~/Dropbox/wiki/vim/config.md | else | edit ~/Dropbox/wiki/vim/config.md | endif
setlocal fdm=expr
setlocal fde=fold#md#stacked()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 5 - ((4 * winheight(0) + 0) / 1)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
5
normal! 0
wincmd w
exe '1resize ' . ((&lines * 29 + 16) / 33)
exe '2resize ' . ((&lines * 1 + 16) / 33)
tabnext 1
if exists('s:wipebuf') && s:wipebuf != bufnr('%')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToOAacFIsW
set winminheight=1 winminwidth=1
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
let g:my_session = v:this_session
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
