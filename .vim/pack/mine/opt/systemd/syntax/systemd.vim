vim9script
# The default plugin actually loads the dosini syntax:{{{
#
#     # $VIMRUNTIME/syntax/systemd.vim
#     runtime! syntax/dosini.vim
#}}}
#   It's not good enough.{{{
#
#    > The syntax is **inspired** by XDG Desktop Entry Specification[1] .desktop
#    > files, which are in turn **inspired** by Microsoft Windows .ini files.
#
# Source: `man systemd.syntax /inspired`
#
# As an example, the `dosini` syntax plugin doesn't correctly handle a multiline
# value:
#
#     [Section]
#     KeyOne=value 1 \
#         value 1 continued
#
#     KeyTwo=value 2\
#     # this line is ignored
#     ; this line is ignored too
#            value 2 continued
#
# ---
#
# Besides, it's nice having more control over what is highlighted and how.
# In particular, we can get more meaningful syntax names when we press `!s`.
#}}}

if exists('b:current_syntax')
    finish
endif

# `extend` to account for a possible comment embedded inside a multi-line value.
syntax match systemdComment /^\s*[#;].*$/ contains=@Spell,systemdTodo extend
syntax keyword systemdTodo TODO FIXME contained
syntax region systemdSection start=/^\s*\[/ end=/\]/

syntax match systemdDirective /^\s*[^;#[:blank:]].\{-}\ze=/ nextgroup=systemdValue skipwhite
# `keepend` to prevent a final number value from consuming the end:{{{
#
#     A=123
#     B=...
#     ^---^
#     that's not a continuation of the previous 123 value
#}}}
syntax region systemdValue
    \ start=/=/hs=s+1
    \ end=/[^\\]$/
    \ contained
    \ contains=systemdComment,systemdContinuationLine,systemdNumber
    \ keepend
    # fix: the previous  rule might wrongly highlight a parameter  as a value if
    # the parameter on the previous line is empty
    syntax match systemdValue /=$/ transparent
syntax match systemdContinuationLine /\\$/ contained

syntax match systemdNumber /=\@1<=\d\+\_s\@=/ contained
syntax match systemdNumber /=\@1<=\d*\.\d\+\_s\@=/ contained
syntax match systemdNumber /=\@1<=\d\+e[+-]\=\d\+\_s\@=/ contained

highlight default link systemdComment Comment
highlight default link systemdContinuationLine Special
highlight default link systemdDirective Identifier
highlight default link systemdNumber Number
highlight default link systemdSection Title
highlight default link systemdTodo Todo
highlight default link systemdValue String

b:current_syntax = 'systemd'
