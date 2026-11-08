vim9script

import autoload '../fz.vim'
import autoload '../fz/util.vim'

const MAX_PROMPT_LENGTH: number = &columns - 20

const FZF_OPTS: list<string> = systemlist('fish --command="complete --do-complete ''fzf -''" | awk ''{ print $1 }''')
var FindCmd: string

# Interface {{{1
export def Files(..._args: list<any>) # {{{2
    #     command                           | args
    #     ----------------------------------------
    #     :FZ                              | []
    #     :FZ ~                            | ['~']
    #     :FZ --reverse --info=inline /tmp | ['--reverse', '--info=inline', '/tmp']
    var args: list<string> = copy(_args)

    for arg: string in args
        if arg =~ '^-'
                && FZF_OPTS->index(arg->substitute('=[^=]*$', '', '')) == -1
                || arg !~ '^-'
                && ! arg
                ->util.Expand()
                ->isdirectory()
            # Let's be consistent with `fzf(1)`'s error message:
            #
            #     $ fzf --invalid
            #     unknown option: --invalid
            printf('unknown option: %s', arg)->util.Error()
            return
        endif
    endfor

    # Set `spec.dir` and `spec.options` (containing at least `--prompt`).{{{
    #
    #     :FZ
    #     spec = {
    #               assuming Vim's CWD is $HOME
    #               v-------v
    #         dir: '/home/lgc'
    #         options: ['--prompt ~/']
    #     }
    #
    #     :FZ ~
    #     spec = {
    #         dir: '/home/lgc/'
    #         options: ['--prompt /home/lgc/'],
    #     }
    #
    #     :FZ --reverse --info=inline /tmp
    #     spec = {
    #         dir: '/tmp/'
    #         options: ['--reverse', '--info=inline', '--prompt /tmp/'],
    #     }
    #}}}
    var spec: dict<any>
    if len(args) > 0
            && args[-1]
            ->util.Expand()
            ->isdirectory()
        spec.dir = remove(args, -1)
            ->util.Expand()
            ->trim('/', 2)
    else
        spec.dir = getcwd()
    endif

    var prompt: string = spec.dir
        # necessary if `spec.dir` contains a space
        ->fnameescape()
        ->fnamemodify(':~:.')
        ->pathshorten()
        # an unbalanced quote  would cause the final `fzf(1)`  command to give
        # an error
        ->util.Escape('[''"]')
    if prompt !~ '/$'
        prompt ..= '/'
    endif
    if strwidth(prompt) > MAX_PROMPT_LENGTH
        prompt = '> '
    endif
    spec.options = args->extend(['--multi', $'--prompt="{prompt} {$FZF_PROMPT}"'])

    if FindCmd == ''
        FindCmd = GetFindCmd(spec.dir)
    endif
    spec.source = FindCmd

    fz.Run(spec)
enddef
# }}}1
# Core {{{1
def GetFindCmd(cwd: string): string #{{{2
    # How slow is `find(1)`?{{{
    #
    # As an  example, currently,  `find(1)` finds around  300K entries  in our
    # `$HOME`.  It needs around 5s:
    #
    #     $ find ... | wc -l
    #
    # Note that – when testing –  it's important to redirect the output of
    # `find(1)`  to  something else  than  the  terminal;  hence the  pipe  to
    # `$ wc -l` in the previous command.
    # The terminal would add some overhead  to regularly update the screen and
    # show `find(1)`'s output.   Besides, most (all?) terminals  can't keep up
    # with a command which  has a fast output; i.e. they  need to drop *a lot*
    # of lines when displaying the output.
    #}}}

    # split before any comma which is not preceded by an odd number of backslashes
    var tokens: list<string> = split(&wildignore, '\%(\\\@1<!\\\%(\\\\\)*\\\@!\)\@<!,')

    # ignore files whose *directory* is present in `'wildignore'` (e.g. `*/build/*`)
    var by_directory: string = tokens
        ->copy()
        ->filter((_, v: string): bool => v =~ '/')
        ->map((_, v: string) =>
            '-ipath '
            # Why replacing the current working directory with a dot?{{{
            #
            #     $ mkdir -p /tmp/test \
            #         && cd /tmp/test \
            #         && touch file{1,2,3} \
            #         && mkdir ignore \
            #         && touch ignore/file{1,2,3}
            #
            #                          ✘
            #                      v-------v
            #     $ find . -ipath '/tmp/test/ignore/*' -o -type f -print
            #     ./file2
            #     ./file1
            #     ./ignore/file2
            #     ./ignore/file1
            #     ./ignore/file3
            #     ./file3
            #
            #                      ✔
            #                      v
            #     $ find . -ipath './ignore/*' -o -type f -print
            #     ./file2
            #     ./file1
            #     ./file3
            #}}}
            .. v
            ->substitute('^\V' .. escape(cwd, '\') .. '/', './', '')
            ->shellescape()
        )->join(' -o ')
    by_directory = $'\( {by_directory} -o -name ".*" \) -prune -o'
    #                                  ^-----------^
    #                                  also ignore hidden directories

    # ignore files whose *name* is present in `'wildignore'` (e.g. `tags`)
    var by_name: string = tokens
        ->copy()
        ->filter((_, v: string): bool => v !~ '[/*]')
        ->map((_, v: string) => '-iname ' .. shellescape(v))
        ->join(' -o ')
    by_name = $'\! \( {by_name} -o -name ".*" \)'
    #                           ^-----------^
    #                           also ignore hidden files

    # ignore files whose *extension* is present in `'wildignore'` (e.g. `*.mp3`)
    var by_extension: string = tokens
        ->copy()
        ->filter((_, v: string): bool => v =~ '\*' && v !~ '/')
        ->map((_, v: string) => '-iname ' .. shellescape(v))
        ->join(' -o ')
    by_extension = $'\! \( {by_extension} \)'

    return printf('find . -mindepth 1 %s %s %s -type f -print 2>/dev/null',
        by_directory, by_name, by_extension)
enddef
