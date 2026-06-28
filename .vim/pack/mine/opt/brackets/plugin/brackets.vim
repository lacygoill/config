vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/brackets.vim'
import autoload '../autoload/brackets/move.vim'

# Commands {{{1
# Ilist {{{2

#                                            ┌ command{{{
#                                            │
#                                            │   ┌ pattern is NOT word under cursor
#                                            │   │
#                                            │   │      ┌ do NOT start searching after current line
#                                            │   │      │  start from beginning of file
#                                            │   │      │
#                                            │   │      │      ┌ search in comments only if a bang is added
#                                            │   │      │      │
#                                            │   │      │      │        ┌ pattern
#                                            │   │      │      │        │}}}
command -bang -nargs=1 Ilist brackets.IList('i', false, false, <bang>0, <q-args>)
command -bang -nargs=1 Dlist brackets.IList('d', false, false, <bang>0, <q-args>)
#}}}1
# Mappings {{{1
# Move in lists {{{2
# arglist {{{3

nmap <unique> ]a <Plug>(next-file-in-arglist)
nmap <unique> [a <Plug>(prev-file-in-arglist)
nnoremap <Plug>(next-file-in-arglist) <ScriptCmd>move.Next(']a')<CR>
nnoremap <Plug>(prev-file-in-arglist) <ScriptCmd>move.Next('[a')<CR>

nnoremap <unique> [A <ScriptCmd>first<CR>
nnoremap <unique> ]A <ScriptCmd>last<CR>

# file list {{{3

nmap <unique> ]f <Plug>(next-file)
nmap <unique> [f <Plug>(prev-file)
nnoremap <Plug>(next-file) <ScriptCmd>brackets.EditNextFile()<CR>
nnoremap <Plug>(prev-file) <ScriptCmd>brackets.EditNextFile(false)<CR>

# quickfix list {{{3

nmap <unique> ]q <Plug>(next-entry-in-qfl)
nmap <unique> [q <Plug>(prev-entry-in-qfl)
nnoremap <Plug>(next-entry-in-qfl) <ScriptCmd>move.Cnext(']q')<CR>
nnoremap <Plug>(prev-entry-in-qfl) <ScriptCmd>move.Cnext('[q')<CR>

nmap <unique> ]l <Plug>(next-entry-in-loclist)
nmap <unique> [l <Plug>(prev-entry-in-loclist)
nnoremap <Plug>(next-entry-in-loclist) <ScriptCmd>move.Cnext(']l')<CR>
nnoremap <Plug>(prev-entry-in-loclist) <ScriptCmd>move.Cnext('[l')<CR>

nnoremap <unique> [Q <ScriptCmd>cfirst<CR>
nnoremap <unique> ]Q <ScriptCmd>clast<CR>

nnoremap <unique> [L <ScriptCmd>lfirst<CR>
nnoremap <unique> ]L <ScriptCmd>llast<CR>

nmap <unique> ]<C-Q> <Plug>(next-file-in-qfl)
nmap <unique> [<C-Q> <Plug>(prev-file-in-qfl)
nnoremap <Plug>(next-file-in-qfl) <ScriptCmd>move.Cnext('] C-q')<CR>
nnoremap <Plug>(prev-file-in-qfl) <ScriptCmd>move.Cnext('[ C-q')<CR>

nmap <unique> ]<C-L> <Plug>(next-file-in-loclist)
nmap <unique> [<C-L> <Plug>(prev-file-in-loclist)
nnoremap <Plug>(next-file-in-loclist) <ScriptCmd>move.Cnext('] C-l')<CR>
nnoremap <Plug>(prev-file-in-loclist) <ScriptCmd>move.Cnext('[ C-l')<CR>

# quickfix stack {{{3

nmap <unique> >q <Plug>(next-qflist)
nmap <unique> <q <Plug>(prev-qflist)
nnoremap <Plug>(next-qflist) <ScriptCmd>move.Cnewer('>q')<CR>
nnoremap <Plug>(prev-qflist) <ScriptCmd>move.Cnewer('<q')<CR>

nmap <unique> >l <Plug>(next-loclist)
nmap <unique> <l <Plug>(prev-loclist)
nnoremap <Plug>(next-loclist) <ScriptCmd>move.Cnewer('>l')<CR>
nnoremap <Plug>(prev-loclist) <ScriptCmd>move.Cnewer('<l')<CR>

# tag stack {{{3

nmap <unique> ]t <Plug>(next-tag)
nmap <unique> [t <Plug>(prev-tag)
nnoremap <Plug>(next-tag) <ScriptCmd>move.Tnext(']t')<CR>
nnoremap <Plug>(prev-tag) <ScriptCmd>move.Tnext('[t')<CR>

nnoremap <unique> [T <ScriptCmd>tfirst<CR>
nnoremap <unique> ]T <ScriptCmd>tlast<CR>
#}}}2
# Move to text matching regex {{{2

map <unique> ]` <Plug>(next-codespan)
map <unique> [` <Plug>(prev-codespan)
noremap <expr> <Plug>(next-codespan) move.Regex('codespan')
noremap <expr> <Plug>(prev-codespan) move.Regex('codespan', false)

