vim9script

if exists('b:current_syntax')
    finish
endif

syntax match apparmorComment /#.*$/ contains=@Spell
syntax match apparmorInclude /^\s*#include\>/ nextgroup=apparmorIncludePath skipwhite
syntax match apparmorIncludePath /.*$/ contained

highlight default link apparmorComment Comment
highlight default link apparmorInclude Include
highlight default link apparmorIncludePath String

b:current_syntax = 'apparmor'
