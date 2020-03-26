if stridx(&rtp, 'vim-lg-lib') == -1
    finish
endif

" Define some motions {{{1
"       Why define them here? Why not in vimrc?{{{
"
" In the vimrc, we would need a guard:
"
"     if has('vim_starting')
"         ...
"     endif
"
" Without it, as  soon as we would  resource the vimrc, the  wrappers which make
" these motions repeatable  would be overwritten, and we would  lose the ability
" to repeat the motions.
"
" So, why not using the guard?
"
" We'll undoubtedly forget it sometimes, and then lose time wondering why one
" of our motion is not repeatable.
"}}}
"    g,  g; {{{2

nno <unique> g; g,zv
nno <unique> g, g;zv

"    gj  gk         vertical jump {{{2

" Alternative: https://github.com/haya14busa/vim-edgemotion
noremap <expr><silent><unique> gk <sid>vertical_jump_rhs(0)
noremap <expr><silent><unique> gj <sid>vertical_jump_rhs(1)

fu s:snr()
    return matchstr(expand('<sfile>'), '.*\zs<SNR>\d\+_')
endfu
let s:snr = get(s:, 'snr', s:snr())

fu s:vertical_jump_rhs(is_fwd) abort
    let mode = mode(1)

    if mode is# "\<c-v>"
        let mode = "\<c-v>\<c-v>"
    endif

    return printf(":\<c-u>call %svertical_jump_go(%d,%s)\<cr>",
        \ s:snr, a:is_fwd, string(mode))
endfu

fu s:vertical_jump_go(is_fwd, mode) abort
    if a:mode is# 'n'
        norm! m'
    elseif a:mode =~# "^[vV\<c-v>]$"
        norm! gv
    endif

    let n = s:get_jump_height(a:is_fwd)
    if n <= 0
        return
    endif

    " temporarily disable folds before we move
    let [fen_save, winid, bufnr] = [&l:fen, win_getid(), bufnr('%')]
    let &l:fen = 0
    try
        exe 'norm! '..(a:is_fwd ? n..'j' : n..'k')
    finally
        " restore folds
        if winbufnr(winid) == bufnr
            let [tabnr, winnr] = win_id2tabwin(winid)
            call settabwinvar(tabnr, winnr, '&fen', fen_save)
        endif
    endtry

    " open just enough folds to see where we are
    if a:mode =~# "[nvV\<c-v>]"
        norm! zv
    endif
endfu

fu s:get_jump_height(is_fwd) abort
    let vcol = '\%'..virtcol('.')..'v'
    let flags = a:is_fwd ? 'nW' : 'bnW'

    " a line where there IS a character in the same column,
    " then one where there is NOT
    let lnum1 = search(vcol..'.*\n\%(.*'..vcol..'.\)\@!', flags)

    " a line where there is NOT a character in the same column,
    " then one where there IS
    let lnum2 = search('^\%(.*'..vcol..'.\)\@!.*\n.*\zs'..vcol, flags)

    let lnums = filter([lnum1, lnum2], {_,v -> v > 0})

    return a:is_fwd
        \ ?     min(lnums) - line('.')
        \ :     line('.') - max(lnums)
endfu

"    <t  >t         move tab pages {{{2

nno <silent> <t :<c-u>call <sid>move_tabpage('-1')<cr>
nno <silent> >t :<c-u>call <sid>move_tabpage('+1')<cr>

fu s:move_tabpage(where) abort
    try
        exe 'tabmove '..a:where
    catch /^Vim\%((\a\+)\)\=:E474:/
    catch
        return lg#catch()
    endtry
endfu
" }}}1
" Make `fx` motion, &friends, repeatable {{{1

