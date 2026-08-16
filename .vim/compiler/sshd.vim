vim9script

g:current_compiler = 'sshd'

#    > Test mode.  Only check the validity  of the configuration file and sanity of
#    > the  keys.  This  is  useful  for updating  sshd  reliably as  configuration
#    > options may change.
#
# Source: `man 8 sshd /DESCRIPTION/;/-t`
CompilerSet makeprg=sshd\ -t

CompilerSet errorformat=%f:\ line\ %l:%m,%-G%.%#
