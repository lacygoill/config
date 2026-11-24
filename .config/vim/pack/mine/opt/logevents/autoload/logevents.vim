vim9script

# If you get `E12`, read this:{{{
#
# You can't run a shell command from an autocmd listening to `OptionSet`, if the
# latter event has been triggered by a modeline:
#
#     $ vim -Nu NONE +'autocmd OptionSet * call system("")'
#     :help
#     E12: Command not allowed from exrc/vimrc in current dir or tag search
#
# Here, when `:help` is run, the bottom modeline is processed.
# It sets options, which fires `OptionSet`, which invokes `system()`.
#
# However,  when  a  modeline  is  processed,  Vim  temporarily  forbids
# external shell commands from being run, for security reasons.
# So, `system()` gives `E12`.
#
# Anyway, in the past, we sometimes had this error, when:
#
#    - we were logging `OptionSet`
#    - the modeline mechanism was enabled
#    (`'modeline'` was set, and `'modelines'` was greater than 0)
#
# That's because  we did not log  the autocmds in  a real file; instead  we were
# using  an empty  tmux pane  (`tmux display-message  -I`), which  forced us  to
# invoke `system()` every time we had to log an autocmd being fired.
#
# We don't do that anymore (too inefficient).  Now, we use a real logfile (which
# we follow with `less(1)`), which lets us run `writefile()`.
#}}}

# Variables {{{1

const DIR: string = $'{$TMPDIR}/vim'
const LOGFILE: string = DIR .. '/events.log'

var EVENTS: list<string> = getcompletion('', 'event')

# These events are deliberately left out due to side effects:
#
#    - BufReadCmd
#    - BufWriteCmd
#    - FileAppendCmd
#    - FileReadCmd
#    - FileWriteCmd
#    - FuncUndefined
#    - SourceCmd

const DANGEROUS: list<string> =<< trim END
    BufReadCmd
    BufWriteCmd
    FileAppendCmd
    FileReadCmd
    FileWriteCmd
    FuncUndefined
    SourceCmd
END

const SYNONYMS: list<string> =<< trim END
    BufCreate
    BufRead
    BufWrite
END

# Some events are fired too frequently.{{{
#
# It's fine if we want to log them specifically.
# It's not if we're logging everything with `:LogEvents *`.
#}}}
const TOO_FREQUENT: list<string> =<< trim END
    CmdlineChanged
    CmdlineEnter
    CmdlineLeave
    SafeState
    SafeStateAgain
END

EVENTS->filter((_, v: string): bool => (DANGEROUS + SYNONYMS)->index(v, 0, true) == -1)
lockvar! EVENTS

var EVENT2PREDEFINED: dict<any> = {
    CompleteChanged: 'v:event',
    CompleteDone: 'v:completed_item',
    FileChangedShell: 'v:fcs*',
    InsertChange: 'v:insertmode',
    InsertCharPre: 'v:char',
    InsertEnter: 'v:insertmode',
    ModeChanged: 'v:event',
    OptionSet: 'v:option*',
    SwapExists: 'v:swap*',
    TermResponse: 'v:termresponse',
    TextYankPost: 'v:event',
}
EVENT2PREDEFINED
    ->map((_, v: string): any => v[-1] == '*'
        ? v->getcompletion('help')->filter((_, w: string): bool => w =~ '^v:[a-z_]\+$')
        : v)
lockvar! EVENT2PREDEFINED

const BEFORE_REGCONTENTS: number = strcharlen('12:34  TextYankPost  ')
    + strcharlen('v:event.regcontents: ')

# Functions {{{1
# Interface {{{2
export def Main(args: list<string>) #{{{3
    # Do *not* try to remove tmux dependency, and use jobs instead.{{{
    #
    # The logging must be external to the current Vim's instance, otherwwise
    # it would pollute what we're trying to study.
    #}}}
    if !exists('$TMUX')
        Error('only works inside tmux')
        return
    endif
    if empty(args)
        PrintUsage()
        return
    endif
    var idx_unknown_option: number = match(args,
        '-\%(\%(clear\|stop\|v\|vv\|vvv\)\%(\s\|$\)\)\@!\S*')
    if idx_unknown_option >= 0
        Error('unknown OPTION: ' .. args[idx_unknown_option])
        return
    endif

    if args->index('-clear') >= 0
        Clear(args)
        return
    endif
    if args->index('-stop') >= 0
        Stop(args)
        return
    endif

    var events: list<string> = copy(args)->GetEventsToLog()
    if empty(events)
        Error('missing EVENT operand')
        return
    endif

    last_args = args
    # if a pane already exists, just close it
    if pane_id != ''
        Close()
    endif

    var verbosity: number = VerbosityLevel(args)
    OpenTmuxPane(verbosity)
    Log(events, verbosity)
