vim9script noclear

if exists('loaded') || stridx(&runtimepath, '/ultisnips,') == -1
    finish
endif
var loaded = true

import autoload '../autoload/plugin/ultisnips.vim'

var Derive: func
if stridx(&runtimepath, '/vim9-syntax,') != -1
    import 'vim9SyntaxUtil.vim'
    Derive = vim9SyntaxUtil.Derive
    lockvar! Derive
endif

# Mappings {{{1

# Why not `<Tab>`/`<S-Tab>`?{{{
#
# It would make our code much more  complex because we would have to work around
# various mappings  installed by Ultisnips  (including temporary ones,  local to
# the buffer).  It's much simpler to prevent UltiSnips from interfering entirely
# with what we  want to do with  `<Tab>` and `<S-Tab>`.  So, we  feed it useless
# keys.
#}}}
# OK, but why S-F7..9 ? {{{
#
# We're looking for unused keys, which will stay unused in the future.
# Currently, the maximum value `xx` to create a `<F-xx>` LHS is `37`:
# https://github.com/vim/vim/blob/8858498516108432453526f07783f14c9196e112/src/keymap.h#L194
#
# Beyond  this value,  creating a  mapping would  shadow the  `<` key,  probably
# because it's not interpreted as a function key anymore.
#}}}
g:UltiSnipsExpandTrigger = '<S-F7>'
g:UltiSnipsJumpForwardTrigger = '<S-F8>'
g:UltiSnipsJumpBackwardTrigger = '<S-F9>'
# Remove select mode mappings using printable characters {{{

# From `:help mapmode-s`:
#
#    > Some commands work both in Visual and Select mode, some in only one.
#    > Note that quite often "Visual" is mentioned where both Visual and Select
#    > mode apply.
#    > NOTE: Mapping a printable character in Select mode may confuse the user.
#    > It's better to explicitly use :xmap, and :smap for printable characters.
#    > Or use :sunmap after defining the mapping.
#
# It probably implies that mapping a printable character in select mode is a bad
# idea.  For example, suppose that a plugin install this mapping:
#
#     :snoremap z abc
#
# When the user will hit `z` in select mode, he will expect the selected text
# to be replaced by the `z` character.
# But in fact, the selected text will be replaced by `abc`.
# This unexpected behavior can happen because some plugins use the `:v(nore)map`
# command instead of `:x(nore)map`.
#
# It could pose a pb for UltiSnips, when a tabstop is selected and we hit some
# character to  replace the  selection.  Therefore, by  default, each  time we
# expand a tab  trigger, UltiSnips removes all the select  mode mappings whose
# LHS is a printable character.
#
# We like that (no printable character in a select mode mapping):
#}}}
g:UltiSnipsRemoveSelectModeMappings = true

# Purpose: gain the ability to manually end the expansion of a snippet
# Where did you find the code for the RHS of the mapping?{{{
#
# https://github.com/SirVer/ultisnips/issues/1017#issuecomment-452154595
#
# Note that  we can't  use `g:_uspy` anymore;  probably since  UltiSnips dropped
# python2 support: https://github.com/SirVer/ultisnips/pull/1129
#}}}
inoremap <unique> <C-G><S-Tab> <ScriptCmd>silent! py3 UltiSnips_Manager._current_snippet_is_done()<CR>

# We want Tab in visual mode to use the `{VISUAL}` token inside ultisnips snippets.
# Where does the RHS come from?{{{
#
# Give a valid key to `g:UltiSnipsExpandTrigger`, e.g.:
#
#     g:UltiSnipsExpandTrigger = '<C-G>e'
#
# Then, restart Vim, and type:
#
#     verbose xmap <C-G>e
#}}}
# Why do we need to install this mapping manually?{{{
#
# Because, we purposefully gave an invalid value to `g:UltiSnipsExpandTrigger`.
#}}}
xnoremap <unique> <Tab> <C-\><C-N><ScriptCmd>:* call UltiSnips#SaveLastVisualSelection()<CR>gvs
#                                               ^--^
# Why `:call`?  Isn't it useless in Vim9?{{{
#
# Usually, yes,  it is.   Except if  you need  to call  a legacy  function which
# expects to handle a range via `a:firstline` and `a:lastline`.
# That's exactly what `UltiSnips#SaveLastVisualSelection()` is.
#}}}
#   OK, but isn't that a bad mechanism?{{{
#
# Yes, a range should be passed explicitly:
#
#     ✘
#     function Func() range
#         echo 'start of range: ' .. a:firstline
#         echo 'end of range: ' .. a:lastline
#     endfunction
#     :* call Func()
#
#     ✔
#     function Func(lnum1, lnum2)
#         echo 'start of range: ' .. a:lnum1
#         echo 'end of range: ' .. a:lnum2
#     endfunction
#     Func(line("'<"), line("'>"))
#
# But we have no control over this function; it's provided by UltiSnips.
# IOW, this weird `call` is necessary to call a weird legacy function.
#}}}

