vim9script

# How to hide leading spaces which are highlighted (in blue by default)?{{{
#
#     highlight! link snipLeadingSpaces Normal
#}}}
# Why should I *not* do it?{{{
#
# Most of our lines should be indented with  tabs, so that when a tab trigger is
# expanded, our  buffer-local options  related to indenting  (like 'shiftwidth')
# are taken into account.
#
# So, we should be informed whenever a  line is indented with spaces, because it
# may mean that we need to replace them with tabs.
#}}}

# `snipLeadingSpaces` is invisible when `'termguicolors'` is set.{{{
#
# That's because the default syntax plugin forgot the `cterm=reverse` attribute:
#
#     hi def snipLeadingSpaces term=reverse ctermfg=15 ctermbg=4 gui=reverse guifg=#dc322f
#                              ^----------^                      ^---------^
#
# We could add  `cterm=reverse`, but then leading spaces  would be highlighted
# in red,  instead of  blue (because  the definition  also forgot  the `guibg`
# attribute).  Let's add `guibg=#some_blue_color_code`.
#}}}
if !hlget('snipLeadingSpaces')->get(0, {})->get('cterm', {})->get('reverse')
    import 'vim9SyntaxUtil.vim' as util
    util.Derive('snipLeadingSpaces', 'snipLeadingSpaces',
        {guibg: v:colornames['light steel blue'], default: false})
endif

# TO_DO and FIX_ME are not highlighted if they're directly followed by a colon.{{{
# This is because of:
#
#     syntax iskeyword @,48-57,_,192-255,-,:
#                                          ^
#
# This setting comes from `$VIMRUNTIME/syntax/sh.vim`.
# `~/.vim/pack/vendor/opt/ultisnips/syntax/snippets.vim` loads  the `sh` syntax,
# to correctly highlight a shell interpolation.
#
#     syntax include @Shell syntax/sh.vim
#
# We remove it to join TO_DO and FIX_ME with the colon, like everywhere else.
# BUT: it may break the syntax highlighting inside a shell interpolation.
# I think I value the latter less than the former: I won't use a lot of shell
# interpolation.
#}}}
syntax iskeyword @,48-57,_,192-255,-

# The plugin wrongly uses the `display` argument in a `:syn-keyword` rule.{{{
#
#     syn keyword snipTODO contained display FIXME NOTE NOTES TODO XXX
#                                    ^-----^
#                                       ✘
#
# This causes the word “display” to be unexpectedly highlighted in a comment.
#}}}
syntax clear snipTODO
syntax keyword snipTODO contained FIXME NOTE TODO