enddef
var pane_id: string
var last_args: list<string>

export def Complete(arglead: string, _, _): string #{{{3
    if arglead[0] == '-'
        var options: list<string> =<< trim END
            -clear
            -stop
            -v
            -vv
            -vvv
        END
        return options->join("\n")
    endif
    return copy(EVENTS)->join("\n")
enddef
#}}}2
# Core {{{2
def Error(msg: string) #{{{3
    echohl ErrorMsg
    echomsg 'LogEvents: ' .. msg
    echohl NONE
enddef

def PrintUsage() #{{{3
    var usage: list<string> =<< trim END
        Usage: LogEvents [OPTION] EVENT...
          or:  LogEvents OPTION
        EVENT can contain a wildcard (e.g. Buf*, Buf[EL], ???New).

              -clear                   clear log
              -stop                    stop logging
              -v                       increase verbosity
              -vv                      increase verbosity even more (<amatch>, <afile>, v:char, v:event, ...)
              -vvv                     max verbosity (necessary to get <abuf>)
    END
    echo usage->join("\n")
enddef

def Clear(args: list<string>) #{{{3
    if join(args) != '-clear'
        Error('-clear must be used alone')
        return
    endif
    if pane_id != ''
        Close()
    else
        Error('nothing to clear')
        return
    endif
    call(Main, [last_args])
enddef

def Stop(args: list<string>) #{{{3
    if join(args) != '-stop'
        Error('-stop must be used alone')
        return
    endif
    if pane_id != ''
        Close()
    else
        Error('nothing to stop')
    endif
enddef

def Close() #{{{3
    if !exists('#LogEvents')
        return
    endif

    autocmd! LogEvents
    augroup! LogEvents

    silent system('tmux kill-pane -t ' .. pane_id)
    pane_id = ''
enddef

def VerbosityLevel(args: list<string>): number #{{{3
    var lvl: number = 0
    if args->index('-v') >= 0
        lvl = 1
    elseif args->index('-vv') >= 0
        lvl = 2
    elseif args->index('-vvv') >= 0
        lvl = 3
    endif
    return lvl
enddef

def GetEventsToLog(arg_events: list<string>): list<string> #{{{3
    var log_everything: bool = arg_events->index('*') >= 0
    # Why do you append a `$`?{{{
    #
    # Without, when we run:
    #
    #     :LogEvents safestate
    #
    # `SafeState` *and* `SafeStateAgain` are logged.
    # It's due to `getcompletion()`:
    #
    #     :echo getcompletion('safestate', 'event')
    #     ['SafeState', 'SafeStateAgain']˜
    #
    # It's as if `getcompletion()` appends a `*` at the end.
    # To prevent that, we append `$`.
    #}}}
    var events: list<list<string>> = arg_events
        ->mapnew((_, v: string): list<string> =>
                    getcompletion(v[-1] =~ '\l' ? v .. '$' : v, 'event'))
    if empty(events)
        return []
    endif
    var flattened: list<string> = events
        ->flattennew()
        # Make sure that all events are present inside `EVENTS`.{{{
        #
        # Otherwise, if  we try to log  a dangerous event, which  is absent from
        # `EVENTS`, the next `map()` will wrongly replace its name with the last
        # event in `EVENTS`, which is `WinNew` atm:
        #
        #       EVENTS->index(v, 0, true) == -1
        #     ⇒ EVENTS[-1]
        #     ⇒ 'WinNew'
        #}}}
        ->filter((_, v: string): bool => EVENTS->index(v, 0, true) >= 0)
        # normalize names
        ->map((_, v: string) => EVENTS[EVENTS->index(v, 0, true)])
    if log_everything
        flattened
            ->filter((_, v: string): bool => TOO_FREQUENT->index(v, 0, true) == -1)
    endif
    return flattened
enddef

def GetExtraInfo(event: string, verbosity: number): string #{{{3
    if verbosity == 1
        return expand('<amatch>')
    endif

    var info: string = ''
    var amatch: string = expand('<amatch>')
    if amatch != ''
        info ..= 'amatch: ' .. amatch
    endif

    var afile: string = expand('<afile>')
    if afile != ''
        if afile == amatch
            info ..= "\nafile: \""
        else
            info ..= "\nafile: " .. afile
        endif
    endif

    if verbosity == 3
        var abuf: string = expand('<abuf>')
        if abuf != ''
            info ..= (info == '' ? '' : "\n") .. 'abuf: ' .. abuf
        endif
    endif

    if EVENT2PREDEFINED->has_key(event)
        info ..= "\n" .. GetPredefInfo(event)
    endif
    return info
