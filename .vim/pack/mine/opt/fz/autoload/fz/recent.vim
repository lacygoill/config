vim9script

import autoload '../fz.vim'
import autoload '../fz/util.vim'

const MAX_OLD_FILES: number = 100
const OLD_FILES_PATH: string = $'{$HOME}/.local/share/vim/oldfiles'

# Interface {{{1
export def Files() # {{{2
    var curbuf: string = expand('%:p')
    var source: list<string> = (BuflistedSorted()
        + copy(v:oldfiles)
        + (filereadable(OLD_FILES_PATH)
        ? readfile(OLD_FILES_PATH)
        : [])
        + frec)
        ->map((_, v: string) => util.Expand(v))
        ->filter((_, v: string): bool => v->filereadable()
        && v != ''
        && v != curbuf
        && !isdirectory(v))
        ->map((_, v: string) => v->fnamemodify(':p'))
        ->Uniq()

    fz.Run({
        options: [
            '--multi',
            $'--prompt="Recent Files {$FZF_PROMPT}"'
        ],
        source: source,
    })
enddef

# `~/bin/frec`
var frec: list<string>
if executable('frec')
    var wildignore: string = &wildignore
        ->split(',')
        ->map((_, glob: string) => glob->glob2regpat())
        ->join('\|')
    silent frec = systemlist('frec -f -l')
        ->filter((_, fname: string): bool => fname !~ wildignore)
endif

export def SaveOldFiles() # {{{2
    var buffers: list<string> = getbufinfo({buflisted: true, bufloaded: true})
        ->filter((_, info: dict<any>): bool =>
            info.name !~ '^/\%(dev\|proc\|run\|tmp\)/'
            # `:vimgrep` can create a lot of insignificant hidden buffers; ignore them.
            # Don't use `getbufvar()`.{{{
            #
            # `&hidden` has nothing to do with whether a given buffer is hidden.
            # It's a global option.  So, don't write this:
            #
            #     info.bufnr->getbufvar('&hidden')
            #
            # It's always true, since we set `'hidden'`.
            #}}}
            && !info.hidden)
        ->map((_, info: dict<any>): string => info.name)

    if buffers->empty()
        return
    endif

    var old: list<string>
    if OLD_FILES_PATH->filereadable()
        old = readfile(OLD_FILES_PATH)
            ->map((_, fname: string) => fname->substitute('^$HOME/\@=', $HOME, ''))
    endif

    # Warning: Do not  try to remove  duplicates (with `sort()`  and `uniq()`)
    # *before* removing paths beyond `MAX_OLD_FILES`.  As soon as you sort the
    # paths, you lose the guarantee that the oldest ones are at the start.
    if (buffers + old)->len() > MAX_OLD_FILES
        if !old->empty()
            old->remove(0, [buffers->len(), old->len()]->min() - 1)
        endif
        if (buffers + old)->len() > MAX_OLD_FILES
            buffers->remove(0, buffers->len() - MAX_OLD_FILES - 1)
        endif
    endif

    var new: list<string> = (buffers + old)
        ->filter((_, fname: string): bool => fname->filereadable())
        ->sort()
        ->uniq()
        # Make the  paths immune to a  possible change of `$USER`  (e.g. after
        # migrating to a different system).
        ->map((_, fname: string) => fname->substitute($'^{$HOME}/', '$HOME/', ''))

    if new != old
        writefile(new, OLD_FILES_PATH)
    endif
enddef
# }}}1
# Util {{{1
def BuflistedSorted(): list<string> # {{{2
    # Note: You could also use `undotree()` instead of `lastused`.{{{
    #
    # The maximal precision of `lastused` is  only 1s. `undotree()` has a much
    # better precision,  but the semantics  of the sorting would  change; i.e.
    # the sorting  would no  longer be  based on  the last  time a  buffer was
    # active, but on the last time it was changed.
    #}}}
    return getbufinfo({buflisted: true})
        ->filter((_, v: dict<any>): bool =>
                    getbufvar(v.bufnr, '&buftype', '') == '')
        ->map((_, v: dict<any>): dict<number> =>
                    ({bufnr: v.bufnr, lastused: v.lastused}))
        # the most  recently active buffers  first; for 2 buffers  accessed in
        # the same second, the one with  the bigger number first (because it's
        # the most recently created one)
        ->sort((a: dict<number>, b: dict<number>): number =>
              a.lastused < b.lastused
            ?     1
            : a.lastused == b.lastused
            ?     b.bufnr - a.bufnr
            :    -1
        )->map((_, v: dict<number>): string => bufname(v.bufnr))
enddef

def Uniq(list: list<string>): list<string> # {{{2
    var visited: dict<bool>
    var ret: list<string>
    for path: string in list
        if !empty(path) && !visited->has_key(path)
            ret->add(path)
            visited[path] = true
        endif
    endfor
    return ret
enddef
