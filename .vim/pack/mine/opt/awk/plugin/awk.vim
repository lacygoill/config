vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# These options control how the `=` operator indent lines.
# For more info, read the top of the script at `./indent/awk.vim`.

#     g:awk_indent_switch_labels = 0{{{
#             switch (label) {
#             case /A/:
#
#     g:awk_indent_switch_labels = 1
#             switch (label) {
#                 case /A/:
#                                      (default: 1, disable: -1)
#}}}
g:awk_indent_switch_labels = 1

#     g:awk_indent_curly_braces = 0{{{
#             if (brace)
#             {
#
#     g:awk_indent_curly_braces = 1
#             if (brace)
#                 {
#                                       (default: 0)
#}}}
g:awk_indent_curly_braces = 1

#     g:awk_indent_tail_bslash = 2{{{
#
#             function_name(  \
#                           arg1, arg2, arg3)
#
#     g:awk_indent_tail_bslash = -2
#
#             function_name(  \
#                 arg1, arg2, arg3)
#                                       (default: 2, disable: 0)
#}}}
g:awk_indent_tail_bslash = -2
