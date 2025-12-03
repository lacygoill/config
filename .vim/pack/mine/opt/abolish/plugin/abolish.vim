vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# Source:
# https://github.com/tpope/vim-abolish/blob/master/plugin/abolish.vim

import 'lg.vim'

# Utility functions {{{1

def Send(
    self: dict<func>,
    func: string,
    ...varargs: list<string>
): string

    var Func: any
    if typename(func) == 'string' || typename(func) == 'number'
        Func = get(self, func, '')
    else
        Func = func
    endif
    var s: dict<func> = typename(self) =~ '^dict' ? self : {}
    if typename(Func) =~ '^func'
        return call(Func, varargs, s)
    endif
    if typename(Func) =~ '^dict' && Func->has_key('apply')
        return call(Func.apply, varargs, Func)
    endif
    if typename(Func) =~ '^dict' && Func->has_key('call')
        return call(Func.call, varargs, s)
    endif
    if typename(Func) == 'string' && Func == '' && s->has_key('function missing')
        return call(Send, [s, 'function missing', func] + varargs)
    endif
    return Func
enddef

def DictClone(d: dict<any>): dict<any>
    return deepcopy(d)
enddef

var object: dict<func(dict<any>): dict<any>> = {
    Clone: DictClone,
}

if !exists('g:Abolish')
    g:Abolish = {}
endif
g:Abolish->extend(object, 'force')
         ->extend({Coercions: {}}, 'keep')

def Throw(msg: string)
    v:errmsg = msg
    throw 'Abolish: ' .. msg
enddef

def Words(): list<string>
    var words: list<string>
    for line in getline('w0', 'w$')
        var col: number
        while match(line, '\<\k\k\+\>', col) >= 0
            words->add(line->matchstr('\<\k\k\+\>', col))
            col = line->matchend('\<\k\k\+\>', col)
        endwhile
    endfor
    return words
enddef

def Extractopts(
    list: list<string>,
    opts: dict<any>
): dict<any>

    var i: number
    while i < len(list)
        if list[i] =~ '^-[^=]' && opts->has_key(list[i]->matchstr('-\zs[^=]*'))
            var key: string = list[i]->matchstr('-\zs[^=]*')
            var value: string = list[i]->matchstr('=\zs.*')
            if get(opts, key)->typename() =~ '^list'
                opts[key]->add(value)
            elseif get(opts, key)->typename() == 'number'
                opts[key] = 1
            else
                opts[key] = value
            endif
        else
            ++i
            continue
        endif
        remove(list, i)
    endwhile
    return opts
enddef
# }}}1
# Dictionary creation {{{1

def Mixedcase(word: string): string
    return Camelcase(word)->substitute('^.', '\u&', '')
enddef

def Camelcase(aword: string): string
    var word = aword->tr('-', '_')
    if word !~ '_' && word =~ '\l'
        return word->substitute('^.', '\l&', '')
    endif
    var Pat: func = (m: list<string>): string =>
        m[1] == '' ? m[2]->tolower() : m[2]->toupper()
    return word->substitute('\C\(_\)\=\(.\)', Pat, 'g')
enddef

def Snakecase(word: string): string
    return word
        ->substitute('::', '/', 'g')
        ->substitute('\(\u\+\)\(\u\l\)', '\1_\2', 'g')
        ->substitute('\(\l\|\d\)\(\u\)', '\1_\2', 'g')
        ->substitute('[.-]', '_', 'g')
        ->tolower()
enddef

def Uppercase(word: string): string
    return Snakecase(word)->toupper()
enddef

def Dashcase(word: string): string
    return Snakecase(word)->tr('_', '-')
enddef

def Spacecase(word: string): string
    return Snakecase(word)->tr('_', ' ')
enddef

def Dotcase(word: string): string
    return Snakecase(word)->tr('_', '.')
enddef

def Titlecase(word: string): string
    return Spacecase(word)
        ->substitute('\(\<\w\)', (m: list<string>): string => m[1] ->toupper(), 'g')
enddef

extend(g:Abolish, {
    Camelcase: Camelcase,
    Mixedcase: Mixedcase,
    Snakecase: Snakecase,
    Uppercase: Uppercase,
    Dashcase: Dashcase,
    Dotcase: Dotcase,
    Spacecase: Spacecase,
    Titlecase: Titlecase
}, 'keep')

