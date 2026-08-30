vim9script

g:current_compiler = 'awk'

CompilerSet errorformat=gawk:\ %f:%l:\ %m,gawk:\ %f:%l:\ (FILENAME=%.%#\ FNR=%[0-9]%#)\ %m

# To reduce noise.{{{
#
#     warning: reference to uninitialized variable `...'
#     warning: reference to uninitialized field `...'
#}}}
#                               v----v
CompilerSet makeprg=gawk\ --lint=fatal\ --traditional\ -f\ %:p:S\ %:h:S/*.input\ >/dev/null
#                                                                 ^-----------^
#
# This assumes the existence  of an `.input` file in the  directory of the awk
# script.  Its contents should be representative  of what the script will have
# to deal with in  practice.  You could also run awk with  an empty input, but
# then you might get many meaningless warnings.
