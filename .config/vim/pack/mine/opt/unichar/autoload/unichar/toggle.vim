vim9script

export def Main(lnum1: number, lnum2: number)
    cursor(lnum1, 1)
    var pat: string
    var Rep: func
    if search('\\u\x\+', 'nW', lnum2) > 0
        [pat, Rep] = [
            '\\u\x\+',
            (m: list<string>): string => eval('"' .. m[0] .. '"')
        ]
    else
        [pat, Rep] = [
            '[^\x00-\xff]',
            (m: list<string>): string =>
            char2nr(m[0])
            ->printf(char2nr(m[0]) <= 65'535
            ? '\u%x'
            : '\U%x')
        ]
    endif
    getline(lnum1, lnum2)
        ->map((_, v: string) => v->substitute(pat, Rep, 'g'))
        ->setline(lnum1)
enddef
