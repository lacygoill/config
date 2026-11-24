vim9script

# TODO: Split the code: one feature per file.

import 'lg.vim'
import 'lg/window.vim'
import autoload 'mangrep.vim'

# Init {{{1

const EFM_TYPE: dict<string> = {
    e: 'error',
    w: 'warning',
    i: 'info',
    n: 'note',
    # we use  this ad-hoc  flag in `vim-stacktrace`  to distinguish  Vim9 errors
    # which are given at compile time, from those given at runtime
    c: 'compiling',
}

const HELP_TEXT: list<string> =<< trim END
    # only keep entries whose text match PAT
    :Cfilter PAT

    # remove all entries whose text match PAT
    :Cfilter! PAT

    # only keep entries in a file whose filetype is listed in FILETYPES
    :Cfilter -filetype=FILETYPES

    # remove all entries in a file whose filetype is listed in FILETYPES
    :Cfilter! -filetype=FILETYPES
END

var pos: list<number>
var idx: number

# Interface {{{1
export def Quit() #{{{2
    if reg_recording() != ''
        feedkeys('q', 'in')
        return
    endif
    quit
enddef

export def Align(info: dict<number>): list<string> #{{{2
    var qfl: list<any>
    if info.quickfix
        qfl = getqflist({id: info.id, items: 0}).items
    else
        qfl = getloclist(info.winid, {id: info.id, items: 0}).items
    endif
    var l: list<string>
    var range: list<number> = range(info.start_idx - 1, info.end_idx - 1)
    var lnum_width: number = range
        ->copy()
        ->map((_, n: number) => qfl[n]['lnum'])
        ->max()
        ->len()
    var col_width: number = range
        ->copy()
        ->map((_, n: number) => qfl[n]['col'])
        ->max()
        ->len()
    var pat_width: number = range
        ->copy()
        ->map((_, n: number) => strcharlen(qfl[n]['pattern']))
        ->max()
    var fname_width: number = range
        ->copy()
        ->map((_, n: number) =>
            qfl[n]['bufnr']->bufname()->fnamemodify(':t')->strcharlen())
        ->max()
    var type_width: number = range
        ->copy()
        ->map((_, n: number) =>
            get(EFM_TYPE, qfl[n]['type'], '')->strcharlen())
        ->max()
    var errnum_width: number = range
        ->copy()
        ->map((_, n: number) => qfl[n]['nr'])
        ->max()
        ->len()
    for idx: number in range
        var e: dict<any> = qfl[idx]
        if !e.valid
            l->add($'|| {e.text}')
        # happens  if you  re-open  the  qf window  after  wiping  out a  buffer
        # containing an entry from the qfl
        elseif e.bufnr == 0
            l->add('the buffer no longer exists')
        else
            # case where the entry does not  refer to a particular location in
            # a file, but just to a file as a whole (e.g. `:Cfd`)
            if e.lnum == 0 && e.col == 0 && e.pattern == ''
                l->add(bufname(e.bufnr))
            else
                var fname: string = printf('%-*S', fname_width, bufname(e.bufnr)
                    ->fnamemodify(full_filepath ? ':p' : ':t'))
                var lnum: string = printf('%*d', lnum_width, e.lnum)
                var col: string = printf('%*d', col_width, e.col)
                var pat: string = printf('%-*S', pat_width, e.pattern)
                var type: string = printf('%-*S', type_width, get(EFM_TYPE, e.type, ''))
                var errnum: string = ''
                if e.nr > 0
                    errnum = printf('%*d', errnum_width + 1, e.nr)
                endif
                if e.pattern == ''
                    l->add(printf('%s|%s col %s %s%s| %s', fname, lnum, col, type, errnum, e.text))
                else
                    l->add(printf('%s|%s %s%s| %s', fname, pat, type, errnum, e.text))
                endif
            endif
        endif
    endfor
    return l
enddef