" To make `)` repeatable, we just need to invoke `repmap#make#all()`.
" So, why do we  need extra mappings, and an extra  function, `s:fts()`, to make
" `fx` (&friends) repeatable?
" Answer:{{{
"
" When we press `)`, the last saved motion is `)`.
" When we press `fx`, the last saved motion is `f`, not `fx`.
"
" Why not `fx`?
" Because the saved motion is the lhs of the mapping, and `fx` is not the lhs of
" any mapping (`f` is).
" `x` is probably asked by `vim-sneak` via `getchar()`.
" But it doesn't explicitly belong to the lhs.
"
" So, there's an issue here.
" `f` is not a sufficient information to successfully repeat `fx`.
" 2 solutions:
"
"         1. save `x` to later repeat `fx`
"         2. repeat `fx` by pressing Vim's default `;` motion
"
" The 1st solution will work with `tx` and `Tx`, but only the 1st time.
" After that, the  cursor won't move, because  it will always be  stopped by the
" same `x`.
"
" So we must use the 2nd solution, and press `;`.
" But this introduces a special case:
"
"     we press `)` → `s:move()`        must press `)`
"     we press `;` → `s:move_again()`  must press `)`
"
"     we press `f`  → `s:move()`       must press `f`
"     we press `;`  → `s:move_again()` must press `;`
"                                                  │
"                                                  └ special case (because != f)
"
" We  need to  redefine the  `f`  motion with  the  output of  a function  which
" returns:
"
"     `f` when we press `f`
"     `;` when we press `;` to repeat a `f` motion
"
" So, this function must know whether we're repeating a `f` motion,
" and press different keys accordingly.
"
" We'll give this information to the function via:
"
"     repmap#make#is_repeating()
"}}}

" These mappings must be installed *before* `repmap#make#all()`
" is invoked to make the motions repeatable.
noremap <expr><unique> t  <sid>fts('t')
noremap <expr><unique> T  <sid>fts('T')
noremap <expr><unique> f  <sid>fts('f')
noremap <expr><unique> F  <sid>fts('F')
noremap <expr><unique> ss <sid>fts('s')
noremap <expr><unique> SS <sid>fts('S')

fu s:fts(cmd) abort
    " Why not `call feedkeys('zv', 'int')`?{{{
    "
    " It  would interfere  with  `vim-sneak`,  when the  latter  asks for  which
    " character we want to move on. `zv` would be interpreted like this:
    "
    "     zv
    "     ││
    "     │└ enter visual mode
    "     └ move cursor to next/previous `z` character
    "}}}
    " How is this autocmd better?{{{
    "
    " `feedkeys('zv', 'int')` would IMMEDIATELY press `zv` (✘).
    " The autocmd also presses `zv`, but only after a motion has occurred (✔).
    "}}}
    au CursorMoved * ++once norm! zv

    " What's the purpose of this `if` conditional?{{{
    "
    " This function can be called:
    "
    "    -   directly from a  [ftFT]  mapping
    "    - indirectly from a  [;,]    mapping
    "      │
    "      └ move_again()  →  s:move()  →  fts()
    "
    " It needs to distinguish from where it was called.
    " Because in  the first  case, it  needs to  ask the  user for  a character,
    " before returning the  keys to press. In the other, it  doesn't need to ask
    " anything.
    "}}}
    if repmap#make#is_repeating()
        let move_fwd = a:cmd =~# '\C[fts]'
        "                └ When we press `;` after `fx`, how is `a:cmd` obtained?{{{
        "
        " Here's what happens approximately:
        "
        " we press ;
        " |
        " +-  move_again('fwd', ', ;')   is invoked
        "     |
        "     +-  all info about the 'f' motion is saved in `motion`
        "     |
        "     |   Why 'f' ?
        "     |   'f' was saved in   s:last_motions[', ;']   when we pressed `fx` earlier
        "     |   and is now retrieved with   s:get_motion_info(s:last_motions[', ;'])
        "     |
        "     +-  s:move('f', 0, 0, motion)   is invoked
        "           |     │   │  │
        "           |     │   │  └ don't update the last motion
        "           |     │   └ not local to buffer
        "           |     └ obtained with   motion.fwd.lhs
        "           |
        "           +-  'fwd' is saved in `dir_key`
        "           |   obtained with   s:get_direction('f', motion)
        "           |
        "           +-  s:fts('f')  is evaluated through `eval()`
        "               │
        "               └ obtained with   motion['fwd'].rhs
        "
        "               When this evaluation occurs, `s:fts()` receives the argument 'f'.
        "               This is how `a:cmd` is obtained.
        "}}}
        call feedkeys(move_fwd ? "\<plug>Sneak_;" : "\<plug>Sneak_,", 'i')
    else
        call feedkeys("\<plug>Sneak_"..a:cmd, 'i')
    endif
    return ''
