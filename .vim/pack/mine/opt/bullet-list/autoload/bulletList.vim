vim9script

import 'lg.vim'

# Interface {{{1
export def Ordered(type = ''): string #{{{2
    if type == ''
        &operatorfunc = Ordered
        return 'g@'
    endif
    var lnum1: number = line("'[")
    var lnum2: number = line("']")

    # pattern describing 0 or 1 comment string + sequence of whitespace
    var cmt: string
    # pattern describing 1 comment string + sequence of whitespace
    var cmtt: string
    [cmt, cmtt] = GetCommentPatterns()

    var pat: string
    var rep: string
    # If the lines are already prefixed by unordered list markers,
    # we want to change them with digits.
    if getline(lnum1) =~ '^\s*' .. cmt .. '[-*+]'

        # Why the `\s*` at the end of the pattern?
        # Because otherwise, when we switch from a bullet list to a digit
        # list, a space is added between the marker and the text.

        pat = '^\s*' .. cmt .. '\zs[-*+]\s*'
        rep = '\=counter .. ". "'

        # If the lines are already prefixed with digits, we want to remove them.
        # This allows to toggle a numbered list.
    elseif getline(lnum1) =~ '^\s*' .. cmt .. '\d\+\s*\.'

        pat = '^\s*' .. cmt .. '\zs\d\+\s*\.\s*'
        rep = ''

        # Otherwise, the lines are unprefixed, so we want to prefix them with digits.
    else
        #                                                 ┌ ignore an empty commented line
        #                                                 ├────────────────────────┐
        pat = '^\s*' .. cmt .. '\zs\ze' .. (!empty(cmt) ? '\%(' .. cmtt .. '\)\@!\S' : '')
        rep = '\=counter .. ". "'
    endif

    var update_index: string = 'counter = line(".") == line("'']") + 1 ? counter + 1 : 1'
    var cmd: string = 'silent keepjumps keeppatterns'
        .. ' :%s,%s global/%s/' .. update_index
        .. ' | keepjumps keeppatterns substitute/%s/%s/e'

    counter = 0
    try
        execute printf(cmd, lnum1, lnum2, pat, pat, rep)
    catch
        lg.Catch()
    endtry
    return ''
enddef

var counter: number

export def Unordered(type = ''): string #{{{2
    if type == ''
        &operatorfunc = Unordered
        return 'g@'
    endif
    var lnum1: number = line("'[")
    var lnum2: number = line("']")

    var cmt: string
    var cmtt: string
    [cmt, cmtt] = GetCommentPatterns()

    var pat: string
    var rep: string
    # if the lines are prefixed with digits, we want to replace them with markers
    if getline(lnum1) =~ '^\s*' .. cmt .. '\d\+\.'
        pat = '^\s*' .. cmt .. '\zs\%(\d\+\.\s\+\)'
        rep = '- '

        # if the lines are already prefixed with markers, remove them
    elseif getline(lnum1) =~ '^\s*' .. cmt .. '[-*+]'
        pat = '^\s*' .. cmt .. '\zs[-*+]\s*'
        rep = ''

        # otherwise, the lines are unprefixed, so we want to prefix them with markers
    else
        #                                                 ┌ ignore an empty commented line
        #                                                 ├────────────────────────┐
        pat = '^\s*' .. cmt .. '\zs\ze' .. (!empty(cmt) ? '\%(' .. cmtt .. '\)\@!\S' : '')
        rep = '- '
    endif

    var cmd: string = 'silent keepjumps keeppatterns :%s,%s substitute/%s/%s/e'

    try
        execute printf(cmd, lnum1, lnum2, pat, rep)
    catch
        lg.Catch()
    endtry
    return ''
enddef
#}}}1
# Core {{{1
def GetCommentPatterns(): list<string> #{{{2
    var cml: string = &commentstring->matchstr('\S*\ze\s*%s')
    if empty(cml)
        return ['', '']
    endif

    # pattern describing 0 or 1 comment string followed by whitespace
    # pattern describing      1 comment string "
    return [
        '\V' .. '\%(' .. escape(cml, '\') .. '\)\=' .. '\m' .. '\s*',
        '\V' .. escape(cml, '\') .. '\m' .. '\s*'
    ]
enddef