export def Cfilter( #{{{2
        bang: bool,
        pat: string,
        mod: string
        )
    if pat == ''
        for line: string in HELP_TEXT
            echo line ?? "\n"
        endfor
        return
    endif

    var Filter: func
    if pat =~ '^-filetype='
        var filetypes: list<string> = pat
            ->matchstr('^-filetype=\zs\S*')
            ->split(',')
        if bang
            Filter = (_, entry: dict<any>): bool => filetypes->index(entry.bufnr->getbufvar('&filetype')) == -1
        else
            Filter = (_, entry: dict<any>): bool => filetypes->index(entry.bufnr->getbufvar('&filetype')) >= 0
        endif
        # If we don't load  a quickfix buffer, `getbufvar(bufnr, '&filetype')`
        # will be empty no matter what.
        mangrep.LoadQuickFixListBuffers()
    else
        # We only filter based on the text (`entry.text`).{{{
        #
        # If you want to filter based on the filepath:
        #
        #     bufname(entry.bufnr)->fnamemodify(':p')
        #
        # ... make up a dedicated syntax.  Do  *not* filter based on both the text
        # and the filepath: it's too confusing, and can give unexpected results.
        #}}}
        if bang
            Filter = (_, entry: dict<any>): bool => entry.text !~ pat
        else
            Filter = (_, entry: dict<any>): bool => entry.text =~ pat
        endif
    endif

    # get a qfl with(out) the entries we want to filter
    var qflist: list<dict<any>> = Getqflist()
    var old_size: number = len(qflist)
    filter(qflist, Filter)

    if len(qflist) == old_size
        echo 'No entry was removed'
        return
    endif

    var title: string = Get('title')->AddFilterIndicatorToTitle(pat, bang)
    var action: string = GetAction(mod)
    Setqflist([], action, {items: qflist, title: title})

    # tell me what you did and why
    echo printf('(%d) items were removed because they %s match %s',
        old_size - len(qflist),
        bang
        ?    'DID'
        :    'did NOT',
        strcharlen(pat) <= 50
        ?    pat
        :    'the pattern')
enddef

export def CfreeStack(loclist = false) #{{{2
    if loclist
        setloclist(0, [], 'f')
        lhistory
    else
        setqflist([], 'f')
        chistory
    endif
enddef

export def ConcealLtagPatternColumn() #{{{2
# We don't  want to  see the middle  column displaying a  pattern in  a location
# window opened by an `:ltag` command.
    if get(w:, 'quickfix_title', '')[: 4] != 'ltag '
        return
    endif
    if get(w:, 'ltag_conceal_match', 0) >= 1
        matchdelete(w:ltag_conceal_match)
    endif
    w:ltag_conceal_match = matchadd('Conceal', '|.\{-}\\\$\s*|' .. '\|' .. '|.\{-}|')
    &l:concealcursor = 'nvc'
    &l:conceallevel = 3
enddef

export def Context() #{{{2
    var Getqflist_context: func
    var wintype: string = win_gettype()
    if wintype == 'quickfix'
        Getqflist_context = function('getqflist', [{context: 0}])
    elseif wintype == 'loclist'
        Getqflist_context = function('getloclist', [0] + [{context: 0}])
    else
        return
    endif

    # make sure the quickfix list is associated to some context, and that it's ours
    var context: any = Getqflist_context().context
    if !(context->typename() =~ '^dict<'
            && context->get('origin', '') == 'mine')
        return
    endif

    if context->has_key('matches')
        var matches: list<list<string>> = context.matches
        for [HG: string, regex: string] in matches
            # We support a few special named regexes as a short and convenient
            # way to  match some given  text.  For example,  `location` should
            # match the file  names as well as the line  and column numbers of
            # all entries.   And `barbar` should  match `|| ` at the  start of
            # invalid entries.
            matchadd(HG, {
                location: '^.\{-}|\s*\%(\d\+\)\=\s*\%(col\s\+\d\+\)\=\s*|\s\=',
                barbar: '^|\s*|\s*\|\s*|\s*|\s*$',
            }->get(regex, regex))
            if HG == 'Conceal'
                &l:conceallevel = 3
                &l:concealcursor = 'nc'
            endif
        endfor
    endif
enddef

export def RemoveInvalidEntries() #{{{2
    var qfl: list<dict<any>> = Getqflist()
        ->filter((_, entry: dict<any>): bool => entry.valid)
    Setqflist([], 'r', {items: qfl, title: Get('title')})
enddef

