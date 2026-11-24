vim9script

import autoload '../autoload/fz/util.vim'

# Config {{{1

const DEFAULT_OPTIONS: list<string> = [
    # To avoid unexpected errors.{{{
    #
    # For example, if  we don't disable `C-g` and press  it while the snippets
    # popup is open, an error is given:
    #
    #     Error detected while processing function <SNR>143_OnExit[22]..<SNR>143_Callback[4]..<SNR>149_Sink:
    #     line    2:
    #     E1093: Expected 2 items but got 0
    #
    # I   think   that's   because   we    bind   it   to   `print-query`   in
    # `$FZF_DEFAULT_OPTS`.
    #}}}
    '--bind=ctrl-g:ignore',
    # size and position of preview window relative to overall popup
    '--preview-window=down,60%,border-up,nowrap',
]

# Key bindings for interacting with selected entries.{{{
#
# Only used  when no  custom `sink`/`sinklist` has  been provided.   Because a
# custom sink  probably means  that the  entries are  not ordinary  file paths
# (e.g. color schemes names).  And `:split` only makes sense with a file path;
# not with a color scheme.
#}}}
const HOW_TO_OPEN: dict<any> = {
    ctrl-s: 'split',
    ctrl-v: 'vsplit',
    alt-T: 'tab split',
    ctrl-q: util.PutInQuickfixList,
}

# size of overall popup window (in percentage of screen area)
const POPUP: dict<float> = {width: 0.75, height: 0.5}

# delay after which `<C-L>` is pressed to make fzf execute its `clear-screen` action
const REDRAW_DELAY: number = 10

# Init {{{1

var spec: dict<any>

# Interface {{{1
export def Run(_spec: dict<any>) # {{{2
    # The following table summarizes the keys supported in `_spec`:
    #
    #     ------------+---------+------------
    #     Option name | Type    | Description
    #     ------------+---------+------------
    #     source      | string  | Shell command to generate input to fzf (e.g. `find .`)
    #     source      | list    | Vim list as input to fzf
    #     sink        | string  | Vim command to handle the selected item (e.g. `edit`, `tabedit`)
    #     sink        | funcref | Reference to function to process each selected item
    #     sinklist    | funcref | Similar to `sink`, but takes the list of output lines at once
    #     options     | list    | Options to fzf
    #     dir         | string  | Working directory for fzf process and any process it starts
    #     ------------+---------+------------
    spec = _spec

    if !spec->has_key('dir')
        spec.dir = getcwd()
    endif

    spec.options = get(spec, 'options', [])
        ->extend(DEFAULT_OPTIONS)
        ->add(
            # Override whatever value we assigned in `$FZF_DEFAULT_OPTS`.{{{
            #
            # We can't  include this option in  `DEFAULT_OPTIONS`, because the
            # terminal's height might change during  a single Vim session.  If
            # it does, the  height of our popup needs to  be re-computed every
            # time `Run()` is invoked.
            #}}}
            $'--height={Height()}'
        )

    if !spec->has_key('sink') && !spec->has_key('sinklist')
        spec.options->add('--expect=' .. keys(HOW_TO_OPEN)->join(','))
        spec.sinklist = DefaultSinkList
    endif

    var source_cmd: string
    var source: any = remove(spec, 'source')
    var typename: string = typename(source)
    # "needles" = fzf output
    # "source" = "haystack" = fzf input
    var tmp_files: dict<string> = {needles: tempname()}
    if typename == 'string'
        source_cmd = source

    # if the source is a list, pass it to fzf via a temporary file
    elseif typename =~ '^list'
        # write the source in a temporary file
        tmp_files.source = tempname()
        writefile(source, tmp_files.source)
        # tell fzf how to read that source
        source_cmd = 'cat ' .. shellescape(tmp_files.source)
    endif

    var cmd: string = $'{source_cmd} | fzf {spec.options->join()} > {tmp_files.needles}'
    TermStart(cmd, tmp_files)
enddef
# }}}1
# Core {{{1
def TermStart(cmd: string, tmp_files: dict<string>) # {{{2
    term_start([&shell, &shellcmdflag, cmd], {
        cwd: spec.dir,
        exit_cb: function(OnExit, [cmd, tmp_files]),
        hidden: true,
        # if we  try to  close the  terminal window, send  SIGTERM to  the fzf
        # process
        term_kill: 'term',
    })->PopupCreate()

    # apply all of our generic terminal-buffer customizations
    doautocmd <nomodeline> TerminalWinOpen
    # apply fzf-specific settings
    setlocal nospell nonumber
    setlocal buftype=nofile bufhidden=wipe noswapfile

    setfiletype fzf
    startinsert
enddef

