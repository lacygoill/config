vim9script

syntax match weechatCommand #\_[[:blank:]?:]\@1<=/\l\+\_[ }]\@=#
#                                        ^^
#                                  ternary conditional operator{{{
#
# Example:
#
#     /key bind meta-up /eval ${if:${buffer.number} == 1 ?/mute :/buffer move -1}
#                                                        ^----^ ^------^
#}}}
highlight default link weechatCommand Statement

syntax match weechatCommand +/alias\s\@=+ nextgroup=weechatAliasAdd skipwhite
syntax keyword weechatAliasAdd add nextgroup=weechatAliasName contained skipwhite
syntax match weechatAliasName /\w\S*/ nextgroup=weechatAliasFirstCommand contained skipwhite
syntax match weechatAliasFirstCommand -/\=\w\S*- contained
highlight default link weechatAliasFirstCommand Statement
highlight default link weechatAliasName weechatBold

syntax match weechatCommand +/filter\s\@=+ nextgroup=weechatFilterAdd skipwhite
syntax keyword weechatFilterAdd add nextgroup=weechatFilterName contained skipwhite
syntax match weechatFilterName /\w\S*/ nextgroup=weechatFilterBuffers contained skipwhite
syntax match weechatFilterBuffers /\S\+/
    \ contained
    \ contains=weechatFilterSeparator
    \ nextgroup=weechatFilterTags
    \ skipwhite
syntax match weechatFilterTags /\S\+/
    \ contained
    \ contains=weechatFilterSeparator
syntax match weechatFilterSeparator /[,+]/ contained
highlight default link weechatBold Bold
highlight default link weechatFilterName weechatBold
highlight default link weechatFilterBuffers Structure
highlight default link weechatFilterTags Special
highlight default link weechatFilterSeparator Delimiter

syntax match weechatCommand +/ignore\s\@=+ nextgroup=weechatIgnoreAdd skipwhite
syntax keyword weechatIgnoreAdd add contained nextgroup=weechatIgnoreNickOrHost skipwhite
syntax match weechatIgnoreNickOrHost /\S\+/ contained
highlight default link weechatIgnoreNickOrHost Exception

syntax match weechatKeyBinding #/key\s\@=# nextgroup=weechatKeySubcmd skipwhite
syntax keyword weechatKeySubcmd bind unbind contained nextgroup=weechatKey skipwhite
syntax keyword weechatKeySubcmd bindctxt unbindctxt contained nextgroup=weechatKeyContext skipwhite
syntax match weechatKeyContext /\S\+/ contained nextgroup=weechatKey skipwhite
syntax match weechatKey /[^, ]\+/ contained nextgroup=weechatKeyComma
syntax match weechatKeyComma /,/ contained nextgroup=weechatKey
highlight default link weechatKeyBinding Statement
highlight default link weechatKeyComma Delimiter
highlight default link weechatKey Special

syntax match weechatCommand +/\%(set\|unset\|toggle\)\s\@=+ nextgroup=weechatOption skipwhite
syntax match weechatOption /\l[-a-zA-Z0-9._,#]\+/ contained
highlight default link weechatOption Type

syntax match weechatCommand +/trigger\s\@=+ nextgroup=weechatTriggerAdd skipwhite
syntax keyword weechatTriggerAdd add contained nextgroup=weechatTriggerName skipwhite
syntax match weechatTriggerName /\w\S*/ contained
highlight default link weechatTriggerName weechatBold

syntax match weechatBool /\<\%(on\|off\)\>/
highlight default link weechatBool Boolean

# Note that right after the comment leader, there might be nothing, a Vim fold
# marker, a space, or some exotic space (like a no-break space).
syntax match weechatComment /^\s*#\w\@!.*/ contains=weechatTodo,@Spell
syntax match weechatComment /\s#\w\@!.*/ms=s+1 contains=weechatTodo,@Spell
syntax match weechatTodo /\<\%(FIXME\|TODO\)\ze:\=\>/ contained
highlight default link weechatComment Comment
highlight default link weechatTodo Todo

syntax region weechatConditionalExpr
    \ matchgroup=Operator
    \ start=/${if:/
    \ end=/}/
    \ contains=
    \     weechatContinuationLine
    \     ,weechatCommand
    \     ,weechatConditionalExpr
    \     ,weechatNumber
    \     ,weechatOperator
    \     ,weechatVariable

syntax match weechatContinuationLine /\\$/
highlight default link weechatContinuationLine Special

syntax match weechatNumber /[-+]\=\<\d\+\>%\=/
highlight default link weechatNumber Number

syntax match weechatOperator /[!=]=/ contained
syntax match weechatOperator /[<>]=\=/ contained
syntax match weechatOperator /[?:]/ contained
syntax match weechatOperator /&&\|||/ contained
highlight default link weechatOperator Operator

syntax region weechatString start=/"\n\@!/ skip=/\\\\\|\\"/ end=/"/ contains=weechatContinuationLine
syntax region weechatString start=/'\n\@!/ skip=/\\\\\|\\'/ end=/'/ contains=weechatContinuationLine
highlight default link weechatString String

syntax region weechatVariable start=/${\%(if:\)\@!/ end=/}/ contains=weechatVariable
# `$123` in `/alias` commands
syntax match weechatVariable /\$\d\+\|\$\*/
highlight default link weechatVariable Identifier

b:current_syntax = 'weechat'
