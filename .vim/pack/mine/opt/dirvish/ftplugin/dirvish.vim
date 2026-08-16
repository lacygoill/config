vim9script noclear
# `noclear` is necessary for some mappings to keep working.{{{
#
# dirvish might source this script manually, causing it to be sourced twice.  If
# that happens, without `noclear`, any mapping whose RHS contains a reference to
# the `dirvish` variable would no longer work.
#
# That can happen if `:Dirvish` is passed an explicit path:
#
#     $ vim ~
#     # press: l
#     E121: Undefined variable: dirvish
#}}}

if exists('b:did_ftplugin')
  finish
endif
b:did_ftplugin = true

import autoload '../autoload/dirvish.vim'

nmap <buffer><nowait> x <Plug>(dirvish_arg)
xmap <buffer><nowait> x <Plug>(dirvish_arg)
nmap <buffer><nowait> K <Plug>(dirvish_K)
xmap <buffer><nowait> K <Plug>(dirvish_K)

nnoremap <buffer> <Plug>(dirvish_up) <ScriptCmd>execute 'Dirvish %:h' .. repeat(':h', v:count1)<CR>
nnoremap <buffer> <Plug>(dirvish_split_up) <ScriptCmd>execute 'split +Dirvish\ %:h' .. repeat(':h', v:count1)<CR>
nnoremap <buffer> <Plug>(dirvish_vsplit_up) <ScriptCmd>execute 'vsplit +Dirvish\ %:h' .. repeat(':h', v:count1)<CR>

nnoremap <buffer><nowait> ~    <ScriptCmd>Dirvish ~<CR>
nnoremap <buffer><nowait> i    <ScriptCmd>dirvish.Open('edit', false)<CR>
nnoremap <buffer><nowait> <CR> <ScriptCmd>dirvish.Open('edit', false)<CR>
nnoremap <buffer><nowait> a    <ScriptCmd>dirvish.Open('vsplit', true)<CR>
nnoremap <buffer><nowait> o    <ScriptCmd>dirvish.Open('split', true)<CR>
nnoremap <buffer><nowait> p    <ScriptCmd>dirvish.Open('p', true)<CR>
nnoremap <buffer><nowait> <2-LeftMouse> <ScriptCmd>dirvish.Open('edit', false)<CR>
nnoremap <buffer><nowait> dax  <ScriptCmd>arglocal<Bar>silent! argdelete *<Bar>echo 'arglist: cleared'<Bar>Dirvish %<CR>
nnoremap <buffer><nowait> <C-N> <C-\><C-n>j<ScriptCmd>feedkeys('p')<CR>
nnoremap <buffer><nowait> <C-P> <C-\><C-n>k<ScriptCmd>feedkeys('p')<CR>

xnoremap <buffer><nowait> I    <ScriptCmd>dirvish.Open('edit', false)<CR>
xnoremap <buffer><nowait> <CR> <ScriptCmd>dirvish.Open('edit', false)<CR>
xnoremap <buffer><nowait> A    <ScriptCmd>dirvish.Open('vsplit', true)<CR>
xnoremap <buffer><nowait> O    <ScriptCmd>dirvish.Open('split', true)<CR>
xnoremap <buffer><nowait> P    <ScriptCmd>dirvish.Open('p', true)<CR>

nnoremap <buffer><silent> R :<C-U><C-R>=v:count != 0 ? ':let g:dirvish_mode=' .. v:count .. '<Bar>' : ''<CR>Dirvish %<CR>
nnoremap <buffer> g? <ScriptCmd>help dirvish-mappings<CR>

nnoremap <buffer><nowait> . :<C-U><C-R>=v:count != 0 ? 'Shdo' .. (v:count != 0 ? '!' : '') .. ' {}' : ('! ' .. getline('.')->fnamemodify(':.')->shellescape(v:true))<CR><Home><C-Right>
xnoremap <buffer><nowait> . :Shdo <C-R>=v:count != 0 ? '!' : ' '<CR> {}<Left><Left><Left>
nnoremap <buffer><nowait> cd :<C-U><C-R>=(v:count != 0 ? 'cd' : 'lcd')<CR> % <Bar> pwd<CR>

# Buffer-local / and ? mappings to skip the concealed path fragment.
nnoremap <buffer> / /\ze[^/]*[/]\=$<Home>
nnoremap <buffer> ? ?\ze[^/]*[/]\=$<Home>

# Force autoload if `ft=dirvish`
if !exists('dirvish.ForceAutoload')
    try
        dirvish.ForceAutoload()
    catch
    endtry
endif