def CreateDictionary(
    alhs: string,
    arhs: string,
    opts: dict<any>
): dict<string>

    var dictionary: dict<string>
    var i: number
    var expanded: dict<string> = ExpandBraces({[alhs]: arhs})
    for [lhs: string, rhs: string] in items(expanded)
        if get(opts, 'case', true)
            dictionary[Mixedcase(lhs)] = Mixedcase(rhs)
            dictionary[tolower(lhs)] = tolower(rhs)
            dictionary[toupper(lhs)] = toupper(rhs)
        endif
        dictionary[lhs] = rhs
    endfor
    ++i
    return dictionary
enddef

def ExpandBraces(dict: dict<string>): dict<string>
    var new_dict: dict<string>
    var redo: bool
    for [key: string, val: string] in dict->items()
        if key =~ '{.*}'
            redo = true
            var all: string
            var kbefore: string
            var kmiddle: string
            var kafter: string
            var vbefore: string
            var vmiddle: string
            var vafter: string
            [all, kbefore, kmiddle, kafter; _] = key
                ->matchlist('\(.\{-\}\){\(.\{-\}\)}\(.*\)')
            [all, vbefore, vmiddle, vafter; _] = val
                ->matchlist('\(.\{-\}\){\(.\{-\}\)}\(.*\)')
                + ['', '', '', '']
            if all == ''
                [vbefore, vmiddle, vafter] = [val, ',', '']
            endif
            var targets: list<string> = kmiddle->split(',', true)
            var replacements: list<string> = vmiddle->split(',', true)
            if replacements == ['']
                replacements = targets
            endif
            for i: number in range(0, len(targets) - 1)
                new_dict[kbefore .. targets[i] .. kafter] =
                    vbefore
                    .. replacements[i % len(replacements)]
                    .. vafter
            endfor
        else
            new_dict[key] = val
        endif
    endfor
    if redo
        return ExpandBraces(new_dict)
    endif
    return new_dict
enddef
# }}}1
# Abolish Dispatcher {{{1

def SubComplete(arglead: string, _, _): string
    if arglead =~ '^[/?]\k\+$'
        var char: string = arglead[0]
        return Words()
            ->map((_, v: string) => char .. v)
            ->join("\n")
    elseif arglead =~ '^\k\+$'
        return Words()->join("\n")
    endif
    return ''
enddef

def Complete(
    arglead: string,
    cmdline: string,
    _
): string

    # Vim bug: :Abolish -<Tab> calls this function with arglead equal to 0
    return arglead =~ '^[^/?-]' && typename(arglead) != 'number'
        ?     Words()->join("\n")
        : cmdline =~ '^\w\+\s\+\%(-\w*\)\=$'
        ?     "-search\n-substitute\n-delete\n-buffer\n-cmdline\n"
        : cmdline =~ ' -\%(search\|substitute\)\>'
        ?     '-flags='
        :     "-buffer\n-cmdline"
enddef

var commands: dict<any>
commands.abstract = object.Clone(object)

def DictAbstractDispatch(
    d: dict<any>,
    bang: bool,
    line1: number,
    line2: number,
    count: number,
    args: list<string>
): string

    var cloned: dict<any> = d.Clone(d)
    return cloned.go(cloned, bang, line1, line2, count, args)
enddef
commands.abstract.dispatch = DictAbstractDispatch

def DictAbstractGo(
    d: dict<any>,
    bang: number,
    line1: number,
    line2: number,
    count: number,
    args: list<string>
): string

    d.bang = bang
    d.line1 = line1
    d.line2 = line2
    d.count = count
    return d.process(d, bang, line1, line2, count, args)
enddef
commands.abstract.go = DictAbstractGo

def Dispatcher(
    bang: number,
    line1: number,
    line2: number,
    count: number,
    aargs: list<string>
): string

    var args = copy(aargs)
    var command: dict<any> = commands.abbrev
    for [i: number, arg: string] in args->items()
        if arg =~ '^-\w\+$' && commands->has_key(arg->matchstr('-\zs.*'))
            command = commands[arg->matchstr('-\zs.*')]
            args->remove(i)
            break
        endif
    endfor
    try
        return command.dispatch(command, bang, line1, line2, count, args)
    catch /^Abolish: /
        lg.Catch()
        return ''
    endtry
    return ''
enddef
# }}}1
# Subvert Dispatcher {{{1

