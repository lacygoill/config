" Why should I disable keys in `~/.vim/after/plugin`, instead of `vimrc`?{{{
"
" Plugin authors often use `mapcheck()` to decide whether they can remap a key.
" And,  atm, `mapcheck()`  returns an  empty string  whether there's  no mapping
" conflicting  with `{name}`,  or  the  first conflicting  mapping  has the  rhs
" `<nop>`.
" Because of this confusion, if you need to disable a key, and you do it in your
" vimrc (`nno <key> <nop>`), there's a  chance that a plugin will overwrite your
" mapping, even if it tries to avoid it by invoking `mapcheck()`.
"
" This is what happens if you disable `s` (recommended by `vim-sandwich`).
" `vim-sneak` will still remap `s`:
"
"         https://github.com/vim/vim/issues/2940
"
" In fact, it depends on the order of installation of the mappings:
"
"     $ vim -Nu NONE +'nno s <nop>' +'nno sab de' +'echo mapcheck("s", "n") is# ""'
"         → 0 ✔
"
"     $ vim -Nu NONE +'nno sab de' +'nno s <nop>' +'echo mapcheck("s", "n") is# ""'
"         → 1 ✘
"
" Bottom_line:
" We should disable a key after all plugins have been sourced.
" It's more reliable.
"}}}

" Various keys used as a prefix {{{1

fu! s:cancel_prefix(prefixes) abort
    for pfx in a:prefixes
        " We may let the timeout elapse.
        " In this case, the key should have no effect.
        " This is probably the reason why `:h sandwich-keymappings`, recommends this:{{{
        "
        " NOTE: To prevent unintended operation, the following setting is strongly
        "       recommended to add to your vimrc.
        "
        "         nmap s <Nop>
        "         xmap s <Nop>
        "}}}
        exe 'nno  '.pfx.'  <nop>'
        exe 'xno  '.pfx.'  <nop>'
        " Are there other mappings to disable?{{{
        "
        " In the past I also disabled `pfx Esc`.
        "
        "     exe 'nno  '.pfx.'<esc>  <esc>'
        "     exe 'xno  '.pfx.'<esc>  <esc>'
        "
        " But it doesn't seem necessary.
        "
        " If you press a prefix key  then Escape, since there's no mapping using
        " `pfx Esc` as its lhs, and since it doesn't make any sense for Vim (for
        " example  it's  not  an  operator combined  with  a  text-object),  Vim
        " probably ignores the prefix, and only types Escape.
        "
        " Confirmed by:
        "
        "     :ino + <nop>
        "     :startinsert
        "     + Esc
        "         → you get back to normal mode (meaning that Vim has pressed escape)
        "}}}
    endfor
endfu
call s:cancel_prefix(['+', '-', '<bar>', 'U', 's', 'S'])

" You've disabled `s` and `S`. What about `sS` and `Ss`?{{{
"
" Disabling those is useless.
"
" When  you press  `s` after  `S`, `S`  is automatically  canceled (look  at the
" command line; 'showcmd'). Only `S` remains.
" If you  wait for the timeout,  our `nno S  <nop>` mapping will be  used, which
" will make sure nothing happens.
"}}}

" i_C-n {{{1

" Why do you disable keyword completion?{{{
"
" When I want to move the cursor backward with C-b, I suspect I hit C-n
" by accident instead. Very annoying (slow popup menu; breaks workflow).
" We can still use C-p though.
"}}}
ino  <expr>  <c-n>  pumvisible() ? '<c-n>' : ''

" x_C-z {{{1

" Don't suspend if I press C-z by accident from visual mode.
vno  <c-z>  <nop>

" do  dp {{{1

" I often hit `do` and `dp` by accident, when in fact I only wanted to hit
" `o` or `p`.
" Anyway, `do` and `dp` are only useful in a buffer which is in diff mode.
nno  <expr>  do  &l:diff ? 'do' : ''
nno  <expr>  dp  &l:diff ? 'dp' : ''

" go Esc {{{1

" When we cancel `go` with Escape, Vim moves the cursor to the top of the
" buffer (1st byte, see `:h go`). Annoying.
nno  go<esc>  <nop>

" Uu {{{1

" I think we often press `Uu` by accident.
" When that happens, Vim undo our edits, which I don't want.
nno  Uu  <nop>

