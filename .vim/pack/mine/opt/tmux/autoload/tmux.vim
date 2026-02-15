vim9script

import 'lg.vim'
import autoload './tmux/formatCapture.vim'

const PROMPT_SIGIL: string = "\u066a"

export def PutPreviousPane() #{{{1
# Put the visible part of the tmux previous pane, right below the cursor.

    # collect some info about the current and previous panes
    var pane_mode: string
    var selection_active: string
    var window_zoomed_flag: string
    var tmux_cmd: string = 'tmux '
        ..     'display -p -F "#{pane_mode},#{selection_active}" -t "{last}"'
        .. ' \; display -p -F "#{window_zoomed_flag}"'
    silent [pane_mode, selection_active, window_zoomed_flag] = system(tmux_cmd)
        ->trim("\n")
        ->split(',\|\n', true)
    var in_copy_mode: bool = pane_mode == 'copy-mode'
    var is_selection_active: bool = selection_active == '1'
    var is_maximized: bool = window_zoomed_flag == '1'

    # If  the current  pane  is maximized,  open  a split  and  paste the  whole
    # scrollback buffer in there.
    if is_maximized
        new
        silent systemlist('tmux capture-pane -p -J -S - -t "{last}"')
            ->append('.')
        formatCapture.Main()
        return
    endif

    # make sure we're in copy mode in the previous pane
    if !in_copy_mode
        silent system('tmux copy-mode -t "{last}"')
    endif

    # and make sure there's no active selection
    if is_selection_active
        silent system('tmux send-keys -X -t "{last}" clear-selection')
    endif

    # yank the visible screen in a tmux buffer
    var tmux_subcmds: list<string> =<< trim END
        top-line
        select-line
        bottom-line
        copy-selection
    END
    tmux_cmd = 'tmux '
        .. tmux_subcmds
        ->map((_, v: string) => 'send-keys -X -t "{last}" ' .. v)
        ->join(' \; ')
    silent var tmux_buffer: list<string> = system(tmux_cmd .. ' \; show-buffer')
        ->substitute('\n\+$', '', '')
        ->split('\n')

    # If we were not in copy-mode initially, we should not be in copy-mode at the end.
    if !in_copy_mode
        silent system('tmux send-keys -X -t "{last}" cancel')
    endif

    # put the yanked screen in Vim
    var curlnum: number = line('.')
    var indent: string = getline(curlnum)->matchstr('^\s*')
    # If we put the end of the scrollback buffer, we don't need the last 2 lines
    # with the last shell prompt.  That's noise.
    if tmux_buffer->get(-1, '') == PROMPT_SIGIL
        tmux_buffer->remove(-2, -1)
    endif
    tmux_buffer
        # make sure the lines are correctly indented
        # (i.e. same indent as the current line)
        ->map((_, v: string) => indent .. v)
        ->append(curlnum)
    silent system('tmux delete-buffer')

    if &l:commentstring == '' || &filetype == 'markdown'
        return
    endif

    # If we're  in the  middle of  a comment,  then the  pasted lines  should be
    # automatically commented.
    var firstline: number = curlnum + 1
    var lastline: number = curlnum + len(tmux_buffer)
    if IsCommented(curlnum)
        var range: string = printf(':%d,%d', firstline, lastline)
        execute range .. 'CommentToggle'
        execute 'silent keepjumps keeppatterns '
            .. range .. 'substitute/^\s*' .. GetCml() .. ' \zs/    /e'
    endif
enddef

def IsCommented(lnum: number): bool
    return getline(lnum) =~ '^\s*\V' .. GetCml()
enddef

