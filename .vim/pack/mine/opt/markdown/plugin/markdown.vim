vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/markdown/getDefinition.vim'

augroup MyMarkdown
    autocmd!
    autocmd BufReadPost ~/Wiki/*/code/**/* {
        nnoremap <buffer><nowait> gd <ScriptCmd>getDefinition.Main()<CR>
        xnoremap <buffer><nowait> gd <ScriptCmd>getDefinition.Main()<CR><C-\><C-N>
    }
augroup END
