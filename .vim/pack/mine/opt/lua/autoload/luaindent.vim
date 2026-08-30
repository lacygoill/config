vim9script

# Init {{{1

const BLOCK_START: string = '^\C\s*\%(if\|for\|while\|repeat\|else\|elseif\|do\|then\)\>'
    .. '\|{\s*$'
    .. '\|\<function\>\s*\%(\k\|[.:]\)\{-}\s*('

const BLOCK_END: string = '^\C\s*\%(end\|else\|elseif\|until\)\>'
    .. '\|^\s*}'

# Interface {{{1
export def Expr(): number # {{{2
    var prevlnum: number = prevnonblank(v:lnum - 1)

    if prevlnum == 0
        return 0
    endif

    # In a multiline string, the indentation is semantic, not cosmetic.
    # Leave it alone.
    if InMultiLineString()
        return -1
    endif

    var ind: number = indent(prevlnum)
    var prevline: dict<any> = {text: getline(prevlnum), lnum: prevlnum}
    var line: dict<any> = {text: getline(v:lnum), lnum: v:lnum}

    if prevline->StartsBlock()
            && !prevline.text->AlsoClosesBlock()
        ind += shiftwidth()
    endif

    if line->EndsBlock()
        ind -= shiftwidth()
    endif

    return ind
enddef
# }}}1
# Util {{{1
def InMultiLineString(): bool # {{{2
    return synstack(v:lnum, 1)
        ->indexof((_, id: number) => id->synIDattr('name') =~ '\cstring') >= 0
enddef

def StartsBlock(line: dict<any>): bool # {{{2
    return line->NonCommentedMatch(BLOCK_START)
enddef

def EndsBlock(line: dict<any>): bool # {{{2
    return line->NonCommentedMatch(BLOCK_END)
enddef

def AlsoClosesBlock(line: string): bool # {{{2
    # `else` and `elseif` don't close the main block `if` block.
    # But `end` and `until` do close a block.
    return line =~ '\<\%(end\|until\)\>'
enddef

def NonCommentedMatch(line: dict<any>, pat: string): bool # {{{2
    var col: number = line.text->match(pat)
    return col != -1 && !InCommentOrString(line.lnum, col + 1)
enddef

def InCommentOrString(lnum: number, col: number): bool # {{{2
    return synstack(lnum, col)
        ->indexof((_, id: number) => id->synIDattr('name') =~ '\ccomment\|string') >= 0
enddef
