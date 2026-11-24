vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/reorder.vim'

# Mappings {{{1

nnoremap <expr><unique> gr  reorder.Main('reverse')
nnoremap <expr><unique> grr reorder.Main('reverse') .. '_'
xnoremap <expr><unique> gr  reorder.Main('reverse')

nnoremap <expr><unique> gs  reorder.Main('sort')
nnoremap <expr><unique> gss reorder.Main('sort') .. '_'
xnoremap <expr><unique> gs  reorder.Main('sort')

nnoremap <expr><unique> gS  reorder.Main('shuf')
nnoremap <expr><unique> gSS reorder.Main('shuf') .. '_'
xnoremap <expr><unique> gS  reorder.Main('shuf')

# Usage: {{{1

#     gs          operator to sort
#     gr          operator to reverse the order
#     gS          "           randomize the order
#
#     gsip        sort paragraph
#     5gss        sort 5 lines
#     gsib        sort text between parentheses


# When we call the operators with a characterwise motion / text-object,
# they try to guess what's the separator between the texts to sort.
# Indeed, in this case, the separator is probably not a newline, but a comma,
# a semicolon, a colon or a space.


# Sample texts to test the operators:

#     (b; c; a)    gsib
#     (b  c  a)    gsib

#     b    3gss or gsip
#     c
#     a
