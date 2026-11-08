vim9script

# highlight typos in comments
syntax clear sshdconfigComment
syntax match sshdconfigComment /^#.*$/ contains=@Spell,sshdconfigTodo
syntax match sshdconfigComment /\s#.*$/ contains=@Spell,sshdconfigTodo

#     X11Forwarding
#      ^^
#      should be highlighted as sshdconfigKeyword, not as sshdconfigNumber
#
# The issue is only visible when the keyword is indented inside a block.
syntax clear sshdconfigNumber
syntax match sshconfigNumber /\<\d\+\>/
#                                   ^^
#                                   necessary to not break sshdconfigTime

# The default rules for `sshdconfigHostPort` are not entirely correct.{{{
#
# For example, they wrongly match this:
#
#     TrustedUserCAKeys /etc/ssh/user-ca-keys.pub
#                                ^--------------^
#                                       ✘
#
# There is also a fixme for one of them.
#
# Anyway, ATM,  I'm not interested in  whatever it's supposed to  match, and I
# don't want wrong highlighting – unexpectedly – in some part of a value.
#}}}
syntax clear sshdconfigHostPort
