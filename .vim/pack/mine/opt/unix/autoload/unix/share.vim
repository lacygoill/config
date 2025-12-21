vim9script

export def Main(lnum1: number, lnum2: number)
    var lines: list<string> = getline(lnum1, lnum2)
    if lines->len() < 3
        # https://paste.debian.net/  doesn't seem  to accept  a paste  shorter
        # than 3 lines
        echomsg 'Share: need at least 3 lines'
        return
    endif

    # `-P`: private; create a non-public paste (the URL contains with `/private/`)
    # `-a`: author; default is `$USER`
    silent var url: string = 'pastebinit -a anonymous -b https://paste.debian.net'
        ->systemlist(lines)
        ->get(-1, '')
    echomsg url
    silent system('xdg-open ' .. shellescape(url))
enddef
