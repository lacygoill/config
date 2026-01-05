vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/tradewinds.vim'

# Alternative: https://github.com/vim/vim/pull/3220#issuecomment-538651011

command -bar -nargs=1 TradewindsMove tradewinds.SoftMove(<q-args>)

nmap <unique> <C-W>gh <Plug>(tradewinds-h)
nmap <unique> <C-W>gj <Plug>(tradewinds-j)
nmap <unique> <C-W>gk <Plug>(tradewinds-k)
nmap <unique> <C-W>gl <Plug>(tradewinds-l)

nnoremap <Plug>(tradewinds-h) <ScriptCmd>TradewindsMove h<CR>
nnoremap <Plug>(tradewinds-j) <ScriptCmd>TradewindsMove j<CR>
nnoremap <Plug>(tradewinds-k) <ScriptCmd>TradewindsMove k<CR>
nnoremap <Plug>(tradewinds-l) <ScriptCmd>TradewindsMove l<CR>