def SubvertDispatcher(
    bang: number,
    line1: number,
    line2: number,
    count: number,
    args: string
): string

    try
        return ParseSubvert(bang, line1, line2, count, args)
    catch /^Subvert: /
        lg.Catch()
        return ''
    endtry
    return ''
enddef

def ParseSubvert(
    bang: number,
    line1: number,
    line2: number,
    count: number,
    aargs: string
): string

    var args: string
    if aargs =~ '^\%(\w\|$\)'
        args = (bang ? '!' : '') .. aargs
    else
        args = aargs
    endif
    var separator: string =
           '\%(\%(\\\)\@1<!'
        .. '\%(\\\\\)*\\\)\@<!'
        .. matchstr(args, '^.')
    var split: list<string> = args->split(separator, true)[1 :]

    var flags: string = split[1]
        ->matchstr('^[A-Za-z]*')
    var rest: string = split[1 :]
        ->join(separator)
        ->matchstr(' \zs.*')

    return count != 0 || split == ['']
        ?     ParseSubstitute(bang, line1, line2, count, split)

        : len(split) == 1
        ?     FindCommand(separator, '', split[0])

        : len(split) == 2 && split[1] =~ '^[A-Za-z]*n[A-Za-z]*$'
        ?     ParseSubstitute(bang, line1, line2, count, [split[0], '', split[1]])

        : len(split) == 2 && split[1] =~ '^[A-Za-z]*\%([+-]\d\+\)\=$'
        ?     FindCommand(separator, split[1], split[0])

        : len(split) >= 2 && split[1] =~ '^[A-Za-z]* '
        ?     GrepCommand(rest, bang, flags, split[0])

        : len(split) >= 2 && separator == ' '
        ?     split[1 :]->join(' ')->GrepCommand(bang, '', split[0])

        :     ParseSubstitute(bang, line1, line2, count, split)
enddef

def NormalizeOptions(aflags: any): dict<any>
    var opts: any
    var flags: any
    if typename(aflags) =~ '^dict'
        opts = aflags
        flags = get(aflags, 'flags', '')
    else
        opts = {}
        flags = aflags
    endif
    if flags =~ 'w'
        opts.boundaries = 2
    elseif flags =~ 'v'
        opts.boundaries = 1
    elseif !opts->has_key('boundaries')
        opts.boundaries = 0
    endif
    opts.case = (flags !~ 'I' ? get(opts, 'case', true) : false)
    opts.flags = flags->substitute('\C[avIiw]', '', 'g')
    return opts
enddef
# }}}1
# Searching {{{1

def Subesc(pattern: string): string
    return pattern
        ->substitute('[][\\/.*+?~%()&]', '\\&', 'g')
enddef

def Sort(a: string, b: string): number
    if a ==? b
        return a == b ? 0 : a > b ? 1 : -1
    endif
    if strlen(a) == strlen(b)
        return a >? b ? 1 : -1
    endif
    return strlen(a) < strlen(b) ? 1 : -1
enddef

def Pattern(
    dict: dict<string>,
    boundaries: number
): string

    var a: string
    var b: string
    if boundaries == 2
        a = '<'
        b = '>'
    elseif boundaries
        # TODO: Replace `@<=` with `@1<=`?
        a = '%(<|_@<=|[[:lower:]]@<=[[:upper:]]@=)'
        b = '%(>|_@=|[[:lower:]]@<=[[:upper:]]@=)'
    else
        a = ''
        b = ''
    endif
    return '\v\C' .. a .. '%(' .. dict->keys()
        ->sort(Sort)
        ->map((_, v: string) => Subesc(v))
        ->join('|')
        .. ')' .. b
enddef

def EgrepPattern(
    dict: dict<string>,
    boundaries: number
): string

    var a: string
    var b: string
    [a, b] = boundaries == 2
        ?     ['\<', '\>']
        : boundaries
        ?     ['(\<\|_)', '(\>\|_\|[[:upper:]][[:lower:]])']
        :     ['', '']

    return a .. '(' .. dict->keys()
        ->sort(Sort)
        ->map((_, v: string) => Subesc(v))
        ->join('\|')
        .. ')' .. b
enddef

