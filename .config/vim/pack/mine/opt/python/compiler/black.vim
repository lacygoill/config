vim9script

g:current_compiler = 'black'

CompilerSet errorformat=%-G%.%#
CompilerSet makeprg=black\ --skip-string-normalization\ %:p:S
#                          ^-------------------------^
#
# `--skip-string-normalization`: Don't normalize string quotes or prefixes.
# Useful to preserve  single quotes around dictionary keys (by  default they are
# turned into double quotes).
