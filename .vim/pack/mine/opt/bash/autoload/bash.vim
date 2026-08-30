vim9script

export def BreakLongCmd(type = ''): string #{{{1
    if type == ''
        &operatorfunc = BreakLongCmd
        return 'g@l'
    endif

    if !executable('zsh')
        echohl Error
        echo 'requires zsh, but zsh is not installed'
        echohl NONE
        return ''
    endif

    # get new refactored shell command
    var shell_save: string
    if &shell =~ '\Czsh'
        shell_save = &shell
        &shell = 'zsh'
    endif
    var lnum: number = line('.')
    var old: string = getline(lnum)
    silent var new: list<string> =
        systemlist('cmd=' .. shellescape(old) .. "; printf '%s\n' ${${(z)cmd}[@]}")
    if shell_save != ''
        &shell = shell_save
    endif

    # add indentation for lines after the first one
    var curindent: string = old->matchstr('^\s*')
    new
        ->map((i: number, v: string) => i > 0 ? curindent .. '    ' .. v : curindent .. v)
        # add line continuations for lines before the last one
        ->map((i: number, v: string) => i < len(new) - 1 ? v .. ' \' : v)

    # replace old command with new one
    var reg_save: dict<any> = getreginfo('"')
    reg_save
        ->deepcopy()
        ->extend({regcontents: new, regtype: 'l'})
        ->setreg('"')
    execute 'normal! ' .. lnum .. 'GVp'
    setreg('"', reg_save)

    # join lines which don't start with an option with the previous one (except for the very first line)
    var range: string = ':' .. (lnum + 1) .. ',' .. (lnum + len(new) - 1)
    execute 'silent ' .. range .. 'global/^\s*[^-+ ]/ :.-1 substitute/\\$// | join'
    #                                           ^^
    #                                           options usually start with a hyphen, but also – sometimes – with a plus
    return ''
enddef

export def UndoFtplugin() #{{{1
    set errorformat<
    set makeprg<
    set shiftwidth<
    set textwidth<

    nunmap <buffer> =rb

    nunmap <buffer> [m
    nunmap <buffer> ]m
    nunmap <buffer> [M
    nunmap <buffer> ]M
enddef