def FindCommand(
    acmd: string,
    flags: any,
    word: string
): string

    var opts: dict<any> = NormalizeOptions(flags)
    var dict: dict<string> = CreateDictionary(word, '', opts)
    # This  is tricky.   If  we use  `:/pattern`,  the search  drops  us at  the
    # beginning of the line, and we can't use position flags (e.g., `/foo/e`).
    # If we use `:normal /pattern`, we leave ourselves vulnerable to
    # “press enter” prompts (even with `:silent`).
    var cmd: string = (acmd =~ '[?!]' ? '?' : '/')
    setreg('/', [Pattern(dict, opts.boundaries)], 'c')
    if opts.flags == '' || search(@/, 'n') == 0
        return 'normal! ' .. cmd .. "\<CR>"
    endif
    if opts.flags =~ ';[/?]\@!'
        Throw("E386: Expected '?' or '/' after ';'")
    else
        return "execute 'normal! " .. cmd .. cmd .. opts.flags .. "\<CR>'|call histdel('search', -1)"
    endif
    return ''
enddef

def GrepCommand(
    args: string,
    bang: number,
    flags: any,
    word: string
): string

    var opts: dict<any> = NormalizeOptions(flags)
    var dict: dict<string> = CreateDictionary(word, '', opts)
    var lhs: string
    if &grepprg == 'internal'
        lhs = "'" .. Pattern(dict, opts.boundaries) .. "'"
    elseif &grepprg =~ '^[ar]g\>'
      lhs = "'" .. EgrepPattern(dict, opts.boundaries) .. "'"
    else
        lhs = "-E '" .. EgrepPattern(dict, opts.boundaries) .. "'"
    endif
    return 'grep' .. (bang ? '!' : '') .. ' ' .. lhs .. ' ' .. args
enddef

commands.search = commands.abstract.Clone(commands.abstract)
commands.search.options = {word: 0, variable: 0, flags: ''}

def DictSearchProcess(
    d: dict<any>,
    bang: number,
    line1: number,
    line2: number,
    count: number,
    args: list<string>
): string

    Extractopts(args, d.options)
    if d.options.word
        d.options.flags ..= 'w'
    elseif d.options.variable
        d.options.flags ..= 'v'
    endif
    var opts: dict<any> = NormalizeOptions(d.options)
    if len(args) > 1
        return args[1 :]
            ->join(' ')
            ->GrepCommand(bang, opts, args[0])
    endif
    if len(args) == 1
        return FindCommand(bang ? '!' : ' ', opts, args[0])
    endif
    Throw('E471: Argument required')
    return ''
enddef
commands.search.process = DictSearchProcess
# }}}1
# Substitution {{{1

def Abolished(): string
    return get(g:abolish_last_dict, submatch(0), submatch(0))
enddef

def SubstituteCommand(
    cmd: string,
    bad: string,
    good: string,
    flags: string
): string

    var opts: dict<any> = NormalizeOptions(flags)
    var dict: dict<string> = CreateDictionary(bad, good, opts)
    var lhs: string = Pattern(dict, opts.boundaries)
    g:abolish_last_dict = dict
    return cmd .. '/' .. lhs .. '/\=Abolished()' .. '/' .. opts.flags
enddef

def ParseSubstitute(
    bang: number,
    line1: number,
    line2: number,
    count: number,
    aargs: list<string>
): string

    var separator: string
    var args: list<string>
    if get(aargs, 0, '') =~ '^[/?'']'
        separator = aargs[0]->matchstr('^.')
        args = aargs->join(' ')->split(separator, true)
        args->remove(0)
    else
        args = aargs
    endif
    if len(args) < 2
        Throw('E471: Argument required')
    elseif len(args) > 3
        Throw('E488: Trailing characters')
    endif
    var bad: string
    var good: string
    var flags: string
    [bad, good, flags] = (args + [''])[0 : 2]
    var cmd: string
    if count == 0
        cmd = 'substitute'
    else
        cmd = ':' .. line1 .. ',' .. line2 .. 'substitute'
    endif
    return SubstituteCommand(cmd, bad, good, flags)
enddef

commands.substitute = commands.abstract.Clone(commands.abstract)
commands.substitute.options = {word: 0, variable: 0, flags: 'g'}

def DictSubstituteProcess(
    d: dict<any>,
    bang: number,
    line1: number,
    line2: number,
    count: number,
    args: list<string>
): string

    Extractopts(args, d.options)
    if d.options.word
        d.options.flags ..= 'w'
    elseif d.options.variable
        d.options.flags ..= 'v'
    endif
    NormalizeOptions(d.options)
    if len(args) <= 1
        Throw('E471: Argument required')
    else
        var good = args[1 :]->join('')
        var cmd = bang ? '.' : '%'
        return SubstituteCommand(cmd, args[0], good, d.options)
    endif
    return ''
