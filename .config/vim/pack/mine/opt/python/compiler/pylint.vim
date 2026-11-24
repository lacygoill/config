vim9script

g:current_compiler = 'pylint'

CompilerSet errorformat=%f:%l:%m,%-G,%-G-%#,%-G*%#\ Module\ %.%#,%-GYour\ code\ has\ been\ rated\ at\ %.%#
CompilerSet makeprg=pylint\ --output-format=parseable\ %:p:S
