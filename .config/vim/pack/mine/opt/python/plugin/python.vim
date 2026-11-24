vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# Do *not* set this variable in a filetype plugin.{{{
#
# It  makes  it  hard to  understand  how  the  variable  will be  handled  at
# runtime.  For example, the first time  you read a Python file, your filetype
# plugin will set `g:python_indent`.  Then, the  first time you indent a line,
# an autoload script will be sourced which will extend `g:python_indent`.  But
# you do *not* want to overwrite this extension, so you'll need a guard:
#
#     if !exists('g:python_indent')
#         ...
#     endif
#
# We fell  into this  pitfall in  the past,  and lost  time debugging  a wrong
# indentation.   Besides, should  you  set it  in  `/after/ftplugin/` or  just
# `/ftplugin/`?   Also, setting  a global  variable  in a  local plugin  looks
# weird.
#
# In any case, it's  much easier to set a global variable  in a regular plugin
# which is only sourced one.
#}}}
g:python_indent = {
    # In a multiline construct, use 1 shiftwidth of indentation:{{{
    #
    #     dict = {
    #         'a': 1
    #         'b': 2
    #         'c': 3
    #     }
    #
    # The default is 2 shiftwidths.
    #}}}
    open_paren: 'shiftwidth()',
    # Don't align a closing paren like this:{{{
    #
    #     d = {
    #         a: 1,
    #         b: 2,
    #         }
    #         ^
    #         ✘
    #
    # But like this:
    #
    #     d = {
    #         a: 1,
    #         b: 2,
    #     }
    #     ^
    #     ✔
    #}}}
    closed_paren_align_last_line: false,
}