enddef
commands.substitute.process = DictSubstituteProcess
# }}}1
# Abbreviations {{{1

def Badgood(args: list<string>): list<string>
    var words: list<string> = copy(args)
        ->filter((_, v: string): bool => v !~ '^-')
    args
        ->filter((_, v: string): bool => v =~ '^-')
    if empty(words)
        Throw('E471: Argument required')
    elseif !empty(args)
        Throw('Unknown argument: ' .. args[0])
    endif
    var bad: string
    [bad; words] = words
    return [bad, words->join(' ')]
enddef

def AbbreviateFromDict(cmd: string, dict: dict<string>)
    for [lhs: string, rhs: string] in dict->items()
        execute cmd .. ' ' .. lhs .. ' ' .. rhs
    endfor
enddef

commands.abbrev = commands.abstract.Clone(commands.abstract)
commands.abbrev.options = {buffer: 0, cmdline: 0, delete: 0}
def DictAbbrevProcess(
    d: dict<any>,
    bang: number,
    line1: number,
    line2: number,
    count: number,
    args: list<string>
): string

    var cargs: list<string> = copy(args)
    Extractopts(args, d.options)
    var cmd: string
    var good: string
    if d.options.delete
        cmd = 'unabbrev'
        good = ''
    else
        cmd = 'noreabbrev'
    endif
    if !d.options.cmdline
        cmd = 'i' .. cmd
    endif
    if d.options.delete
        cmd = ' silent! ' .. cmd
    endif
    if d.options.buffer
        cmd ..= ' <buffer>'
    endif
    var bad: string
    [bad, good] = Badgood(args)
    if bad->substitute('[{},]', '', 'g') !~ '^\k*$'
        Throw('E474: Invalid argument (not a keyword: ' .. string(bad) .. ')')
    endif
    if !d.options.delete && good == ''
        Throw('E471: Argument required' .. args[0])
    endif
    var dict: dict<string> = CreateDictionary(bad, good, d.options)
    AbbreviateFromDict(cmd, dict)
    return ''
enddef
commands.abbrev.process = DictAbbrevProcess

commands.delete = commands.abbrev.Clone(commands.abbrev)
commands.delete.options.delete = 1
# }}}1

# Interface {{{1
# Mapping {{{2

def UnknownCoercion(letter: string, word: string): string
    return word
enddef

extend(g:Abolish.Coercions, {
    'c': g:Abolish.Camelcase,
    'm': g:Abolish.Mixedcase,
    's': g:Abolish.Snakecase,
    'u': g:Abolish.Uppercase,
    'k': g:Abolish.Dashcase,
    '.': g:Abolish.Dotcase,
    ' ': g:Abolish.Spacecase,
    't': g:Abolish.Titlecase,
    'function missing': UnknownCoercion
}, 'keep')

def Coerce(transformation = '', type = ''): string
    if type == ''
        &operatorfunc = function(Coerce, [getcharstr()])
        return 'g@l'
    endif

    var clipboard_save: string = &clipboard
    try
        &clipboard = ''
        var reg_save: dict<any> = getreginfo('"')
        var c = v:count1
        var begin: list<number> = getcurpos()
        while c > 0
            --c
            normal! yiw
            var word: string = @"
            @" = Send(g:Abolish.Coercions, transformation, word)
            if word != @"
                normal! viwpw
            else
                normal! w
            endif
        endwhile
        setreg('"', reg_save)
        setpos("'[", begin)
        setpos('.', begin)
    finally
        &clipboard = clipboard_save
    endtry
    return ''
enddef

nnoremap <expr><unique> cr Coerce()

# TODO: add a visual mode mapping to be able to change `foo bar baz` into `foo_bar_baz`.
# https://github.com/tpope/vim-abolish/issues/74

# Commands {{{2

command -nargs=+ -bang -bar -range=0 -complete=custom,Complete Abolish {
    execute Dispatcher(<bang>0, <line1>, <line2>, <count>, [<f-args>])
}

command -nargs=1 -bang -bar -range=0 -complete=custom,SubComplete S {
    execute SubvertDispatcher(<bang>0, <line1>, <line2>, <count>, <q-args>)
}

command -nargs=1 -bang -bar -range=0 -complete=custom,SubComplete Subvert {
    execute SubvertDispatcher(<bang>0, <line1>, <line2>, <count>, <q-args>)
}
