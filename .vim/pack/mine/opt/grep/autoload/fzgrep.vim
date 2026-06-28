vim9script

import autoload './grep.vim'
import autoload 'fz.vim'

var grep_cmd: string

# Config {{{1

const MAX_PAT_LEN: number = 10

# Interface {{{1
export def Main(args: string) # {{{2
    var shortened_args: string = args->strcharlen() > MAX_PAT_LEN
        ? args[: MAX_PAT_LEN - 1] .. '…'
        : args
    var output: dict<any> = grep.Run(args)
    if output->empty()
        return
    endif

    fz.Run({
        options: [
            '--delimiter=:',
            '--expect=ctrl-s,ctrl-v,alt-T,ctrl-q',
            '--nth=4..',
            '--multi',
            '--print-query',
            # if `git-grep(1)` is called, let's try to keep a short prompt
            $'--prompt="{grep_cmd =~ '^git' ? 'git grep' : grep_cmd} {shortened_args} {$FZF_PROMPT}"',
        ],
        sinklist: Open,
        source: output.lines,
    })
enddef
# }}}1
# Core {{{1
def GetSource(opts: string, pat: string): list<string> #{{{2
    silent return systemlist($'{grep_cmd} {opts}{pat->shellescape()}')
enddef

def Open(chosen: list<string>) # {{{2
    # When there's no match, `chosen` might be `['', '']`.{{{
    #
    # That happens if  you pass `--exit-0` to `fzf(1)`, or  if you press Enter
    # even though there's no entry to select.
    #
    # In that case, an error is given:
    #
    #     E684: List index out of range: 1
    #
    # It's often cleared immediately because we  feed `<C-L>` via a timer (but
    # can always be read in your `:messages`).  Anyway, let's avoid that.
    #}}}
    if chosen->len() < 3
        return
    endif

    var query: string = chosen[0]
    var expected_key: string = chosen[1]

    if expected_key == 'ctrl-q'
        var entries: list<string> = chosen[2 :]
            ->map((_, entry: string) =>
                entry->substitute('\(.*\)\t.*\t\(.*\)\t\(.*\)', '\2:\3:\1', ''))
        cgetexpr entries
        var title: string = ':FzGrep'
        if query != ''
            title ..= $' {query}'
        endif
        setqflist([], 'a', {title: title})
        return
    endif

    var [fname: string, lnum: string] = chosen[2]
        ->matchlist('\(^[^:]*\):\(\d\+\)')[1 : 2]

    var cmd: string = {
        ctrl-s: 'split',
        ctrl-v: 'vsplit',
        alt-T: 'tab split',
    }->get(expected_key, 'edit')

    execute $'{cmd} +{lnum} {fname}'
enddef
# }}}1
# Util {{{1
def InGitRepository(): bool # {{{2
    silent system('git status --short')
    return v:shell_error == 0
enddef
