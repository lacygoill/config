vim9script noclear

import autoload '../fz.vim'

const GET_HEADERS_SCRIPT: string = $'{$HOME}/bin/util/notes-headers'
if !filereadable(GET_HEADERS_SCRIPT)
    echohl ErrorMsg
    echomsg $'cannot find util script: {GET_HEADERS_SCRIPT}'
    echohl NONE
    finish
endif

const CORRECTIONS: dict<string> = {
    c: 'C',
    sh: 'bash',
}

const NO_USUAL_TAG: string = ['annex', 'glossary', 'issues', 'pitfalls', 'syntax', 'todo']
    ->map((_, tag: string) => $'!{tag}')
    ->join() .. ' '

# A  tab character  seems to  take too  much valuable  space (which  is scarce
# because a header might be long).
const DELIMITER: string = "\u00a0"
const DELIM: string = '\%u00a0'

# Interface {{{1
export def Fz(all_headers = false) # {{{2
    var args: string
    if !all_headers
        args = [&filetype, expand('%:p'), get(b:, 'repo_root', '')]
            ->map((_, arg: string) => get(CORRECTIONS, arg, arg)->shellescape())
            ->join()
    endif

    var headers: list<string> = systemlist($'{GET_HEADERS_SCRIPT} {args}')
    # If we fail  to find something relevant for the  current file, then let's
    # get everything.
    if headers->empty()
        headers = systemlist($'{GET_HEADERS_SCRIPT}')
    endif

    fz.Run({
        options: [
            '--ansi',
            $"--delimiter='{DELIMITER}'",
            '--expect=ctrl-s,ctrl-v,alt-T,ctrl-q',
            '--multi',
            '--print-query',
            $'--query="{NO_USUAL_TAG}"',
            '--with-nth=1..2',
        ],
        sinklist: Open,
        source: headers,
    })
enddef
# }}}1
# Core {{{1
def Open(chosen: list<string>) # {{{2
    var query: string = chosen[0]->substitute(NO_USUAL_TAG, '', '')
    var expected_key: string = chosen[1]

    if expected_key == 'ctrl-q'
        var entries: list<string> = chosen[2 :]
            ->map((_, entry: string) =>
                entry->substitute($'\(.*\){DELIM}.*{DELIM}\(.*\){DELIM}\(.*\)', '\2:\3:\1', ''))
        lgetexpr entries
        var title: string = 'notes'
        if query != ''
            title ..= $' query={query}'
        endif
        setloclist(0, [], 'a', {title: title})
        return
    endif

    var cmd: string = {
        ctrl-s: 'split',
        ctrl-v: 'vsplit',
        alt-T: 'tab split',
    }->get(expected_key, 'edit')

    var [path: string, lnum: string] = chosen[2]->split(DELIM)[-2 :]

    execute $'{cmd} +{lnum} {path}'
    normal! zvzz
enddef

