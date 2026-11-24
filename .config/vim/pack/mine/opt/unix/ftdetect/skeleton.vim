vim9script

const SKELETONS_DIR: string = expand('<sfile>:h:h') .. '/skeletons'
execute $'autocmd! BufRead,BufNewFile {SKELETONS_DIR}/*.skel b:force_vim9_syntax = true | set filetype=skeleton'
