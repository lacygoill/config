vim9script

import 'lg.vim'

const OPTIONS_DOC: list<string> = readfile($VIMRUNTIME .. '/doc/options.txt')

# Interface {{{1
export def Option(arg_opt: string) #{{{2
    var opt: string
    try
        # Why not just `a-z`?  To support terminal options.
        opt = execute('set ' .. arg_opt .. '?')->matchstr('[a-z0-9<>_-]\+')
    # many errors are possible when you write nonsense (`E518`, `E846`, `E488`, ...)
    catch
        lg.Catch()
        return
    endtry
    # necessary for a reset boolean option (like 'paste')
    opt = opt->substitute('^no', '', '')

    opt->GetCurrentValue()->Display()
enddef
#}}}1
# Core {{{1
def GetCurrentValue(opt: string): list<string> #{{{2
    var vlocal: string = execute('verbose setlocal ' .. opt .. '?')
        ->matchstr('\_s*\zs\S.*')
    var vglobal: string = execute('verbose setglobal ' .. opt .. '?')
        ->matchstr('\_s*\zs\S.*')
    var type: string
    if opt[: 1] == 't_' || opt[0] .. opt[-1] == '<>'
        type = 'terminal'
    else
        type = OPTIONS_DOC
            ->join("\n")
            ->matchstr('\n''' .. opt .. '''\s\+\%(''[a-z]\{2,}''\s\+\)\=\%(boolean\|number\|string\)'
            .. '\_.\{-}\zs\%(global\ze\n\|\%(global or \)\=local to \%(buffer\|window\)\)')
    endif
    var msg: list<string>
    if type =~ '^\%(global\|terminal\)$'
        msg = [type .. ':  ' .. vglobal]
    else
        msg =<< trim eval END
            local:   {vlocal}
            global:  {vglobal}
            type:    {type}
        END
    endif
    return msg
enddef

def Display(arg_msg: list<string>) #{{{2
    var msg: string = arg_msg->join("\n\n")
    # a horizontal rule makes the output easier to read when we execute several `:Vo` consecutively
    var horizontal_rule: string = msg->substitute('.*\n', '', '')
    horizontal_rule = horizontal_rule
        ->substitute('^\t', (_) => repeat(' ', &l:tabstop), '')
    horizontal_rule = horizontal_rule
        ->substitute('.', '-', 'g')
    echo msg .. (msg =~ "\n" ? "\n" .. horizontal_rule : '')
enddef
