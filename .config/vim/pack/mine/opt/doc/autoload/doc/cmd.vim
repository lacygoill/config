vim9script

# Init {{{1

# Could we get it programmatically?{{{
#
# You could use `findfile()`:
#
#     :echo findfile('ctlseqs.txt.gz', '/usr/share/**')
#                                                  ^^
#                                                  could append a small number to limit the recursiveness
#                                                  and make the command faster
# Or `find(1)`:
#
#     :echo system('find /usr -path "*/xterm/*ctlseqs.txt.gz"')->trim("\n", 2)
#
# But those commands take some time.
# Not sure it's worth it for the moment.
#}}}
const PATH_TO_CTLSEQS: string = '/usr/share/doc/xterm/ctlseqs.txt.gz'

# Interface {{{1
export def ExplainShell(shell_cmd: string) #{{{2
    if !executable('explain-shell')
        echo 'could not find explain-shell program'
        return
    endif

    var cmd: string
    if shell_cmd == ''
        cmd = getline('.')
    else
        cmd = shell_cmd
    endif
    # The bang suppresses an error in case we've visually a command with an unterminated string:{{{
    #
    #     awk '{ print $1 }'
    #     ^--------^
    #     selection; the closing quote is missing
    #}}}
    silent! systemlist('explain-shell ' .. cmd .. ' 2>/dev/null')->setreg('o', 'c')
    echo @o
enddef

export def CtlSeqs() #{{{2
    if CtlSeqsFileIsAlreadyDisplayed()
        FocusCtlSeqsWindow()
    else
        execute 'noswapfile split +1 ' .. PATH_TO_CTLSEQS
    endif
    if expand('%:t') == 'ctlseqs.txt.gz'
        nnoremap <buffer><expr><nowait> q reg_recording() != '' ? 'q' : '<ScriptCmd>quit!<CR>'
    endif
enddef

export def Info(topic: string) #{{{2
    new
    execute ':.!info ' .. topic
    if bufname('%') != ''
        return
    endif
    # The  filetype needs  to  be `info`,  otherwise `doc#mapping#Main`  would
    # return too early when there is a pattern to search.
    &l:filetype = 'info'
    &l:bufhidden = 'delete'
    &l:buftype = 'nofile'
    &l:buflisted = false
    &l:swapfile = false
    &l:wrap = false
    nnoremap <buffer><expr><nowait> q reg_recording() != '' ? 'q' : '<ScriptCmd>quit<CR>'
enddef

export def FoldInfo() #{{{2
    # Test against these nodes:
    #
    #    - `info '(find)Common Tasks'`
    #    - `info '(find)Worked Examples'`

    # Delete unfolded menu and intro.{{{
    #
    # They're useless and might make it hard  to find our folds (we might even
    # wrongly think  that there  are no  folds if they  start after  the first
    # screen).
    #}}}
    silent! keepjumps keeppatterns :1,/^===/-2 delete _

    # insert markdown-like headers
    silent! keepjumps keeppatterns global/^===/delete _ | :- substitute/^/# /e
    silent! keepjumps keeppatterns global/^---/delete _ | :- substitute/^/## /e
    # delete "File: ..., Node: ..., Next: ..., ..." line
    silent! keepjumps keeppatterns global/^File:/if getline(line('.') + 2) =~ '^#' | .,.+1 delete _ | endif

    # fold info nodes
    normal za
enddef

export def Doc(keyword = '', filetype = '') #{{{2
    if keyword == '' && filetype == ''
        || (keyword == '--help' || keyword == '-h')
        var usage: list<string> =<< trim END
            usage:
                :Doc div        keyword 'div', scoped with current filetype
                :Doc div html   keyword 'div', scoped with html

            If you don't get the expected information,
            make sure that the documentation for the relevant language is enabled on:
                https://devdocs.io/
        END
        echo usage->join("\n")
        return
    endif

    var cmd: string = 'xdg-open'
    # For the syntax of the query, see this link:
    # https://devdocs.io/help#search
    var url: string = 'http://devdocs.io/?q='

    var args: string = filetype == ''
        ? url .. &filetype .. ' ' .. keyword
        : url .. filetype .. ' ' .. keyword

    silent system(cmd .. ' ' .. shellescape(args))
enddef
#}}}1
# Core {{{1
def FocusCtlSeqsWindow() #{{{2
    var bufnr: number = bufnr('ctlseqs\.txt.\gz$')
    var winids: list<number> = win_findbuf(bufnr)
    var tabpagenr: number = tabpagenr()
    winids
        ->filter((_, v: number): bool => getwininfo(v)[0]['tabnr'] == tabpagenr)
        ->get(0)
        ->win_gotoid()
enddef
#}}}1
# Utilities {{{1
def CtlSeqsFileIsAlreadyDisplayed(): bool #{{{2
    return tabpagebuflist()
        ->map((_, v: number): string => bufname(v))
        ->match('ctlseqs\.txt\.gz$') >= 0
enddef
