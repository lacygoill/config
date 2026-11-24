vim9script

import 'lg.vim'
import 'lg/window.vim'

# Interface {{{1
export def Main(all_values: bool, type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(Main, [all_values])
        return 'g@l'
    endif

    var pat: string =
        # this part is optional because, in Vim9 script, there might be no assignment command
           '\%(\%(let\|var\|const\=\)\s\+\)\='
        #                                to capture a dict member: foo.bar = 123
        #                                v
        .. '\([bwtglsav]:\)\=\(\h\%(\w\|\.\)*\)\s*[+-.*]\{,2}[=:].*'
        #                                                      ^
        #                                                      for Vim9 variables which are only declared, not assigned
    var line: string = getline('.')
    if line->match(pat) == -1
        echo 'No variable to capture on this line'
        return ''
    endif

    copy .

    if all_values
        Rep = (m) => 'g:d_' .. m[2]->tr('.', '_')
            .. ' = get(g:, ''d_' .. m[2]->tr('.', '_') .. ''', []) '
            .. '+ [deepcopy(' .. m[1] .. m[2] .. ')]'
    else
        Rep = (m) => 'g:d_' .. m[2]->tr('.', '_')
            .. ' = deepcopy(' .. m[1] .. m[2] .. ')'
    endif

    var new_line: string = line
        ->substitute(pat, Rep, 'e')
    setline('.', new_line)

    return ''
enddef

var Rep: func

export def Dump() #{{{2
    var vars: list<string> = getcompletion('d_*', 'var')
    if empty(vars)
        echo 'there are no debugging variables'
        return
    endif
    vars->map((_, v: string) =>
                v .. ' = ' .. eval('g:' .. v)->string())
    try
        window.Scratch(vars)
    catch /^Vim\%((\a\+)\)\=:E994:/
        lg.Catch()
        return
    endtry
    wincmd P
    if !&l:previewwindow
        return
    endif
    nnoremap <buffer><nowait> DD <ScriptCmd>UnletVariableUnderCursor()<CR>
enddef
# }}}1
# Utilities {{{1
def UnletVariableUnderCursor() #{{{2
    execute 'unlet! g:' .. getline('.')->matchstr('^d_\S\+')
    keepjumps delete _
    silent update
    echomsg 'the variable has been removed'
enddef
