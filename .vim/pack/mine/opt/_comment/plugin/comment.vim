vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/comment/duplicate.vim'
import autoload '../autoload/comment/half.vim'
import autoload '../autoload/comment/motion.vim'
import autoload '../autoload/comment/object.vim'
import autoload '../autoload/comment/paste.vim'
import autoload '../autoload/comment/toggle.vim'

# Commands {{{1

command -range -bar CommentToggle toggle.Main('line', <line1>, <line2>)

# Mappings {{{1
# toggle {{{2

nnoremap <expr><unique> gc toggle.Main()
xnoremap <expr><unique> gc toggle.Main()
nnoremap <expr><unique> gcc toggle.Main() .. '_'

# stop at empty commented lines
onoremap <unique> ic <ScriptCmd>object.Main(true, v:operator == 'c')<CR>
# stop at non-commented lines
onoremap <unique> ac <ScriptCmd>object.Main(false, v:operator == 'c')<CR>

xnoremap <unique> ic <C-\><C-N><ScriptCmd>object.Main(true)<CR>
xnoremap <unique> ac <C-\><C-N><ScriptCmd>object.Main(false)<CR>

# Why not just `gcic` in the RHS?{{{
#
# Suppose you accidentally press `gcu` on an *un*commented line.
# `ic` won't select anything, and `gc` will comment the current line.
# That's not what  we want; if there's  no commented line where we  are, then we
# don't want anything to happen.
#}}}
nmap <unique> gcu vic<Plug>(uncomment-selection)
xmap <expr> <Plug>(uncomment-selection) mode() =~ '^[vV<C-V>]$' ? 'gc' : ''

# paste and comment {{{2

# Paste and comment right afterward.
# Rationale:{{{
#
# We often have to press ``]pgc`]`` and it's hard/awkward to type.
#}}}
# How to select the text which I've just pasted with these mappings?{{{
#
# Press `gV` or `g C-v` (custom mappings installed from our vimrc).
#}}}
nnoremap <expr><unique> cp paste.Main(']', '')
nnoremap <expr><unique> cP paste.Main('[', '')

nnoremap <expr><unique> <cp paste.Main(']', '<')
nnoremap <expr><unique> <cP paste.Main('[', '<')

nnoremap <expr><unique> >cp paste.Main(']', '>')
nnoremap <expr><unique> >cP paste.Main('[', '>')

nnoremap <expr><unique> =cp paste.Main(']', '=')
nnoremap <expr><unique> =cP paste.Main('[', '=')

# duplicate code {{{2

nnoremap <expr><unique> +d  duplicate.Main()
nnoremap <expr><unique> +dd duplicate.Main() .. '_'
xnoremap <expr><unique> +d  duplicate.Main()

# comment half a block {{{2

# Useful when we  debug an issue and try  to reduce a custom vimrc  to a minimum
# amount of lines.
nnoremap <expr><unique> gct half.Main('top')
nnoremap <expr><unique> gcb half.Main('bottom')

# motion {{{2

map <unique> ]" <Plug>(next-comment)
map <unique> [" <Plug>(prev-comment)
noremap <expr> <Plug>(next-comment) motion.Main()
noremap <expr> <Plug>(prev-comment) motion.Main(false)
