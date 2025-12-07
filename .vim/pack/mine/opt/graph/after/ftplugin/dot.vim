vim9script

# Commands {{{1

command -bar -buffer -range=% -nargs=+ -complete=custom,graph#cmd_complete Graph {
    graph#cmd(<q-args>, <line1>, <line2>)
}

# Mappings {{{1

nnoremap <buffer><nowait> <Bar>c <ScriptCmd>Graph -compile<CR>
xnoremap <buffer><nowait> <Bar>c <C-\><C-N><ScriptCmd>:* Graph -compile<CR>

nnoremap <buffer><nowait> <Bar>i <ScriptCmd>Graph -interactive<CR>

nnoremap <buffer><nowait> <Bar>s <ScriptCmd>Graph -show<CR>
xnoremap <buffer><nowait> <Bar>s <C-\><C-N><ScriptCmd>:* Graph -show<CR>

# Options {{{1

b:mc_chain =<< trim END
    omni
    ulti
    keyn
END

&l:commentstring = '// %s'

&l:omnifunc = graph#omni_complete

compiler dot

# Teardown {{{1

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| call graph#undo_ftplugin()'