def PopupCreate(buf: number) # {{{2
    var width: number = float2nr(&columns * POPUP.width)
    var height: number = Height()
    var row: number = float2nr(0.5 * (&lines - height)) + 1
    var col: number = float2nr(0.5 * (&columns - width)) + 1

    popup_create(buf, {
        line: row,
        col: col,
        minwidth: width,
        maxwidth: width,
        minheight: height,
        maxheight: height,
        zindex: 1'000,
    })

    # Without this timer, sometimes, the top border is not drawn.{{{
    #
    # If you  try to refactor the  timer into a simple  `:redraw` (or anything
    # else), make  sure it works in  a usual session with  several windows and
    # tab pages, as well as in a simple session (`$ vim`).
    #}}}
    timer_start(REDRAW_DELAY, (_) => feedkeys("\<C-L>", 'int'), {repeat: 2})
enddef

def OnExit( # {{{2
        cmd: string,
        tmp_files: dict<string>,
        _,
        exit_status: number
        )
    # Close the popup, but only if it hasn't already been done.{{{
    #
    # For example, our `=d` mapping calls `popup_clear(true)`, which can close
    # the fzf popup before `OnExit()` has been invoked.
    #}}}
    if &filetype == 'fzf'
        close
    endif

    var needles: list<string> = filereadable(tmp_files.needles)
        ? readfile(tmp_files.needles)
        : []
    silent! delete(tmp_files.source)
    silent! delete(tmp_files.needles)

    if !ExitHandler(exit_status, cmd)
        return
    endif

    # Problem: The needles might be paths relative to a different CWD than Vim (`spec.dir` vs `getcwd()`).{{{
    #
    # MRE:
    #
    #     $ cd ~/.vim/pack/mine/opt/fz/
    #     $ vim +'FZ --query=ftdetect ~/.vim'
    #     # press M-a to select all entries
    #     # press C-q to quit and set arglist
    #     # expected: the arglist is set with paths to existing files
    #     # actual: the arglist is set with paths to non-existing files
    #}}}
    # Solution: Temporarily `:lcd` into `spec.dir`.
    var original: dict<any> = {
        cwd: getcwd(),
        winid: win_getid(),
    }
    if spec.dir != original.cwd
        execute $'noautocmd lcd {spec.dir}'
    endif

    if has_key(spec, 'sink')
        #                           v--v
        if typename(spec.sink) =~ '^func'
            for needle: string in needles
                spec.sink(needle)
                #-------^
            endfor
        # `spec.sink` is a string
        else
            for needle: string in needles
                execute spec.sink .. ' ' .. fnameescape(needle)
                #       ^-------^
            endfor
        endif
    elseif has_key(spec, 'sinklist')
        spec.sinklist(needles)
    endif

    if spec.dir != original.cwd
        win_execute(original.winid, $'noautocmd lcd {original.cwd}')
    endif
enddef

def DefaultSinkList(paths: list<string>) # {{{2
    # This  function is  only  invoked if  no `sink`  and  no `sinklist`  were
    # specified  when  calling `Run()`.   We  can  therefore assume  that  the
    # needles are actually file paths.

    if len(paths) < 2
        return
    endif

    var expected_key: string = remove(paths, 0)
    var Command: any = get(HOW_TO_OPEN, expected_key, 'edit')

    if typename(Command) =~ '^func'
        Command(paths)
        return
    endif

    if paths->len() > 1
            && Command == 'edit'
        var arglist: string = paths
            ->map((_, path: string) => path->fnameescape())
            ->join()
        execute $'args {arglist}'
        return
    endif

    for path: string in paths
        if path[0] == '~' || path[0] == '/'
            Open(Command, path)
        else
            Open(Command, spec.dir .. '/' .. path)
        endif
    endfor
enddef

def Open(cmd: string, path: string) # {{{2
    # no need to open a file if it's already displayed in the current window
    if cmd == 'edit'
            && fnamemodify(path, ':p') == expand('%:p', true)
        return
    endif
    execute cmd .. ' ' .. fnameescape(path)
enddef
# }}}1
# Util {{{1
def Error(msg: string) # {{{2
    echohl ErrorMsg
    echomsg msg
    echohl None
enddef

def Warn(msg: string) # {{{2
    echohl WarningMsg
    echomsg msg
    echohl None
enddef

def Height(): number # {{{2
    return float2nr(&lines * POPUP.height)
enddef

def ExitHandler(exit_status: number, cmd: string): bool # {{{2
    #    > 130    Interrupted with CTRL-C or ESC
    #
    # Source: `man fzf /EXIT STATUS/;/130`
    if exit_status == 130
        return false
    endif
    if exit_status > 1
        Error($'Error running {cmd}')
        sleep
        return false
    endif
    return true
enddef
