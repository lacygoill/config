vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

var escapes: dict<string> = {
    "\b": '\b',
    "\e": '\e',
    "\f": '\f',
    "\n": '\n',
    "\r": '\r',
    "\t": '\t',
    "\"": '\"',
    "\\": '\\',
}

var more: bool
var input: string

#     *scriptease-:PP*
#     :PP {expr}              Pretty print the value of {expr}.
#
#     :PP! {expr}             Pretty print the value of {expr} without wrapping.
#
#     :{range}PP[!] {expr}    Pretty print the value of {expr} into the buffer after
#     {range}.
# TODO: It seems our version of this command doesn't support this anymore.
# It would be useful though.
# How about this as an alternative:
#     :new | eval execute('PP 1 + 2')->split('\n')->append('.')
#
#     :PP                     With no {expr}, input, evaluate, and pretty print a
#     series of expressions.  Quit on a blank line.  This is
#     essentially a REPL.
#
#     *scriptease-:PPmsg*
#     :PPmsg {expr}           Pretty print the value of {expr} using |:echomsg|.
#
#     :PPmsg! {expr}          Pretty print the value of {expr} using |:echomsg|
#     without wrapping.
#
#     :{count}PPmsg[!] {expr} Pretty print the value of {expr} using |:echomsg| if
#     and only if the value of 'verbose' is greater than or
#     equal to {count}.
#
#     :PPmsg                  With no {expr}, |:echomsg| the current |<sfile>| and
#     |<slnum>|.


# Interface {{{1
export def PPI(qargs: string, lnum: number) #{{{2
    if !empty(qargs)
        v:errmsg = ''
        try
            if !exists(qargs) && exists($'g:{qargs}')
                Eval($'g:{qargs}')->PP(lnum)
            else
                Eval(qargs)->PP(lnum)
            endif
        catch
            Error(v:exception)
        endtry
        return
    endif

    more = &more
    try
        &more = false
        while true
            input = input('PP> ', '', 'expression')
            if empty(input)
                break
            endif
            echon "\n"
            v:errmsg = ''
            try
                Eval(input)->PP(-1)
            catch
                Error(v:exception)
            endtry
        endwhile
    finally
        &more = more
    endtry
enddef

export def PPmsg(qargs: string, count: number) #{{{2
    if !empty(qargs)
        v:errmsg = ''
        PPMsg(empty(qargs) ? expand('<script>') : Eval(qargs), count)
    elseif &verbose >= count && !expand('<script>')->empty()
        echomsg $'{expand('<script>')}, line {expand('<slnum>')}'
    endif
enddef
#}}}1
# Core {{{1
def PP(expr: any, lnum: number) #{{{2
    if v:errmsg != ''
        return
    endif
    if lnum == -1
        echo Dump(expr, {width: &columns - 1})
    else
        cursor(lnum, 1)
        var indent: number = prevnonblank('.')->indent()
        var out: string = IndentDump(expr, indent)
        ($'{repeat(' ', indent)}PP {out}')
            ->split('\n')
            ->append('.')
        cursor(line("'["), 1)
    endif
enddef

def PPMsg(expr: any, count: number) #{{{2
    if v:errmsg != ''
        return
    endif
    if &verbose >= count
        var lines: list<string> = expr
            ->Dump({width: &columns - 1})
            ->split('\n')
        for line: string in lines
            echomsg line
        endfor
    endif
enddef

def Dump(expr: any, d = {}): string #{{{2
    var opt: dict<any> = {
        width: 0,
        level: 0,
        indent: 1,
        tail: 0,
        seen: []
    }->extend(d)

    opt.seen = opt.seen->copy()
    var childopt: dict<any> = opt->copy()
    ++childopt.tail
    ++childopt.level
    for i: number in opt.seen->len()->range()
        if expr is opt.seen[i]
            return type(expr) == v:t_list ? '[...]' : '{...}'
        endif
    endfor

    var dump: string
    if type(expr) == v:t_string
        if expr =~ '[^[:print:]]' .. '\|' .. "'"
            dump = '"'
                .. Gsub(
                    expr,
                    "[\001-\037\177\"\\\\]",
                    () => get(escapes, submatch(0), submatch(0)->char2nr()->printf('\%03o'))
                )
                .. '"'
        else
            dump = string(expr)
        endif

    elseif type(expr) == v:t_list
        childopt.seen = childopt.seen + [expr]
        dump = '[' .. copy(expr)
            ->mapnew((_, v: any): string => Dump(v, {
                seen: childopt.seen,
                level: childopt.level
            }))
            ->join(', ') .. ']'
        if opt.width != 0 && opt.level + Gsub(dump, '.', '.')->len() > opt.width
            var space: string = repeat(' ', opt.level)
            dump = '[' .. copy(expr)
                ->mapnew((_, v: any): string => Dump(v, childopt))
                ->join($",\n {space}") .. ']'
        endif

    elseif type(expr) == v:t_dict
        childopt.seen = childopt.seen + [expr]
        var keys = keys(expr)
        # TODO: How could `keys` be anything else than a list?
        # Could we specify an explicit type for `keys`?
        if type(keys) != v:t_list
            return 'test_null_dict()'
        endif
        sort(keys)
        dump = '{' .. copy(keys)
            ->map((_, v: string): string => Dump(v)
                .. ': ' .. Dump(expr[v], {
                seen: childopt.seen,
                level: childopt.level
            }))->join(', ') .. '}'
        if opt.width != 0 && opt.level + Gsub(dump, '.', '.')->len() > opt.width
            var space: string = repeat(' ', opt.level)
            var lines: list<string> = []
            var last: string = get(keys, -1, '')
            for k in keys
                var prefix: string = Dump(k) .. ':'
                var suffix: string = Dump(expr[k]) .. ','
                if $'{space}{prefix} {suffix}'->len()
                    >= opt.width - (k == last ? opt.tail : 0)
                    extend(lines, [prefix, Dump(expr[k], childopt) .. ','])
                else
                    extend(lines, [$'{prefix} {suffix}'])
                endif
            endfor
            dump = Sub('{' .. lines->join($"\n {space}"), ',$', '}')
        endif

    elseif type(expr) == v:t_func
        dump = string(expr)
            ->Sub('^function\(''(\d+)''', 'function(''{\1}''')
            ->Sub(',.*\)$', ')')

    else
        dump = string(expr)
    endif

    return dump
enddef

function Eval(qargs) #{{{2
    " we prefer to evaluate in legacy context so that to avoid an annoying error such as:
    "
    "     E1004: White space required before and after '+' at "+1"
    "
    " ... when we try to evaluate `1+1`.
    return eval(a:qargs)
endfunction
#}}}1
# Utilities {{{1
def Sub(str: string, pat: string, rep: string): string #{{{2
    return substitute(str, $'\v\C{pat}', rep, '')
enddef

def Gsub(str: string, pat: string, rep: any): string #{{{2
    return substitute(str, $'\v\C{pat}', rep, 'g')
enddef

def IndentDump(expr: any, indent: number): string #{{{2
    var out: string = Dump(expr, {
        level: 0,
        width: &textwidth - &shiftwidth * 3 - indent,
    })
    return Gsub(out, '\n', "\n" .. repeat(' ', indent + &shiftwidth * 3))
enddef

def Error(msg: string) #{{{2
    echohl ErrorMsg
    echomsg msg
    echohl NONE
enddef
