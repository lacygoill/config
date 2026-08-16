vim9script

syntax include @vi9Script syntax/vim.vim
syntax region skeletonExpression matchgroup=PreProc start=/❴/ end=/❵/ oneline contains=@vi9Script
