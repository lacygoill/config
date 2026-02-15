vim9script

import autoload 'fz/links.vim'

# `:123 lvimgrepadd!`
const VIMGREP: string = '^[:[:blank:]]*\d*\s*l\=vim\%[grepadd]!\=\s\+'
    # opening delimiter
    .. '\([^[:ident:][:blank:]]\)'
    # the pattern;  stopping at the  cursor because  it doesn't make  sense to
    # consider what comes after the cursor during a completion
    .. '\zs.\{-}\%COLc\ze.\{-}'
    # no odd number of backslashes before the closing delimiter
    .. '\%([^\\]\\\%(\\\\\)*\)\@<!'
    # closing delimiter
    .. '\1'
    # flags
    .. '[gj]\{,2}\s'

# `:%s/pat/rep/g`
const SUBSTITUTE: string = 's\([^[:ident:][:blank:]]\)\zs.\{-}\%COLc\ze.\{-}\1.\{-}\1'
    # `:helpgrep :s_flags`
    .. '[cegn]\{,4}\%($\|\s\||\)'

# `:helpgrep pat`
const HELPGREP: string = '\<\%(helpg\%[rep]\|lh\%[elpgrep]\)\s\+\zs.*'

export def Main(): string
    if getcmdtype() != ':'
        return "\<C-L>"
    endif

    # for `:verbose` commands whose output is in the pager
    if getcmdline()->empty()
        # The timer avoids "E565: Not allowed to change text or change window".{{{
        #
        # It's caused by:
        #
        #     # ~/.vim/pack/mine/opt/save/plugin/save.vim
        #             v------v            v------v
        #     autocmd BufLeave,CursorHold,WinLeave,FocusLost * ++nested SaveBuffer()
        #     ...
        #     def SaveBuffer()
        #         ...
        #         silent lockmarks update
        #         ...
        #
        # The fzf  popup triggers  `{Buf,Win}Leave` which  executes `:update`;
        # the latter is  disallowed when the text is locked  (and it is locked
        # when an `<expr>` mapping is used).
        #}}}
        timer_start(0, (_) => [links.Fz(), feedkeys("\<C-\>\<C-N>", 'int')])
        return ''
    endif

    var col: number = getcmdpos()

    var list: list<string>
    for pat: string in [VIMGREP, SUBSTITUTE, HELPGREP]
            ->map((_, pat: string) => '\C' .. pat->substitute('COL', col, 'g'))
        list = getcmdline()
            ->matchlist(pat)
        if list != []
            break
        endif
    endfor

    if list == []
        return "\<C-L>"
    endif

    var pat: string = list[0]
    var delim: string = list[1]
    # Warning: this search is sensitive to the values of `'ignorecase'` and `'smartcase'`
    var pos: list<number> = searchpos(pat, 'n')
    var lnum: number = pos[0]
    col = pos[1]
    if [lnum, col] == [0, 0]
        return ''
    endif
    var match: string = getline(lnum)
        ->strpart(col - 1)
    var suffix: string = match
        ->substitute(pat, '', '')
    if suffix == ''
        return ''
    endif
    # escape the same characters as the default `C-l` in an `:s` command
    if suffix[0] =~ '[$*.[\\' .. delim .. '^~]'
        return '\' .. suffix[0]
    endif
    return suffix[0]
enddef
# Why don't you support `:vimgrep pat` (without delimiters)?{{{
#
# It  would be  tricky because  in that case,  Vim updates  the position  of the
# cursor after every inserted character.
#
# MRE:
#
#     $ tee /tmp/vim.vim <<'EOF'
#         vim9script
#         set incsearch
#         cnoremap <expr> <C-L> C_l()
#         def C_l(): string
#             echomsg getpos('.')
#             return ''
#         enddef
#     EOF
#
#     $ vim -Nu NONE -S /tmp/vim.vim /tmp/vim.vim
#     :vimgrep /c/
#     # press C-l while the cursor is right before `c`
#     [0, 1, 1, 0]˜
#     # the cursor didn't move
#     :vimgrep c C-l
#     [0, 1, 11, 0]˜
#     # the cursor *did* move
