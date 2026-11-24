vim9script

&l:foldmethod = 'expr'
&l:foldexpr = 'RstFoldExpr()'

def RstFoldExpr(): string
    # https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html#sections
    var lines: string = getline(v:lnum, v:lnum + 1)->join("\n")
    # The regex comes from `$VIMRUNTIME/syntax/rst.vim`.
    # Look at `:syntax list rstSections`.
    if lines =~ '\v^%(([=`:.''"~^_*+#-])\1{2,}\n)?.{3,}\n([=`:.''"~^_*+#-])\2{2,}$'
        return '>1'
    endif
    return '1'
enddef

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. ' | set foldmethod< foldexpr<'