map <unique> ]h <Plug>(next-path)
map <unique> [h <Plug>(prev-path)
noremap <expr> <Plug>(next-path) move.Regex('path')
noremap <expr> <Plug>(prev-path) move.Regex('path', false)

map <unique> ]r <Plug>(next-reference-link)
map <unique> [r <Plug>(prev-reference-link)
noremap <expr> <Plug>(next-reference-link) move.Regex('ref')
noremap <expr> <Plug>(prev-reference-link) move.Regex('ref', false)

map <unique> ]u <Plug>(next-url)
map <unique> [u <Plug>(prev-url)
noremap <expr> <Plug>(next-url) move.Regex('url')
noremap <expr> <Plug>(prev-url) move.Regex('url', false)

map <unique> ]U <Plug>(next-concealed-url)
map <unique> [U <Plug>(prev-concealed-url)
noremap <expr> <Plug>(next-concealed-url) move.Regex('concealed-url')
noremap <expr> <Plug>(prev-concealed-url) move.Regex('concealed-url', false)

# Miscellaneous {{{2
# ] SPC {{{3

nnoremap <expr><unique> =<Space> brackets.PutLinesAround()
nnoremap <expr><unique> [<Space> brackets.PutLine(false)
nnoremap <expr><unique> ]<Space> brackets.PutLine(true)

# ] - {{{3

map <unique> ]- <Plug>(next-rule)
map <unique> [- <Plug>(prev-rule)
noremap <Plug>(next-rule) <ScriptCmd>brackets.RuleMotion()<CR>
noremap <Plug>(prev-rule) <ScriptCmd>brackets.RuleMotion(false)<CR>

# can't write `<unique>`; we need to override the operator-pending mode
# installed by the previous `:map`
onoremap [- <ScriptCmd>execute 'normal V' .. v:count1 .. '[-'<CR>
onoremap ]- <ScriptCmd>execute 'normal V' .. v:count1 .. ']-'<CR>

nnoremap <unique> +]- <ScriptCmd>brackets.RulePut()<CR>
nnoremap <unique> +[- <ScriptCmd>brackets.RulePut(false)<CR>

# ]I {{{3

# TODO: The mappings are commented because I don't want to shadow builtin commands like `]I` and `]D`.
# If you don't miss these mappings, remove them, as well as the functions they rely ong.
# If you do miss them, find better LHS'es.

#                                                           ┌ don't start to search at cursor,
#                                                           │ but at beginning of file
#                                                           │
#                                                           │      ┌ don't pass a bang to the commands
#                                                           │      │ normal commands don't accept one anyway
# nnoremap <unique> [I <ScriptCmd>brackets.IList('i', true, false, false)<CR>
#                                                 ^   ^
#                                                 |   search current word
#                                                 + command to execute (ilist or dlist)

# xnoremap <unique> [I <C-\><C-N><ScriptCmd>brackets.IList('i', false, false, true)<CR>

# nnoremap <unique> ]I <ScriptCmd>brackets.IList('i', true, true, false)<CR>
#                                                           ^
#                                                           start to search after the line where the cursor is

# xnoremap <unique> ]I <C-\><C-N><ScriptCmd>brackets.IList('i', false, true, true)<CR>

# nnoremap <unique> [D <ScriptCmd>brackets.IList('d', true, false, false)<CR>
# xnoremap <unique> [D <C-\><C-N><ScriptCmd>brackets.IList('d', false, false, true)<CR>

# nnoremap <unique> ]D <ScriptCmd>brackets.IList('d', true, true, false)<CR>
# xnoremap <unique> ]D <C-\><C-N><ScriptCmd>brackets.IList('d', false, true, true)<CR>

# ]e {{{3

nmap <unique> [e <Plug>(mv-line-above)
nmap <unique> ]e <Plug>(mv-line-below)
nnoremap <expr> <Plug>(mv-line-above) brackets.MvLine('[')
nnoremap <expr> <Plug>(mv-line-below) brackets.MvLine(']')

# ]p {{{3

# By default `]p` puts a copied line with the indentation of the current line.
# But if the copied text is characterwise, `]p` puts it as a characterwise text.
# We don't want that, we want the text to be put as linewise even if it was
# selected with a characterwise motion.

#                                        ┌ how to put internally{{{
#                                        │
#                                        │    ┌ how to indent afterward
#                                        │    │}}}
nnoremap <expr><unique> [p brackets.Put('[p', '')
nnoremap <expr><unique> ]p brackets.Put(']p', '')

# The  following mappings  put  the  unnamed register  after  the current  line,
# treating its contents as linewise  (even if characterwise) AND perform another
# action:
#
#    - >p >P    add a level of indentation
#    - <p <P    remove a level of indentation
#    - =p =P    auto-indentation (respecting our indentation-relative options)
nnoremap <expr><unique> >P brackets.Put('[p', ">']")
nnoremap <expr><unique> >p brackets.Put(']p', ">']")
nnoremap <expr><unique> <P brackets.Put('[p', "<']")
nnoremap <expr><unique> <p brackets.Put(']p', "<']")
nnoremap <expr><unique> =P brackets.Put('[p', "=']")
nnoremap <expr><unique> =p brackets.Put(']p', "=']")

# A simpler version of the same mappings would be:
#
#     nnoremap >P [p>']
#     nnoremap >p ]p>']
#     nnoremap <P [p<']
#     nnoremap <p ]p<']
#     nnoremap =P [p=']
#     nnoremap =p ]p=']
#
# But with these ones, we would lose the linewise conversion.

# ]s  ]S {{{3

# Why? {{{
#
# By default, `zh` and `zl` move the cursor on a long non-wrapped line.
# But at the same time, we use `zj` and `zk` to split the window.
# I  don't like  `hjkl` being  used with  a same  prefix (`z`)  for 2  different
# purposes.
# So, we'll  use `z[hjkl]` to split  the window, and  `[S` and `]S` to  scroll a
# long non-wrapped line.
#}}}
# Warning: this shadows the default `]S` command{{{
#
# ... which  moves the cursor  to the next  wrongly spelled word  (ignoring rare
# words words for another region).
# It's not a big deal, because you can  still use `]s` which does the same thing
# (without ignoring anything).
#}}}

nmap <unique> [S <Plug>(scroll-line-bwd)
nmap <unique> ]S <Plug>(scroll-line-fwd)
nnoremap <Plug>(scroll-line-bwd) 5zh
nnoremap <Plug>(scroll-line-fwd) 5zl
