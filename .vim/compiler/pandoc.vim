vim9script

g:current_compiler = 'pandoc'

# TODO: I'm not sure you can set 'errorformat' correctly.{{{
#
# When  an  error  occurs, the  message  comes  from  LaTeX  which works  on  an
# intermediate  file  (≈ contents  of  the  markdown  file  written in  a  LaTeX
# document).
# As a  result, the line  error doesn't match the  one in the  original markdown
# file.
#}}}
# For the moment, we simply ignore all of the compiler's output.
CompilerSet errorformat=%-G%.%#

# Where could I add `--`?{{{
#
# Right in front of `%:p:S`.
#}}}
# Why would I do it?{{{
#
# To avoid an error in case the filename begins with a hyphen.
#}}}
# Why don't you do it then?{{{
#
# There's no need to.
# We use `:p` which makes the filepath absolute, and thus begin with a `/`.
#}}}
CompilerSet makeprg=pandoc
    \\ -N
    \\ --pdf-engine=xelatex
    \\ --variable\ mainfont=\"DejaVu\ Sans\ Mono\"
    \\ --variable\ sansfont=\"DejaVu\ Sans\ Mono\"
    \\ --variable\ monofont=\"DejaVu\ Sans\ Mono\"
    \\ --variable\ fontsize=12pt
    \\ --toc
    \\ -o\ %:p:r:S.pdf
    \\ %:p:S