export def Cupdate(mod: string) #{{{2
    SavePosAndIdx()

    # get a qfl where the text is updated
    var list: list<dict<any>> = Getqflist()
        # Why `extend()`?{{{
        #
        # There  will be  a conflict  between the  old value  associated to  the key
        # `text`, and the new one.
        #
        # And in  case of conflict, by  default `extend()` overwrites the  old value
        # with the  new one.  So,  in effect, `extend()`  will replace the  old text
        # with the new one.
        #}}}
        ->map((_, entry: dict<any>) => extend(entry, {
                # Why `?? entry.text`?{{{
                #
                # If the  buffer is unloaded, `getbufoneline()`  might return an
                # empty string.   In that case, we  want the text field  to stay
                # the same (hence `entry.text`).
                #}}}
                text: getbufoneline(entry.bufnr, entry.lnum) ?? entry.text
        }))

    # set this new qfl
    var action: string = GetAction(mod)
    Setqflist([], action, {items: list})

    RestorePosAndIdx()
enddef

export def ConcealOrDelete(type = ''): string #{{{2
# Purpose:
#    - conceal visual block
#    - delete anything else (and update the qfl)

    if type == ''
        &operatorfunc = ConcealOrDelete
        return 'g@'
    endif

    var range: list<number>
    if ['char', 'line']->index(type) >= 0
        range = [line("'["), line("']")]
    elseif type == 'block'
        var vcol1: number = virtcol("'[", true)[0]
        var vcol2: number = virtcol("']", true)[0]
        # We could also use:{{{
        #
        #     var pat: string = '\%V.*\%V'
        #
        # ... but the match would disappear when we change the focused window,
        # probably because the visual marks would be set in another buffer.
        #}}}
        var pat: string = $'\%{vcol1}v.*\%{vcol2}v.'
        matchadd('Conceal', pat, 0, -1, {conceal: 'x'})
        &l:concealcursor = 'nc'
        &l:conceallevel = 3
        return ''
    endif

    SavePosAndIdx()

    # get a qfl without the entries we want to delete
    var qfl: list<dict<any>> = Getqflist()
    remove(qfl, range[0] - 1, range[1] - 1)

    # we need to preserve conceal options, because our qf filetype plugin resets them
    var conceallevel_save: number = &l:conceallevel
    var concealcursor_save: string = &l:concealcursor
    # set this new qfl
    Setqflist([], 'r', {items: qfl})
    [&l:conceallevel, &l:concealcursor] = [conceallevel_save, concealcursor_save]

    RestorePosAndIdx()
    return ''
enddef

export def DisableSomeKeys(keys: list<string>) #{{{2
    if !exists('b:undo_ftplugin') || b:undo_ftplugin == ''
        b:undo_ftplugin = 'execute'
    endif
    for key: string in keys
        execute $'silent nnoremap <buffer><nowait> {key} <Nop>'
        b:undo_ftplugin ..= $'|execute "nunmap <buffer> {key}"'
    endfor
enddef

export def Nv(errorfile: string): string #{{{2
    var file: list<string> = readfile(errorfile)
    if empty(file)
        return ''
    endif
    if file->len() > 1'000
        echohl ErrorMsg
        echomsg 'Nv(): too many errors'
        echohl NONE
        return
    endif

    var title: string = file->remove(0)
    # we use simple error formats suitable for a grep-like command
    var qfl: dict<any> = getqflist({
        lines: file,
        efm: '%f:%l:%c:%m,%f:%l:%m'
    })
    var items: list<dict<any>> = get(qfl, 'items', [])
    setqflist([], ' ', {items: items, title: title})
    cwindow
    return ''
enddef

export def OpenAuto(cmd: string) #{{{2
    # `:lhelpgrep`, like `:helpgrep`, opens a help window (with 1st match).{{{
    #
    # But, contrary to `:helpgrep`, the location list is local to a window.
    # Which one?
    # The one where we executed `:lhelpgrep`? No.
    # The help window opened by `:lhelpgrep`? Yes.
    #
    # So, the ll window will NOT be associated with the window where we executed
    # `:lhelpgrep`, but to the help window (with 1st match).
    #
    # And,  `:cwindow` will  succeed from  any window,  but `:lwindow`  can only
    # succeed from the help window (with 1st match).
    # But, when `QuickFixCmdPost` is fired, this help window hasn't been created yet.
    #
    # We need to delay `:lwindow` with a one-shot autocmd listening to `BufWinEnter`.
    #}}}
    if cmd == 'lhelpgrep'
        #       ┌ next time a buffer is displayed in a window
        #       │                    ┌ call this function to open the location window
        #       │                    │
        autocmd BufWinEnter * ++once timer_start(0, (_) => Open('lhelpgrep'))
    else
        Open(cmd)
    endif
