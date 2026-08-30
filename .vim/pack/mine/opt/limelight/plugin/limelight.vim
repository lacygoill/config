vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/limelight.vim'

command -nargs=? -bar -bang -range Limelight limelight.Execute(<bang>0, <count> > 0, <line1>, <line2>, <f-args>)

nnoremap <expr><unique> ++ limelight.Operator()
nnoremap <expr><unique> +++ limelight.Operator() .. '_'
xnoremap <unique> ++ <C-\><C-N><ScriptCmd>:* Limelight<CR>

# stop
nnoremap <unique> +- <ScriptCmd>Limelight!<CR>
