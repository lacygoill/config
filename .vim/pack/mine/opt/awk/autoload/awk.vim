vim9script

var builtin_func: list<string> =<< trim END
    atan2
    cos
    exp
    gsub
    index
    int
    length
    log
    match
    mktime
    rand
    sin
    split
    sprintf
    sqrt
    srand
    strftime
    sub
    substr
    systime
    tolower
    toupper
END

var builtin_var: list<string> =<< trim END
    ARGC
    ARGV
    CONVFMT
    ENVIRON
    FILENAME
    FNR
    FS
    NF
    NR
    OFMT
    OFS
    ORS
    RLENGTH
    RS
    RSTART
    SUBSEP
END

const COMPLETIONS: list<dict<string>> = builtin_func
    ->copy()
    ->map((_, fn: string): dict<string> => ({word: fn .. '(', menu: '[function]'}))
    + builtin_var
    ->copy()
    ->map((_, var: string): dict<string> => ({word: var, menu: '[variable]'}))

export def Complete(findstart: bool, base: string): any #{{{1
    if findstart
        return searchpos('\<\w', 'bcnW')[1] - 1
    endif

    return COMPLETIONS
        ->copy()
        ->filter((_, v: dict<string>): bool => v.word->stridx(base) == 0)
enddef