# We need a way to enable UltiSnips's autotrigger on-demand.
nnoremap <unique> cou <ScriptCmd>ultisnips.ToggleAutoTrigger()<CR>

# Autocmds {{{1

augroup MyUltisnips
    autocmd!

    # useful during a snippet expansion  to prevent the highlighting of trailing
    # whitespace, and to get a flag in the status line
    autocmd User UltiSnipsEnterFirstSnippet g:expanding_snippet = true
    autocmd User UltiSnipsExitLastSnippet unlet! g:expanding_snippet
    # necessary in case a wrong snippet causes UltiSnips to dump a stack trace in a new window{{{
    #
    # Because in that case `UltiSnipsExitLastSnippet` is not fired.
    #
    # Btw, don't  use `WinLeave`.   Focusing a  different window  displaying the
    # same buffer does not end the  snippet expansion.  OTOH, the expansion does
    # end when you focus a different buffer.
    #}}}
    autocmd User UltiSnipsEnterFirstSnippet autocmd BufLeave * ++once unlet! g:expanding_snippet

    # An expanded snippet may break the detection of the current fold.{{{
    #
    #     $ mkdir /tmp/snippets
    #     $ tee /tmp/snippets/vim.snippets <<'EOF'
    #     snippet ab ""
    #     x
    #     x
    #     endsnippet
    #     EOF
    #
    #     $ tee /tmp/vimrc <<'EOF'
    #         let g:UltiSnipsSnippetDirectories = ['/tmp/snippets']
    #         let g:UltiSnipsExpandTrigger = '<Tab>'
    #         set runtimepath-=$HOME/.vim
    #         set runtimepath-=$HOME/.vim/after
    #         set runtimepath^=$HOME/.vim/pack/vendor/opt/ultisnips
    #         filetype on
    #         setlocal foldmethod=marker
    #     EOF
    #
    #     $ vim -Nu /tmp/vimrc +":% delete _ | :0 put =['\\\"{{' .. '{', '\\\"}}' .. '}']" /tmp/vim.vim
    #     # press:
    #     #   zo to open the fold
    #     #   O to open new line inside the fold
    #     #   ab to insert tab trigger
    #     #   tab to expand snippet
    #     #   Esc to get back to normal mode
    #     #   zc to close the fold
    #
    # At the  end, you'll notice the  fold can't be closed,  because Vim doesn't
    # detect  it  anymore.   Most  probably,  UltiSnips  interfered  with  Vim's
    # internal info about the fold; it edited  the buffer in such a way that Vim
    # was not able to track the changes, and its info about the fold got stale.
    #
    # In practice, it does not happen all the time.
    # For  example, in  the previous  MRE, if  you remove  one `x`  line in  the
    # snippet, the issue disappears.
    #}}}
    #   Why don't you listen to `UltiSnipsEnterFirstSnippet` too?{{{
    #
    # It wouldn't work.
    #
    # We would need to slightly delay the command; e.g. with a timer.
    # I  don't like  using  a timer  here;  it  looks like  a  hack, which  will
    # sometimes make UltiSnips behave unexpectedly (e.g. stack trace).
    #}}}
    #   Why only if the foldmethod is 'marker'?{{{
    #
    # I don't think it's needed when we use `expr`, `indent` or `syntax`.
    # For  those methods,  our  fold-related mappings  (like  `SPC SPC`)  should
    # recompute the folds (via `fold#lazy#Compute()`).
    #
    # Besides, `zx`  has the side  effect of re-applying `'foldlevel'`  which in
    # our case closes  all the other folds;  so, better use it  when it's really
    # necessary (to preserve the other folds state).
    #}}}
    var view: dict<number>
    autocmd User UltiSnipsExitLastSnippet {
        if &l:foldmethod == 'marker'
            view = winsaveview()
            execute 'normal! zx'
            winrestview(view)
        endif
    }

    # let us know when a snippet is being expanded
    silent! Derive('Ulti', 'Visual', {gui: {bold: true}, term: {bold: true}, cterm: {bold: true}})
    autocmd User MyFlags g:StatusLineFlag('buffer', '%#Ulti#%{plugin#ultisnips#Status()}',
        \ 55, expand('<sfile>:p') .. ':' .. expand('<sflnum>'))

    # Inserting the output of a shell command in a snippet can cause visual artifacts.{{{
    #
    # MRE:
    #
    #     snippet foo "" bm
    #     ${1:a}`!v system('lsb_release -d')`
    #     endsnippet
    #
    # Besides, if the output of the shell command is always the same (e.g. `$ st -v`),
    # it's inefficient to call a shell every time we expand a snippet.
    #
    # Solution: Save all the info you need  in a global Vim dictionary, when you
    # enter your first snippet, and refer to it in your snippets.
    #}}}
    # Why don't you listen to `UltiSnipsEnterFirstSnippet` instead?{{{
    #
    # Yeah, I tried that in the past.
    # It worked most of the time, but not always.
    # Sometimes, expanding  a snippet  caused ultisnips  to crash  and open  a split
    # window with a stack trace.
    # I think that's because the event is not always fired...
    # I'm tired of this issue; let's call the function from `InsertEnter`.
    #}}}
    autocmd InsertEnter * ultisnips.SaveInfo()

    # Importing a long file with `:read` while a snippet is being expanded may cause a memory leak.{{{
    #
    # There may be other Ex commands which trigger the issue.
    # To be  safe, let's  make UltiSnips  automatically end  the expansion  of a
    # snippet when we enter the command-line.
    #
    # ---
    #
    # Atm, I can reproduce the issue when  I expand the snippet `vimrc` in a new
    # file, then move the cursor at the end of the file, and execute `:read $MYVIMRC`.
    #
    # I'm not sure but this may be due to this issue:
    #
    # https://github.com/SirVer/ultisnips/issues/155#issuecomment-244889469
    #
    # ---
    #
    # When we expand a  snippet in a new file, it seems we  can't exit it simply
    # by moving outside.
    # I  suspect that's  because,  initially,  there are  no  lines outside  the
    # snippet, since there are no lines at all in a new file.
    #}}}
    autocmd User UltiSnipsEnterFirstSnippet ultisnips.PreventMemoryLeak()
    # `silent!` to suppress errors when the event is fired twice consecutively
    # (yeah, for some reason, it can happen)
    # Why not in dirvish? {{{
    #
    # To suppress  `E31` when we open  a dirvish buffer while  a snippet is
    # being expanded:
    #
    #     Error detected while processing function <SNR>16_LoadFTPlugin[2]..plugin#dirvish#UndoFtplugin:
    #     line   14:
    #     E31: No such mapping
    #
    # For some reason, `b:undo_ftplugin` is executed; and the latter unmaps
    # `p` (without `silent!`).  So there's no need to unmap `p` here.
    #
    # Don't try  to understand why `b:undo_ftplugin`  is executed.  Dirvish
    # seems full of special code.
    # }}}
    autocmd User UltiSnipsExitLastSnippet {
        execute 'silent! nunmap <buffer> :'
        if &filetype != 'dirvish'
            execute 'silent! nunmap <buffer> p'
        endif
    }
    # Pitfall: If you try to replace the `:` mapping with a `CmdlineEnter` autocmd, use `state()`:{{{
    #
    #     autocmd User UltiSnipsEnterFirstSnippet autocmd CmdlineEnter : ++once
    #         \ if state('m') == '' | ultisnips.CancelExpansion() | endif
    #
    # Without the `state()` guard, you may exit a snippet prematurely.
    # That's what  happens atm  with the  `if` snippet, when  you jump  from the
    # `else` tabstop.
    #}}}