enddef

def GetPredefInfo(event: string): string #{{{3
    var predefined: any = EVENT2PREDEFINED[event]
    var s: string
    if predefined->typename() == 'list<string>'
        for p: string in predefined
            s ..= GetPredefInfoFor(p)
        endfor
    else
        s = GetPredefInfoFor(predefined)
    endif
    return s
enddef

def GetPredefInfoFor(predefined: string): string #{{{3
    var s: string
    var predef_val: any = predefined->eval()
    var predef_is_dict: bool = predef_val->typename() =~ '^dict'
    var items: list<any> = predef_is_dict
        ? predef_val->items()
        : [[predefined, predef_val]]
    for [key: string, val: any] in items
        var printed_val: string
        if val->typename() != 'string'
            printed_val = val->string()->strtrans()
        # let's make  sure that an  empty string  is logged as  `''`; otherwise,
        # nothing is printed which is confusing/ambiguous
        elseif val == ''
            printed_val = "''"
        else
            printed_val = val
        endif
        # Truncate `v:event.regcontents` if it's too long.
        # Rationale: user data can be arbitrarily long.  Too much noise.
        if predefined == 'v:event' && key == 'regcontents'
            # We can't use `strcharlen()` here.{{{
            #
            # Here, we really want to know how many cells the printed value will
            # occupy on the screen.
            # And user  data can  contain any  unicode character,  include weird
            # ones occupying multiple cells.
            #}}}
            if printed_val->strdisplaywidth() + BEFORE_REGCONTENTS > &columns
                printed_val = printed_val->slice(0, &columns - BEFORE_REGCONTENTS - 3) .. '...'
            endif
        endif
        if val->typename() =~ '^dict'
            for [k: string, v: any] in val->items()
                s ..= printf("%s.%s.%s: %s\n", predefined, key, k, v->string()->strtrans())
            endfor
        else
            if predef_is_dict
                s ..= printf("%s.%s: %s\n", predefined, key, printed_val)
            else
                s ..= printf("%s: %s\n", predefined, printed_val)
            endif
        endif
    endfor
    return s
enddef

def OpenTmuxPane(verbosity: number) #{{{3
    var split_direction: string = verbosity != 0 ? '-v' : '-h'
    # TODO: When split vertically, a too narrow width can cause an issue.{{{
    #
    # If `less(1)` has to wrap its message at the bottom of the screen:
    #
    #     Waiting for data... (interrupt to abort)
    #
    # ... for  some reason, the latter  might be printed multiple  times, in the
    # middle of the screen.
    #}}}
    var size: string = '-l ' .. (verbosity != 0 ? 50 : 35) .. '%'
    var dont_focus: string = '-d'
    var setcwd: string = '-c ' .. DIR->shellescape()
    var print_pane_id: string = '-PF "#{pane_id}"'
    var shellcmd: string = 'less -+F +F ' .. LOGFILE->shellescape()

    var cmd: string = printf('tmux split-window %s %s %s %s %s %s',
        split_direction,
        size,
        dont_focus,
        setcwd,
        print_pane_id,
        shellcmd,
    )
    silent pane_id = cmd->system()->trim("\n", 2)
enddef

def Log(events: list<string>, verbosity: number) #{{{3
    ['Started logging']->writefile(LOGFILE)

    var biggest_width: number = events
        ->mapnew((_, v: string): number => strlen(v))
        ->max()
    augroup LogEvents
        autocmd!
        for event: string in events
            execute printf('autocmd %s * Write(%d, "%s", "%s")',
                event, verbosity, event, printf('%-*s', biggest_width, event))
        endfor
        # close the tmux pane when we quit Vim, if we didn't close it already
        autocmd VimLeave * Close()
    augroup END
enddef

def Write( #{{{3
    verbosity: number,
    event: string,
    msg: string
)
    var to_append: any = strftime('%M:%S') .. '  ' .. msg
    if verbosity != 0
        to_append ..= '  ' .. GetExtraInfo(event, verbosity)
    endif
    to_append = to_append->split('\n')
    if len(to_append) >= 2
        var indent: string = repeat(
            ' ',
            to_append[0]->matchstr('^\d\+:\d\+\s\+\a\+\s\+')->strcharlen()
        )
        to_append = [to_append[0]]
                   + to_append[1 :]
                       ->map((_, v: string) => indent .. v)
    endif
    writefile(to_append + [''], LOGFILE, 'a')
enddef
