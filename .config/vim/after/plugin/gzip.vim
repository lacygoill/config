vim9script

# `$MYVIMRC == ''`: To  avoid `E216: No such group or event: SwapfileHandling`
# when we start Vim with `-Nu NORC`.
if exists('loaded') || $MYVIMRC == ''
    finish
endif
var loaded = true

# Problem: `E325` is given when we read an archive in multiple Vim instances.{{{
#
# It should  be automatically handled  by our `SwapfileHandling`  autocmd from
# our vimrc, but it's not.  The error is given when the `gzip` plugin tries to
# edit the  buffer on  `BufReadPre`.  I  guess the latter  is fired  too early
# (before `SwapExists`).
#}}}
# Solution: Temporarily include the `A` flag in `'shortmess'` to suppress the error.{{{
#
# In theory,  that's wrong.  We should  not simply suppress such  a meaningful
# error.  But in  practice, that should not cause any  issue, because we never
# directly edit an archive using the `gzip` Vim plugin.
#}}}
# We can't install this autocmd in our vimrc.{{{
#
# It would prevent the `gzip` plugin from being sourced:
#
#     # $VIMRUNTIME/plugin/gzip.vim
#     if exists("loaded_gzip") || &cp || exists("#BufReadPre#*.gz")
#                                        ^------------------------^
#}}}
# The pattern is copied from `$VIMRUNTIME/plugin/gzip.vim`.
autocmd! SwapfileHandling BufReadPre *.gz,*.bz2,*.Z,*.lzma,*.xz,*.lz,*.zst,*.br,*.lzo set shortmess+=A
autocmd! SwapfileHandling BufReadPost *.gz,*.bz2,*.Z,*.lzma,*.xz,*.lz,*.zst,*.br,*.lzo set shortmess-=A
