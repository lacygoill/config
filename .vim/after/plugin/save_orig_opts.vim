vim9script

if exists('loaded')
    finish
endif
var loaded = true

# We need to save the original value of some options.{{{
#
# We can't do  it from our vimrc;  that's too early, because we  might want to
# tweak some option from another plugin.
#
# We  can't do  it  from a  `VimEnter`  autocmd; that's  too  late, because  a
# filetype plugin might have already reset some option (e.g. the Perl filetype
# plugin resets `'isfname'`).
#
# This script  seems to be  sourced at the right  time; after all  our plugins
# have been sourced, but before any filetype plugin.
#}}}

# Do *not* make the constant name start with an uppercase character.{{{
#
# It would cause all sorts of issues  because of the `!` flag which we include
# in `'viminfo'`.
#
#     Don't  try to  be smart  and install  a `VimLeavePre`  autocmd to  unlet the
#     variable (it wouldn't always work; e.g.  when debugging a crash).  Don't try
#     a `VimEnter`  autocmd to delay `:lockvar`  either; I'm sure we  would end up
#     finding some other corner case where it fails.
#}}}
g:_ORIG_OPTS = {
    completeopt: &g:completeopt->split(',')->sort(),
    diffopt: &g:diffopt->split(',')->sort(),
    eventignore: &g:eventignore,
    ignorecase: &g:ignorecase,
    isfname: &g:isfname,
    iskeyword: &g:iskeyword,
    paste: &g:paste,
    virtualedit: &g:virtualedit,
    wrapscan: &g:wrapscan,
}
lockvar! g:_ORIG_OPTS

# Special Case: We  can't save  `'cpoptions'` right from  here, because,  in a
# Vim9 script, it's temporarily reset to its default value.
autocmd VimEnter * {
    unlockvar! g:_ORIG_OPTS
    g:_ORIG_OPTS->extend({'cpoptions': &g:cpoptions->split('\zs')->sort()})
    lockvar! g:_ORIG_OPTS
}