endfu

sil! call repmap#make#all({
    \ 'mode':   '',
    \ 'buffer': 0,
    \ 'from':   expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': 'F' ,  'fwd': 'f' },
    \              {'bwd': 'SS',  'fwd': 'ss'},
    \              {'bwd': 'T' ,  'fwd': 't' },
    \            ],
    \ })

" Make other motions repeatable {{{1

" Rule: For a motion to be made repeatable, it must ALREADY be defined.{{{
"
" Don't invoke `repmap#make#all()` for a custom motion
" which you're not sure whether it has been defined, or will be later.
"
" Indeed, the function needs to save all the information relative to the
" original motion in a database.
"}}}
" Why making motions repeatable in this file?{{{
"
"     1. We source it AFTER Vim has started, so all plugins have been
"        sourced and any custom motion has already been defined.
"        We can be sure we're respecting the previous rule.
"
"     2. The process can be slow. This file allows us to delay it
"        until Vim has started, and to keep a short startup time.
"}}}

" cycle through help topics relevant for last errors
" we don't have a pair of motions to move in 2 directions,
" so I just repeat the same keys for 'bwd' and 'fwd'
sil! call repmap#make#all({
    \ 'mode':    'n',
    \ 'buffer':  0,
    \ 'from':    expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': '!e',  'fwd': '!e'},
    \            ]
    \ })

" move tabpage / rotate window
sil! call repmap#make#all({
    \ 'mode':   'n',
    \ 'buffer': 0,
    \ 'from':   expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': '<t'    ,  'fwd': '>t'},
    \              {'bwd': '<c-w>R',  'fwd': '<c-w>r'},
    \            ]
    \ })

" built-in motions
sil! call repmap#make#all({
    \ 'mode':   '',
    \ 'buffer': 0,
    \ 'from':   expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': "['",  'fwd': "]'"},
    \              {'bwd': '["',  'fwd': ']"'},
    \              {'bwd': '[#',  'fwd': ']#'},
    \              {'bwd': '[(',  'fwd': '])'},
    \              {'bwd': '[*',  'fwd': ']*'},
    \              {'bwd': '[/',  'fwd': ']/'},
    \              {'bwd': '[M',  'fwd': ']M'},
    \              {'bwd': '[S',  'fwd': ']S'},
    \              {'bwd': '[]',  'fwd': ']['},
    \              {'bwd': '[c',  'fwd': ']c'},
    \              {'bwd': '[m',  'fwd': ']m'},
    \              {'bwd': '[s',  'fwd': ']s'},
    \              {'bwd': '[{',  'fwd': ']}'},
    \              {'bwd': 'g,',  'fwd': 'g;'},
    \            ],
    \ })