enddef

def Open(arg_cmd: string)
    #    ^
    #    we need to know which command was executed to decide whether
    #    we open the qf window or the ll window

    # all the commands populating a ll seem to begin with the letter l
    var prefix: string
    var size: number
    if arg_cmd =~ '^l'
        [prefix, size] = arg_cmd =~ '^l'
            ?     ['l', getloclist(0, {size: 0}).size]
            :     ['c', getqflist({size: 0}).size]
    else
        [prefix, size] = arg_cmd =~ '^l'
            ?     ['l', getloclist(0, {size: 0}).size]
            :     ['c', getqflist({size: 0}).size]
    endif

    var mod: string = window.GetMod()

    # Wait.  `:copen` can't populate the qfl.  How could `cmd` be `copen`?{{{
    #
    # In some of our  plugins, we may want to open the qf  window even though it
    # doesn't contain any valid entry (e.g.: `:Scriptnames`).
    # In that case, we execute sth like:
    #
    #     doautocmd <nomodeline> QuickFixCmdPost copen
    #     doautocmd <nomodeline> QuickFixCmdPost lopen
    #
    # In these  examples, `:copen` and  `:lopen` are not valid  commands because
    # they don't  populate a  qfl.  We  could probably use  an ad-hoc  name, but
    # `:copen`  and `:lopen`  make the  code more  readable.  The  command names
    # express our intention: we want to open the qf window unconditionally
    #}}}
    var cmd: string = expand('<amatch>') =~ '^[cl]open$' ? 'open' : 'window'
    var how_to_open: string
    if mod =~ 'vertical'
        how_to_open = $'{mod} {prefix}{cmd} 40'
    else
        var height: number = max([min([10, size]), &winminheight + 2])
        #                     │    │
        #                     │    └ at most 10 lines high
        #                     └ at least `&winminheight + 2` lines high
        # Why `&winminheight + 2`?{{{
        #
        # First, the number passed to `:[cl]{open|window}`  must be at least 1, even
        # if the qfl is empty.  E.g., `:lwindow 0` would give `E939`.
        #
        # Second, if `'equalalways'` is reset, and the  qf window is only 1 or 2
        # lines high, pressing Enter on the qf entry would give `E36`.
        # In general, the issue is triggered when  the qf window is `&winminheight + 1` lines
        # high or lower.
        #}}}
        how_to_open = $'{mod} {prefix}{cmd} {height}'
    endif

    # it will fail if there's no loclist
    try
        execute how_to_open
    catch
        lg.Catch()
        return
    endtry

    if arg_cmd == 'helpgrep'
        # Why do you close the help window?{{{
        #
        #    - The focus switches to the 1st entry in the qfl;
        #      it's distracting.
        #
        #      I prefer to first have a look at all the results.
        #
        #    - If it's opened now, it will be from our current window,
        #      and it may be positioned in a weird place.
        #
        #      I prefer to open it later from the qf window;
        #      this way, they will be positioned next to each other.
        #}}}
        #   Why don't you close it for `:lhelpgrep`, only `:helpgrep`?{{{
        #
        # Because, the location list is attached to this help window.
        # If we close it, the ll window will be closed too.
        #}}}

        # Why the delay?{{{
        #
        # It doesn't work otherwise.
        # Probably because the help window hasn't been opened yet.
        #}}}
        # Do *not* listen to any other event.{{{
        #
        # They are full of pitfalls.
        #
        # For example, `BufWinEnter` or `BufReadPost` may give `E788` (only in Vim):
        #
        #     #                                              v---------v
        #     autocmd QuickFixCmdPost * cwindow 10 | autocmd BufWinEnter * ++once helpclose
        #     helpgrep foobar
        #     helpgrep wont_find_this
        #     helpgrep wont_find_this
        #     E788: Not allowed to edit another buffer now˜
        #
        # And `BufEnter` may give `E426` and `E433`:
        #
        #     autocmd QuickFixCmdPost * cwindow 10 | autocmd BufEnter * ++once helpclose
        #     helpgrep wont_find_this
        #     help
        #     E433: No tags file˜
        #     E426: tag not found: help.txt@en˜
        #}}}
        autocmd SafeState * ++once helpclose
    endif
enddef

