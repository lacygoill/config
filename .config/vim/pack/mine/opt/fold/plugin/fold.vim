vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/fold/adhoc.vim'
import autoload '../autoload/fold/collapseExpand.vim'
import autoload '../autoload/fold/comment.vim'
import autoload '../autoload/fold/lazy.vim'
import autoload '../autoload/fold/motion.vim'

# Mappings {{{1

nnoremap <unique> H <ScriptCmd>collapseExpand.Hlm('H')<CR>
nnoremap <unique> L <ScriptCmd>collapseExpand.Hlm('L')<CR>
nnoremap <unique> M <ScriptCmd>collapseExpand.Hlm('M')<CR>

# Purpose: automatically add an empty line at the end of a multi-line comment so
# that the end marker of the fold is on a dedicated line.
nnoremap <expr><unique> zfic comment.Main()

# Why don't you use an autocmd to automatically fold a logfile?{{{
#
# 1. a logfile could have no `.log` extension
#
# 2. a logfile can be very big
#
#    Folding a big file can be slow.
#    We should not pay this price systematically, only when we decide.
#}}}
nnoremap <unique> za <ScriptCmd>adhoc.Main()<CR>

map <unique> ]z <Plug>(next-fold)
map <unique> [z <Plug>(prev-fold)
noremap <expr> <Plug>(next-fold) motion.Rhs(']z')
noremap <expr> <Plug>(prev-fold) motion.Rhs('[z')

# Make sure  that all normal folding  commands recompute the folds  (i.e. invoke
# our `lazy.Compute()`).
{
    var fold_cmds: list<string> =<< trim END
        zA
        zC
        zM
        zO
        zR
        zX
        zc
        zo
        zv
        zx
    END
    var mapcmd: string = 'nnoremap <unique> %s'
        .. ' <ScriptCmd>lazy.Compute()'
        .. ' <Bar> execute "normal! " .. (v:count != 0 ? v:count : "") .. "%s"<CR>'
    for cmd: string in fold_cmds
        execute printf(mapcmd, cmd, cmd)
    endfor
    execute printf(mapcmd, '<space><space>', 'za')
}

# I think that we sometimes try to open a fold from visual mode by accident.
# It leads to an unexpected visual selection; let's prevent this from happening.
xnoremap <unique> <Space><Space> <C-\><C-N>

# Autocmds{{{1

augroup LazyFold
    autocmd!
    # recompute folds in all windows displaying the current buffer,
    # after saving it or after the foldmethod has been set by a filetype plugin
    autocmd BufWritePost,FileType * lazy.ComputeWindows()

    # restore folds after a diff{{{
    #
    # Here's what happens to `'foldmethod'` when we diff a file which is folded with an expr:
    #
    #    1. foldmethod=expr (set by filetype plugin)
    #    2. foldmethod=manual (reset by vim-fold)
    #    3. foldmethod=diff (reset again when we diff the file)
    #
    # When we stop  the diff with `:diffoff`, Vim  automatically resets `'diff'`
    # to `manual`, because:
    #
    #    > Resets related options also when 'diff' was not set.
    #
    # Source: `:help :diffoff`
    #
    # However, the folds have been lost when `'diff'` was set.
    # We need  to make Vim recompute  them according to the  original foldmethod
    # (the one set by our filetype plugin).
    #}}}
    autocmd OptionSet diff lazy.HandleDiff()
augroup END
