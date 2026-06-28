vim9script

export def Main()
    var scripts: list<string> = getscriptinfo()
        ->map((_, info: dict<any>): string => $'{info.sid}:{info.name}' )
    if scripts->len() > 1'000
        echohl ErrorMsg
        echo 'too many scripts'
        echohl NONE
        return
    endif

    setqflist([], ' ', {
        lines: scripts,
        efm: '%m:%f',
        title: ':Scriptnames',
        quickfixtextfunc: (_) => [],
    })
    doautocmd <nomodeline> QuickFixCmdPost cwindow
enddef
