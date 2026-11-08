vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/breakdown.vim'

xnoremap <unique> +c <C-\><C-N><ScriptCmd>breakdown.CenterText()<CR>

# Why not `+^`?{{{
#
# I often press `g^` by accident, which atm makes us focus the first tabpage.
# Too distracting.
#}}}
nnoremap <expr><unique> +v breakdown.PutErrorSign('below')
nnoremap <expr><unique> +V breakdown.PutErrorSign('above')

xnoremap <unique> +v <C-\><C-N><ScriptCmd>breakdown.PutV('below')<CR>
xnoremap <unique> +V <C-\><C-N><ScriptCmd>breakdown.PutV('above')<CR>

# TODO: If possible, use `append()` or `setline()` instead of `:normal` to draw a diagram.  It's faster.

# TODO: We should be able to create a diagram mixing simple branches and buckets.
# We would need 2 keys: one to set a simple branch, one for the two ends of a bucket.

# TODO: Add support for text written before diagram (instead of after){{{
#
# For the LHS use:    m((
#                     m() above the line, to the right of the diagram
#                     m)( below the line, to the left of the diagram
#                     m))
#
#                     m{{
#                     m{}
#                     m}{
#                     m}}
#
# We would have to change the mappings like this:
#
#     nnoremap m(( <ScriptCmd>breakdown.Main('bucket', 'above', 'before')<CR>
#     nnoremap m() <ScriptCmd>breakdown.Main('bucket', 'above', 'after')<CR>
#     nnoremap m)( <ScriptCmd>breakdown.Main('simple', 'above', 'before')<CR>
#     nnoremap m)) <ScriptCmd>breakdown.Main('simple', 'above', 'after')<CR>
#
# And adapt `draw()` and `populate_loclist()`.
#
# Example of bucket diagram:
#
#                                     search('=\%#>', 'bn', line('.'))
#                                            ├─────┘  ├──┘  ├───────┘
#                                            │        │     └ search in the current line only
#                                            │        │
#                                            │        └ backward without moving the cursor and
#                                            │
#                                            └ match any `=[>]`, where `[]` denotes the
#                                              cursor's position
#
# Example of reverse bucket diagram:
#
#                                     search('=\%#>', 'bn', line('.'))
#                                            └─────┤  └──┤  └───────┤
#         match any `=[>]`, where `[]` denotes the ┘     │          │
#                                                        │          │
#                 cursor's position                      │          │
#                 backward without moving the cursor and ┘          │
#                                                                   │
#                                   search in the current line only ┘
#
#
# Example of simple diagram:
#
#                                     search('=\%#>', 'bn', line('.'))
#                                            │        │     │
#                                            │        │     └ search in the current line only
#                                            │        │
#                                            │        └ backward without moving the cursor and
#                                            │
#                                            └ match any `=[>]`, where `[]` denotes the cursor's position
#
# Example of reverse simple diagram:
#
#                                         search('=\%#>', 'bn', line('.'))
#                                                │        │     │
#       match any `=[>]`, where `[]` denotes the ┘        │     │
#       cursor's position                                 │     │
#                                                         │     │
#                  backward without moving the cursor and ┘     │
#                                                               │
#                               search in the current line only ┘