export def OpenManual(where: string) #{{{2
    var wintype: string = win_gettype()
    var size: number = wintype == 'loclist'
        ?     getloclist(0, {size: 0}).size
        :     getqflist({size: 0}).size
    if empty(size)
        echo (wintype == 'loclist' ? 'location' : 'quickfix') .. ' list is empty'
        return
    endif

    var splitbelow_was_on: bool = &splitbelow | &splitbelow = false
    try
        if where == 'nosplit'
            execute "normal! \<CR>zv"
            return
        endif

        execute "normal! \<C-W>\<CR>zv"
        if where == 'vertical split'
            wincmd L
        elseif where == 'tabpage'
            var orig: number = win_getid()
            tab split
            var new: number = win_getid()
            win_gotoid(orig)
            quit
            win_gotoid(new)
        endif
    catch
        lg.Catch()
        return
    finally
        if splitbelow_was_on
            &splitbelow = true
        endif
    endtry
enddef

export def ToggleFullFilePath() #{{{2
    SavePosAndIdx()

    full_filepath = !full_filepath
    var list: list<dict<any>> = Getqflist()
    Setqflist([], 'r', {items: list})

    RestorePosAndIdx()
enddef
var full_filepath: bool

export def UndoFtplugin() #{{{2
    set buflisted<
    set cursorline<
    set statusline<
    set wrap<

    nunmap <buffer> <C-Q>
    nunmap <buffer> <C-R>

    nunmap <buffer> <C-S>
    nunmap <buffer> <C-V><C-V>
    nunmap <buffer> <C-T>

    nunmap <buffer> <CR>
    nunmap <buffer> <C-W><CR>

    nunmap <buffer> D
    nunmap <buffer> DD
    xunmap <buffer> D

    nunmap <buffer> cof
    nunmap <buffer> p
    nunmap <buffer> P

    nunmap <buffer> q

    delcommand CremoveInvalid

    delcommand Csave
    delcommand Crestore
    delcommand Cremove

    delcommand Cconceal
    delcommand Cfilter
    delcommand Cupdate
enddef
#}}}1
# Utilities {{{1
def AddFilterIndicatorToTitle( #{{{2
        title: string,
        pat: string,
        bang: bool
        ): string

    # What is this “filter indicator”?{{{
    #
    # If  the qfl  has  already been  filtered,  we don't  want  to add  another
    # `[:filter pat]`  in the  title.  Too  verbose.  Instead we  want to  add a
    # “branch” or a “concat”:
    #
    #     [:filter! pat1] [:filter! pat2]    ✘
    #     [:filter! pat1 | pat2]             ✔
    #
    #     [:filter pat1] [:filter pat2]      ✘
    #     [:filter pat1 & pat2]              ✔
    #}}}
    var filter_indicator: string = '\s*\[:filter' .. (bang ? '!' : '!\@!')
    var has_already_been_filtered: bool = match(title, filter_indicator) >= 0
    return has_already_been_filtered
        ?     title->substitute('\ze\]$', (bang ? ' | ' : ' \& ') .. pat, '')
        :     $'{title} [:filter{bang ? '!' : ''} {pat}]'
enddef

def GetAction(mod: string): string #{{{2
    return mod =~ '^keep' ? ' ' : 'r'
    #                        ^     ^
    #                        |     + don't create a new list, just replace the current one
    #                        + create a new list
enddef

def Get(property: string): any #{{{2
    return win_gettype() == 'loclist'
        ? getloclist(0, {[property]: 0})[property]
        : getqflist({[property]: 0})[property]
enddef

def Getqflist(): list<dict<any>> #{{{2
    return win_gettype() == 'loclist' ? getloclist(0) : getqflist()
enddef

def MaybeResizeHeight() #{{{2
    if winnr('$') == 1 || winwidth(0) != &columns
        return
    endif

    # no more than 10 lines
    var newheight: number = min([10, Getqflist()->len()])
    # at least 2 lines (to avoid `E36` if we've reset `'equalalways'`)
    newheight = max([2, newheight])
    execute $'resize {newheight}'
enddef

def Setqflist(...l: list<any>) #{{{2
    if win_gettype() == 'loclist'
        call('setloclist', [0] + l)
    else
        call('setqflist', l)
    endif

    MaybeResizeHeight()
enddef

def SavePosAndIdx() #{{{2
    pos = getcurpos()
    idx = Get('idx')
enddef

def RestorePosAndIdx() #{{{2
    Setqflist([], 'a', {idx: idx})
    setpos('.', pos)
enddef
