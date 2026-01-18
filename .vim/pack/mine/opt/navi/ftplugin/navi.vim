vim9script

import autoload '../autoload/navi.vim'

# So that Vim inserts a comment leader when we create a new line by pressing `O`
# on a commented line.
&l:comments = ':;,:#'

# We don't support `;` because we write very few comments starting with `;`.
# Besides,  it  would   be  tricky  to  make   comment-related  operators  and
# text-objects support both comment leaders.
&l:commentstring = '# %s'

&l:foldexpr = 'navi.FoldExpr()'
&l:foldmethod = 'expr'
&l:foldminlines = 1
&l:foldtext = 'navi.FoldText()'

augroup navi
    autocmd! * <buffer>
    # Warning: Do *not* listen to `BufWritePost`.{{{
    #
    # If one  of your functions  has to  edit the buffer  to fix an  error, it
    # should  be immediately  synchronized with  the corresponding  file.  But
    # with `BufWritePost`, it would only be synchronized on the next write:
    #
    #     before BufWritePost:
    #         file has error
    #         buffer has error
    #
    #     after first BufWritePost:
    #         file has error
    #         buffer is fixed
    #
    #     after second BufWritePost:
    #         file is fixed
    #         buffer is fixed
    #
    # So, if you  reload the buffer right  after a `:w`rite, your  fix will be
    # lost:
    #
    #     after first BufWritePost:
    #         file has error
    #         buffer is fixed
    #
    #     :edit
    #
    #         file has error
    #         buffer has error
    #
    # With `BufWritePre`:
    #
    #     before BufWritePre:
    #         file has error
    #         buffer has error
    #
    #     after BufWritePre:
    #         file is fixed
    #         buffer is fixed
    #}}}
    autocmd BufWritePre <buffer> {
        navi.NoArgumentInShellComment()
        navi.WarnAgainstUnusedArgument()
        navi.WarnAgainstMissingExpand()
    }
augroup END

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set comments< commentstring< foldexpr< foldmethod< foldminlines< foldtext<'