" Why `nxo` for the mode? Why not simply an empty string?{{{
"
" You can use `''` when the original motion is built-in or defined via `:[nore]map`.
" In that  case, `maparg(motion,  '', 0,  1).mode` is a  space, which  our `lg#`
" function recognizes as `nvo`.
"
" But  here,   `%`  is  not  built-in;   it's  a  custom  motion   installed  by
" `vim-matchup`.  And the  latter does not use `:[nore]map`; it  uses 3 separate
" mappings; one for `n`, one for `x`, and one for `o`:
"
"     ~/.vim/plugged/vim-matchup/autoload/matchup.vim:179
"
" If  you  pass the  mode  `''`  to  our `lg#`  function,  it  will pass  it  to
" `maparg()`, which won't return a space for the mode, but `o`:
"
"                       vv
"     :echo maparg('%', '', 0, 1).mode
"     o~
"
" As a result, `%` and `g%` would be broken in normal and visual mode.
"}}}
sil! call repmap#make#all({
    \ 'mode':   'nxo',
    \ 'buffer': 0,
    \ 'from':   expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': '[-',  'fwd': ']-'},
    \            ],
    \ })

" custom motions
sil! call repmap#make#all({
    \ 'mode':   'n',
    \ 'buffer': 0,
    \ 'from':   expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': '[<c-l>',  'fwd': ']<c-l>'},
    \              {'bwd': '[<c-q>',  'fwd': ']<c-q>'},
    \              {'bwd': '[a'    ,  'fwd': ']a'},
    \              {'bwd': '[b'    ,  'fwd': ']b'},
    \              {'bwd': '[f'    ,  'fwd': ']f'},
    \              {'bwd': '[l'    ,  'fwd': ']l'},
    \              {'bwd': '[q'    ,  'fwd': ']q'},
    \              {'bwd': '[t'    ,  'fwd': ']t'},
    \            ]
    \ })

sil! call repmap#make#all({
    \ 'mode':   'n',
    \ 'buffer': 0,
    \ 'from':   expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': '<l'    ,  'fwd': '>l'},
    \              {'bwd': '<q'    ,  'fwd': '>q'},
    \            ]
    \ })

sil! call repmap#make#all({
    \ 'mode':   '',
    \ 'buffer': 0,
    \ 'from':   expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': '[`',  'fwd': ']`'},
    \              {'bwd': '[h',  'fwd': ']h'},
    \              {'bwd': '[r',  'fwd': ']r'},
    \              {'bwd': '[u',  'fwd': ']u'},
    \              {'bwd': '[U',  'fwd': ']U'},
    \              {'bwd': '[z',  'fwd': ']z'},
    \              {'bwd': 'gk',  'fwd': 'gj'},
    \            ]
    \ })

sil! call repmap#make#all({
    \ 'mode':   'n',
    \ 'buffer': 0,
    \ 'from':   expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': '[e', 'fwd': ']e'},
    \            ]
    \ })

" toggle settings
sil! call repmap#make#all({
    \ 'mode':   'n',
    \ 'buffer': 0,
    \ 'from':   expand('<sfile>:p')..':'..expand('<slnum>'),
    \ 'motions': [
    \              {'bwd': '[oC',  'fwd': ']oC'},
    \              {'bwd': '[oD',  'fwd': ']oD'},
    \              {'bwd': '[oL',  'fwd': ']oL'},
    \              {'bwd': '[oS',  'fwd': ']oS'},
    \              {'bwd': '[oc',  'fwd': ']oc'},
    \              {'bwd': '[od',  'fwd': ']od'},
    \              {'bwd': '[of',  'fwd': ']of'},
    \              {'bwd': '[oh',  'fwd': ']oh'},
    \              {'bwd': '[oi',  'fwd': ']oi'},
    \              {'bwd': '[ol',  'fwd': ']ol'},
    \              {'bwd': '[on',  'fwd': ']on'},
    \              {'bwd': '[op',  'fwd': ']op'},
    \              {'bwd': '[oq',  'fwd': ']oq'},
    \              {'bwd': '[os',  'fwd': ']os'},
    \              {'bwd': '[ot',  'fwd': ']ot'},
    \              {'bwd': '[ov',  'fwd': ']ov'},
    \              {'bwd': '[ow',  'fwd': ']ow'},
    \              {'bwd': '[oy',  'fwd': ']oy'},
    \              {'bwd': '[oz',  'fwd': ']oz'},
    \            ]
    \ })

