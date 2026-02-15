vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/scriptease.vim'

# TODO: https://github.com/tpope/vim-scriptease/commit/74bd5bf46a63b982b100466f9fd47d2d0597fcdd

# TODO: Sometimes, an expression is too long to read.
# New feature: put the  expression in a new buffer, and fold  the latter so that
# we can easily focus on an arbitrary part of the object.
command -range=-1 -nargs=? -complete=expression PP scriptease.PPI(<q-args>, <count>)
command -range=0 -nargs=? -complete=expression PPmsg scriptease.PPmsg(<q-args>, <count>)

# Use this script as a test:
#
#     vim9script
#
#     def g:Tree(dir: string): dict<list<any>>
#         return {[dir]: readdir(dir)
#             ->mapnew((_, x: string): any =>
#                     isdirectory(x)
#                     ?     {[x]: g:Tree(dir .. '/' .. x)}
#                     : x
#             )}
#     enddef
#     PP g:Tree($HOME)
