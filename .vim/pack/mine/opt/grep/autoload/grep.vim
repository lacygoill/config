vim9script

import 'lg.vim'

# Init {{{1

#     # in fish
#     $ complete --do-complete 'grep -' | awk '{ print $1 }' | sed '/=$\|colour/d'
#
# NOTE: `--no-ignore-case` is missing from the output of the previous command.
const COMPLETIONS: list<string> =<< trim END
    -A
    -a
    -B
    -b
    -C
    -c
    -D
    -d
    -E
    -e
    -F
    -f
    -G
    -H
    -h
    -I
    -i
    -L
    -l
    -m
    -n
    -o
    -P
    -q
    -R
    -r
    -s
    -T
    -U
    -u
    -V
    -v
    -w
    -x
    -Z
    -z
    --after-context
    --basic-regexp
    --before-context
    --binary
    --binary-files
    --byte-offset
    --color
    --context
    --count
    --dereference-recursive
    --devices
    --directories
    --exclude
    --exclude-dir
    --exclude-from
    --extended-regexp
    --file
    --files-without-match
    --files-with-matches
    --fixed-strings
    --group-separator
    --help
    --ignore-case
    --include
    --initial-tab
    --invert-match
    --label
    --line-buffered
    --line-number
    --line-regexp
    --max-count
    --mmap
    --no-filename
    --no-group-separator
    --no-ignore-case
    --no-messages
    --null
    --null-data
    --only-matching
    --perl-regexp
    --quiet
    --recursive
    --regexp
    --silent
    --text
    --unix-byte-offsets
    --version
    --with-filename
    --word-regexp
END

# Interface {{{1
export def Main(args: string) # {{{2
    if getcwd() == $HOME
        Error($'{$HOME} is too big; try from a smaller directory')
        return
    endif

    var output: dict<any> = Run(args)
    if output->empty()
        return
    endif

    # Problem: `getqflist()` can be too slow if we find too many matches.{{{
    #
    # `getqflist()` takes  more time to  parse the lines and  produce quickfix
    # entries, than `systemlist()`  does to run the shell  command which finds
    # the matches.
    #
    # MRE:
    #
    #     :Time g:lines = systemlist('locate test')
    #     0.454 seconds to run :g:lines = systemlist('locate test')
    #
    #     :echo g:lines->len()
    #     26782
    #
    #     :Time getqflist({lines: g:lines, efm: '%f'})
    #     26.253 seconds to run :getqflist({lines: g:lines, efm: '%f'})
    #     ^----^
    #
    # This makes Vim hang way too long, and consume too much CPU/memory.
    #}}}
    # Solution: Bail out beyond an arbitrary threshold.{{{
    #
    # If you  find more than a  thousand matches, you probably  gave a pattern
    # which is too broad anyway.
    #}}}
    if output.lines->len() > 1'000
        Error('too many matches')
        return
    endif

    silent var items: list<dict<any>> = getqflist({
        lines: output.lines,
        efm: '%f:%l:%c:%m'
    }).items
    setqflist([], ' ', {items: items, title: output.cmd})
    doautocmd <nomodeline> QuickFixCmdPost cwindow
enddef

export def Complete(..._): string # {{{2
    return COMPLETIONS->join("\n")
enddef

export def Operator(type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(lg.Opfunc, [{funcname: Operator}])
        return 'g@'
    endif

    if type == 'char'
        normal! `[v`]y
    # `git-grep(1)` is line-oriented (no multiline pattern).
    elseif type == 'line' || type == 'block' || type == 'char' && @" =~ "\n"
        return ''
    endif

    # If the text starts with `-`, `git-grep(1)` might wrongly interpret it as
    # an option.  We need to tell it that it's not.
    #     vvv
    Main('-- ' .. getreg('"')->shellescape())

    return ''
enddef
# }}}1
# Core {{{1
export def Run(args: string): dict<any> # {{{2
    # We `export`  this function  because we  need it  for `:FzGrep`  which is
    # installed in a different plugin.

    var opts_regex: string = '\%(--\=\w\%(\w\|-\)*\s*\)*\%(--\s\+\)\='
    if args =~ $'^{opts_regex}\s*$'
        Error('missing pattern')
        return {}
    endif

    var cmd: string = InGitRepository()
        ? $'git grep --line-number --column {args}'
        : $'grepc {args}'
    var lines: list<string> = systemlist(cmd)
    if lines->empty()
            # `grep(1)` exits with the status code  2 if it didn't have enough
            # permissions to open a file/directory.  That doesn't mean that it
            # failed to match anything.
            || cmd =~ '^grep' && v:shell_error == 1
            || cmd =~ '^git' && v:shell_error != 0
        Error('pattern not found')
        return {}
    endif

    return {
        cmd: cmd,
        lines: lines,
    }
enddef
# }}}1
# Util {{{1
def Error(msg: string) # {{{2
    echohl ErrorMsg
    echomsg msg
    echohl NONE
enddef

def InGitRepository(): bool # {{{2
    silent system('git status --short')
    return v:shell_error == 0
enddef
