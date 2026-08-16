vim9script

if exists('loaded') || stridx(&runtimepath, '/helptoc,') == -1
    finish
endif
var loaded = true

g:helptoc = {shell_prompt: '^٪'}
nnoremap <unique> <Space>o <ScriptCmd>HelpToc<CR>
