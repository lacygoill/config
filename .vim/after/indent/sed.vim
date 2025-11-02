vim9script

# The default indentation is wrong.{{{
#
#     /pat/{
#     s/foo/bar/
#     s/foo/bar/
#     }
#
#     =ip →
#
#     /pat/{
#         s/foo/bar/
#             s/foo/bar/
#     }
#
# Since `'indentexpr'` and `'equalprg'` are empty  in a sed buffer by default,
# Vim uses  the internal formatting function  (`:help C-indenting`).  Not sure
# it can be configured for sed code.
#}}}

&l:indentexpr = 'Indent()'

if !exists('*Indent')
    def Indent(lnum = v:lnum): number
        if lnum == 1
            return 0
        endif
        var prev_lnum: number = prevnonblank(lnum - 1)
        var prev_indent: number = indent(prev_lnum)
        if getline(prev_lnum) =~ '{$'
            return prev_indent + shiftwidth()
        endif
        if getline(lnum) =~ '^\s*}$'
            return prev_indent - shiftwidth()
        endif
        return prev_indent
    enddef
endif

# Teardown {{{1

b:undo_indent = (get(b:, 'undo_indent') ?? 'execute')
    .. '| set indentkeys<'