augroup END

# Miscellaneous {{{1

# When we execute `:UltiSnipsEditSplit`, we want to open the snippet file in
# an horizontal split.
g:UltiSnipsEditSplit = 'horizontal'

# We want UltiSnips to look for the snippet files in only 1 directory.{{{
#
#     ~/.vim/pack/mine/opt/snippets/UltiSnips
#
# ... and  only there;  i.e. not  in a  public snippet  directory provided  by a
# third-party plugin:
#
#     https://github.com/honza/vim-snippets

# This has also the benefit of increasing the performance, because UltiSnips
# won't search the runtimepath.
#}}}
g:UltiSnipsSnippetDirectories = [$HOME .. '/.vim/pack/mine/opt/snippets/UltiSnips']

# Prevent UltiSnips from looking for SnipMate snippets.{{{
#
# Those are in sub-directories of the runtimepath ending with `snippets/`.
#
# If we don't do this, UltiSnips will load SnipMate snippets that we install
# from a third party plugin, even though we've set `g:UltiSnipsSnippetDirectories`
# to a single absolute path.
#}}}
g:UltiSnipsEnableSnipMate = false

# But don't do it for Tab!{{{
#
# Tab is NOT a printable character, but UltiSnips seems to unmap it as if it was one.
#}}}
g:UltiSnipsMappingsToIgnore = ['completion#SnippetOrComplete']
# For more info: `:help UltiSnips-warning-smapping`
# Edit: It doesn't seem necessary anymore, but I'll keep it anyway, just in case...
