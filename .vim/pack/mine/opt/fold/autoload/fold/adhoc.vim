vim9script

import autoload '../fold/foldtext.vim'
import autoload 'fex/tree.vim'

const HOW_TO_FOLD: dict<dict<any>> = {
    #     $ apt changelog transmission-daemon
    #     # press E to pipe `less(1)` buffer to Vim
    changelog: {
        condition: () => &filetype =~ '\%(deb\)\=changelog',
        1: '^\S',
        default: '1',
    },
    journalctl: {
        1: '^-- Subject: ',
        default: '1',
    },
    #     $ nm --defined-only $(locate libncurses.a)
    nm: {
        condition: () => getline(1) == '' && getline(2) =~ '\%(\w\|[-+.]\)*\.o:$',
        1: '\%(\w\|[-+.]\)*\.o:$',
        default: '1',
    },
    #     $ objdump --all-headers /usr/bin/ls | vim -
    objdump-all-headers: {
        condition: () => search('^Program Header:', 'cn') > 0,
        1: '^[A-Z].*:',
        default: '=',
    },
    #     $ objdump --disassemble /usr/bin/ls | vim -
    objdump-disassemble: {
        1: '^Disassembly of section',
        2: '^\x\{16}\s',
        default: '=',
    },
    #     $ ps --forest --user=$USER | vim -
    ps-forest: {
        condition: () => search('\\_ ', 'cn') > 0,
        1: '^\%(\%(\\_\)\@!.\)*$',
        2: '|\s*\\_ ',
        default: '=',
    },
    #     $ systemd-cgls | vim -
    systemd-cgls: {
        condition: () => getline(1) =~ '^CGroup /:' && search('^[├└]', 'cn') > 0,
        1: '^[├└]',
        # Warning: Don't use the `*` quantifier.
        # We need to match the exact amount of spaces.
        #
        # NOTE: The right side of the alternations is for all the lines inside
        # the last fold of level 1.
        2: '^│ [├└]─' .. '\|' .. '^  [├└]─',
        3: '^│   [├└]─' .. '\|' .. '^  │ [├└]─',
        4: '^│   │ [├└]─' .. '\|' .. '^  │   [├└]─',
        default: '=',
    },
    terminal: {
        1: '^٪',
        default: '1',
    },
}

# Interface {{{1
export def Main() #{{{2
    if ['changelog', 'debchangelog', 'info', 'markdown', 'text', '']
            ->index(&filetype) == -1
        return
    endif

    for how: dict<any> in HOW_TO_FOLD->values()
        var h: dict<any> = how->copy()
        if !h->get('condition', () => search(h.1, 'cn') > 0)()
            continue
        endif
        var default: string = h->remove('default')
        if h->has_key('condition')
            h->remove('condition')
        endif
        &l:foldmethod = 'expr'
        &l:foldexpr = $'AdHocExpr({h->string()}, {default->string()})'
        &l:foldtext = 'foldtext.Get()'
        # Useful for `systemd-cgls(1)`.{{{
        #
        # For example, here:
        #
        #     └─system.slice
        #       ...
        #       ├─lightdm.service
        #       │ ├─684 /usr/sbin/lightdm
        #       │ └─704 /usr/lib/xorg/Xorg ...
        #
        # If `'foldminlines'` is `0`, each of  the last two lines is closed in
        # a separate fold (because the current  design of this script does not
        # let  us test  that the  last line  is actually  part of  an existing
        # fold), which feels wrong.
        #}}}
        # In the output of `$ ps --forest`, a closed fold sometimes still unexpectedly contain only 1 line!{{{
        #
        # Right.  It seems  to happen if the line is  longer than the screen's
        # width.  Whether `&l:wrap` is `true`  doesn't matter; how long is the
        # fold title doesn't  matter either.  Is it a Vim  bug?  Or maybe it's
        # because our  fold expression is  too naive,  and often starts  a new
        # fold needlessly?  Anyway,  either refactor the code to  make it less
        # naive, or just  toggle the sizes in the fold  titles.  The titles of
        # the "real" folds will start with something like `[123]`.
        #}}}
        &l:foldminlines = 1
        return
    endfor

    # `$ tree /usr/share/doc | vim -`
    #
    # This block should come *after* using `HOW_TO_FOLD`.{{{
    #
    # `HOW_TO_FOLD`  contains  more  conditions  and regexes  which  are  more
    # specific; they should  have the priority.  In particular,  we don't want
    # `$ systemd-cgls | vim -` to be wrongly folded like `tree(1)`.
    #}}}
    if &buftype != 'terminal'
            && search('^│', 'cn') > 0
        &l:foldmethod = 'expr'
        &l:foldexpr = 'tree.FoldExpr()'
        &l:foldtext = 'tree.FoldText()'
        return
    endif

    if IsVimProfilingLog()
        AddMarkers()
    endif

    b:title_like_in_markdown = true
    unlet! b:did_ftplugin
    runtime! ftplugin/markdown.vim

    # Usually, we set fold options via an autocmd listening to `BufWinEnter`.
    # The cursor might move because we have an autocmd executing ``g`"``.{{{
    #
    #     $ less ~/.bashrc
    #     # press H to open less(1) help screen
    #     # press E to pipe the buffer to Vim
    #     # press G to jump to the bottom
    #     # press za to fold the buffer
    #     # expected: the cursor should not move
    #}}}
    var view: dict<number> = winsaveview()
    doautocmd <nomodeline> BufWinEnter
    winrestview(view)
enddef
#}}}1
# Core {{{1
def AddMarkers() #{{{2
    # create an empty fold before the first profiled function for better readability
    AddEmptyFold('FUNCTION')
    # same thing befored the summary at the end
    AddEmptyFold('FUNCTIONS SORTED')
    # marker for each function
    silent keepjumps keeppatterns :% substitute/^FUNCTION\s\+/## /e
    # marker for each script, and for the ending summaries
    silent keepjumps keeppatterns :% substitute/^SCRIPT\|^\zeFUNCTIONS SORTED/# /e
enddef

def AddEmptyFold(pat: string) #{{{2
    if search(pat, 'n') == 0
        return
    endif
    execute $'silent keepjumps keeppatterns :1/^{pat}\s/-1 put _'
    silent keepjumps keeppatterns substitute/^/#/
enddef

def AdHocExpr(how: dict<string>, default: string): string #{{{2
    var line: string = getline(v:lnum)
    for [lvl: string, pat: string] in how->items()
        if line =~ pat
            return $'>{lvl}'
        endif
    endfor
    return default
enddef
#}}}1
# Util {{{1
def IsVimProfilingLog(): bool #{{{2
    return search('count  total (s)   self (s)', 'n') > 0
        && search('^\%(FUNCTION\|SCRIPT\|FUNCTIONS SORTED\)\s', 'n') > 0
enddef
