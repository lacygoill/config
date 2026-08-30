vim9script

# highlight typos in comments
syntax clear sshconfigComment
syntax match sshconfigComment /^#.*$/ contains=@Spell,sshconfigTodo
syntax match sshconfigComment /\s#.*$/ contains=@Spell,sshconfigTodo

#     ForwardX11Trusted
#             ^^
#             should be highlighted as sshconfigKeyword, not as sshconfigNumber
#
# The issue is only visible when the keyword is indented inside a block.
syntax clear sshconfigNumber
syntax match sshconfigNumber /\<\d\+\>/

# Copied from `$VIMRUNTIME/syntax/sshdconfig.vim`:
#
#     syn match sshdconfigTime "\<\(\d\+[sSmMhHdDwW]\)\+\>"
#
# To support this:
#
#     ControlPersist 30m
#                    ^^^
syntax match sshconfigTime /\<\%(\d\+[sSmMhHdDwW]\)\+\>/
highlight default link sshconfigTime sshconfigConstant