def GetCml(): string
    return &l:commentstring
        ->matchstr('\S*\ze\s*%s')
        ->escape('\')
enddef

export def PasteLastShellCmd(n: number) #{{{1
    silent var buffer: list<string> = systemlist('tmux show-buffer')

    # The last 2 lines are the prompt of the last yet-to-be-typed command.  Useless.
    buffer = buffer[: -3]

    # remove the top part of all the prompts
    # (i.e. any element after an element which starts with the prompt sigil)
    # Why `copy()`?{{{
    #
    # Because we're going to filter the list `buffer` with a test which involves
    # the item *following* the one currently filtered.
    # And because `filter()` may alter the size of `buffer` during the filtering.
    #
    # If the test only involved the current item, there would be no need for `copy()`.
    #}}}
    var copy_buffer: list<string> = copy(buffer)
    var len_buffer: number = len(buffer)
    buffer
        ->filter((i: number, v: string): bool =>
                   i == 0
                || i == len_buffer - 1
                || copy_buffer[i + 1][0] != PROMPT_SIGIL)
    var idx: number = match(buffer, '^' .. PROMPT_SIGIL, 0, n + 1)
    if idx == -1
        idx = len_buffer
    endif
    buffer = buffer[: idx - 1]

    # Why don't you delete the tmux buffer from the tmux key binding which runs this Vim function?{{{
    #
    # `copy-pipe` and  `if-shell` don't block,  so there's  no way to  know when
    # `delete-buffer` would be run.
    # In practice,  it seems to  be run before Vim  is invoked, which  means that
    # `$ tmux show-buffer` wouldn't give the buffer you expect.
    #}}}
    silent system('tmux delete-buffer')
    if &filetype != 'markdown'
        # run `redraw!` to clear the command-line
        redraw!
        return
    endif
    buffer
        ->map((_, v: string) =>
                '    ' .. v
                ->substitute('^[^٪].*\zs', '~', '')
                ->substitute('^٪', '$', ''))
    if getline('.') =~ '\S'
        buffer = [''] + buffer
    endif
    if (line('.') + 1)->getline() =~ '\S'
        buffer->add('')
    endif
    append('.', buffer)
    update
    redraw!
enddef

export def UndoFtplugin() #{{{1
    set commentstring<
    set errorformat<
    set makeprg<
    nunmap <buffer> g"
    nunmap <buffer> g""
    xunmap <buffer> g"
enddef
#}}}1

# K {{{1
# keyword based jump dictionary maps {{{2

# Mapping short keywords to their longer version so they can be found
# in man page with 'K'
# '\[' at the end of the keyword ensures the match jumps to the correct
# place in tmux man page where the option/command is described.
const KEYWORD_MAPPINGS: dict<string> = {
    attach:       'attach-session',
    bind:         'bind-key \[',
    bind-key:     'bind-key \[',
    breakp:       'break-pane',
    capturep:     'capture-pane',
    clearhist:    'clear-history',
    confirm:      'confirm-before',
    copyb:        'copy-buffer',
    deleteb:      'delete-buffer',
    detach:       'detach-client',
    display:      'display-message',
    displayp:     'display-panes',
    findw:        'find-window',
    has:          'has-session',
    if:           'if-shell',
    joinp:        'join-pane',
    killp:        'kill-pane',
    killw:        'kill-window',
    last:         'last-window',
    lastp:        'last-pane',
    linkw:        'link-window',
    loadb:        'load-buffer',
    lock:         'lock-server',
    lockc:        'lock-client',
    locks:        'lock-session',
    ls:           'list-sessions',
    lsb:          'list-buffers',
    lsc:          'list-clients',
    lscm:         'list-commands',
    lsk:          'list-keys',
    lsp:          'list-panes',
    lsw:          'list-windows \[',
    list-windows: 'list-windows \[',
    movep:    'move-pane',
    movew:    'move-window',
    new:      'new-session',
    neww:     'new-window',
    next:     'next-window',
    nextl:    'next-layout',
    pasteb:   'paste-buffer',
    pipep:    'pipe-pane',
    prev:     'previous-window',
    prevl:    'previous-layout',
    refresh:  'refresh-client',
    rename:   'rename-session',
    renamew:  'rename-window',
    resizep:  'resize-pane',
    respawnp: 'respawn-pane',
    respawnw: 'respawn-window',
    rotatew:  'rotate-window',
    run:      'run-shell',
    saveb:    'save-buffer',
    selectl:  'select-layout \[',
    select-layout: 'select-layout \[',
    selectp:    'select-pane',
    selectw:    'select-window',
    send:       'send-keys',
    set:        'set-option \[',
    set-option: 'set-option \[',
    setb:       'set-buffer \[',
    set-buffer: 'set-buffer \[',
    setenv:     'set-environment',
    setw:       'set-window-option \[',
    set-window-option: 'set-window-option \[',
    show:     'show-options',
    showb:    'show-buffer',
    showenv:  'show-environment',
    showmsgs: 'show-messages',
    showw:    'show-window-options \[',
    show-window-options: 'show-window-options \[',
    source:        'source-file',
    splitw:        'split-window \[',
    split-window:  'split-window \[',
    start:         'start-server',
    suspendc:      'suspend-client',
    swapp:         'swap-pane',
    swapw:         'swap-window',
    switchc:       'switch-client \[',
    switch-client: 'switch-client \[',
    unbind:        'unbind-key \[',
    unbind-key:    'unbind-key \[',
    unlinkw:       'unlink-window'
}

# Syntax highlight  group names are  arranged by  tmux man page  sections.  That
# makes  it easy  to  find  a section  in  the man  page  where  the keyword  is
# described.
# This  dictionary provides  a  mapping  between a  syntax  highlight group  and
# related man page section.
const HIGHLIGHT_GROUP_MAN_PAGE_SECTION: dict<string> = {
    tmuxClientSessionCmds: 'CLIENTS AND SESSIONS',
    tmuxWindowPaneCmds:    'WINDOWS AND PANES',
    tmuxBindingCmds:       'KEY BINDINGS',
    tmuxOptsSet:           'OPTIONS',
    tmuxOptsSetw:          'OPTIONS',
    tmuxEnvironmentCmds:   'ENVIRONMENT',
    tmuxStatusLineCmds:    'STATUS LINE',
    tmuxBufferCmds:        'BUFFERS',
    tmuxMiscCmds:          'MISCELLANEOUS'
}

# keyword based jump {{{2

def GetSearchKeyword(keyword: string): string
    return KEYWORD_MAPPINGS->has_key(keyword)
        ?     KEYWORD_MAPPINGS[keyword]
        :     keyword
enddef

def ManTmuxSearch(section: string, regex: string): bool
    if search('^' .. section) == 0
        return false
    endif
    if search(regex) == 0
        return false
    endif
    return true
enddef

def KeywordBasedJump(highlight_group: string, keyword: string)
    var section: string = HIGHLIGHT_GROUP_MAN_PAGE_SECTION->has_key(highlight_group)
        ?     HIGHLIGHT_GROUP_MAN_PAGE_SECTION[highlight_group]
        :     ''
    var search_keyword: string = GetSearchKeyword(keyword)

    Man tmux

    if ManTmuxSearch(section, '^\s\+\zs' .. search_keyword)
    || ManTmuxSearch(section, search_keyword)
    || ManTmuxSearch('', keyword)
        normal! zt
    else
        redraw
        echohl ErrorMsg
        echo "Sorry, couldn't find " .. keyword
        echohl None
    endif
enddef

# highlight group based jump {{{2

const HIGHLIGHT_GROUP_TO_MATCH_MAPPING: dict<list<string>> = {
    tmuxKeyTable:            ['KEY BINDINGS', '^\s\+\zslist-keys', ''],
    tmuxLayoutOptionValue:   ['WINDOWS AND PANES', '^\s\+\zs{}', '^\s\+\zsThe following layouts are supported'],
    tmuxUserOptsSet:         ['.', '^OPTIONS', ''],
    tmuxKeySymbol:           ['KEY BINDINGS', '^KEY BINDINGS', ''],
    tmuxKey:                 ['KEY BINDINGS', '^KEY BINDINGS', ''],
    tmuxAdditionalCommand:   ['COMMANDS', '^\s\+\zsMultiple commands may be specified together', ''],
    tmuxColor:               ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsmessage-bg'],
    tmuxStyle:               ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsmessage-attr'],
    tmuxPromptInpol:         ['STATUS LINE', '^\s\+\zscommand-prompt', ''],
    tmuxFmtInpol:            ['.', '^FORMATS', ''],
    tmuxFmtInpolDelimiter:   ['.', '^FORMATS', ''],
    tmuxFmtAlias:            ['.', '^FORMATS', ''],
    tmuxFmtVariable:         ['FORMATS', '^\s\+\zs{}', 'The following variables are available'],
    tmuxFmtConditional:      ['.', '^FORMATS', ''],
    tmuxFmtLimit:            ['.', '^FORMATS', ''],
    tmuxDateInpol:           ['OPTIONS', '^\s\+\zsstatus-left', ''],
    tmuxAttrInpol:           ['OPTIONS', '^\s\+\zsstatus-left', ''],
    tmuxAttrInpolDelimiter:  ['OPTIONS', '^\s\+\zsstatus-left', ''],
    tmuxAttrBgFg:            ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsstatus-left'],
    tmuxAttrEquals:          ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsstatus-left'],
    tmuxAttrSeparator:       ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsstatus-left'],
    tmuxShellInpol:          ['OPTIONS', '^\s\+\zsstatus-left', ''],
    tmuxShellInpolDelimiter: ['OPTIONS', '^\s\+\zsstatus-left', '']
}

def HighlightGroupBasedJump(highlight_group: string, keyword: string)
    Man tmux
    var section: string = HIGHLIGHT_GROUP_TO_MATCH_MAPPING[highlight_group][0]
    var search_string: string = HIGHLIGHT_GROUP_TO_MATCH_MAPPING[highlight_group][1]
    var fallback_string: string = HIGHLIGHT_GROUP_TO_MATCH_MAPPING[highlight_group][2]

    var search_keyword: string = search_string->substitute('{}', keyword, '')
    if ManTmuxSearch(section, search_keyword)
    || ManTmuxSearch(section, fallback_string)
        normal! zt
    else
        redraw
        echohl ErrorMsg
        echo 'Sorry, couldn''t find the exact description'
        echohl None
    endif
enddef

# just open man page {{{2

def JustOpenManPage(highlight_group: string): bool
    var char_under_cursor: string = getline('.')->strpart(col('.') - 1)[0]
    var syn_groups: list<string> =<< trim END

        tmuxStringDelimiter
        tmuxOptions
        tmuxAction
        tmuxBoolean
        tmuxOptionValue
        tmuxNumber
    END
    return syn_groups->index(highlight_group) >= 0 || char_under_cursor =~ '\s'
enddef

# 'public' function {{{2

# From where do we call `Man()`?{{{
#
# `doc#mapping#Main()`.
#}}}
# Why don't you simply install a local `K` mapping calling `Man()`?{{{
#
# We would  not be able to  press `K` on constructs  like codespans, codeblocks,
# `:help cmd`, `man cmd`, `info cmd`, `CSI ...` inside a tmux file.
#
# IOW, we want to integrate `Man()` into `doc#mapping#Main()`.
# To  do so,  the latter  must first  be  invoked to  try and  detect whether  a
# familiar construct exists around the cursor position.
# *Then*, if nothing is found, we can fall back on `Man()`.
# The only way to achieve this is to invoke `Man()` from `doc#mapping#Main()`.
#}}}
export def Man()
    var keyword: string = expand('<cWORD>')

    var highlight_group: string = synID('.', col('.'), true)->synIDattr('name')
    if JustOpenManPage(highlight_group)
        Man tmux
    elseif HIGHLIGHT_GROUP_TO_MATCH_MAPPING->has_key(highlight_group)
        HighlightGroupBasedJump(highlight_group, keyword)
        return
    else
        KeywordBasedJump(highlight_group, keyword)
        return
    endif
enddef
# }}}1
# g" {{{1

export def FilterOp(type = ''): string
    if type == ''
        &operatorfunc = function(lg.Opfunc, [{funcname: FilterOp}])
        return 'g@'
    endif
    redraw
    var lines: list<string> = getreg('"', true, true)

    var all_output: string = ''
    var index: number = 0
    while index < len(lines)
        var line: string = lines[index]

        # if line is a part of multi-line string (those have '\' at the end)
        # and not last line, perform " concatenation
        while line =~ '\\\s*$' && index != len(lines) - 1
            ++index
            # remove '\' from line end
            line = line->substitute('\\\s*$', '', '')
            # append next line
            line ..= lines[index]
        endwhile

        # skip empty line and comments
        if line =~ '^\s*\%(#\|$\)'
            continue
        endif

        var command: string = 'tmux ' .. line
        if all_output =~ '\S'
            all_output ..= "\n" .. command
        # empty var, do not include newline first
        else
            all_output = command
        endif

        silent var output: string = system(command)
        if v:shell_error != 0
            throw output
        elseif output =~ '\S'
            all_output ..= "\n> " .. output[: -2]
        endif

        ++index
    endwhile

    if all_output =~ '\S'
        redraw
        echo all_output
    endif
    return ''
enddef
