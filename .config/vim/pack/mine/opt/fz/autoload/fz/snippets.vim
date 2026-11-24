vim9script

import autoload '../fz.vim'

# Init {{{1

const DELIMITER: string = "\u00a0"
const SNIPPETS_DIR: string = globpath(&runtimepath, 'UltiSnips')

var BAT_SUPPORTED_LANGUAGES: list<string>
if executable('bat')
    BAT_SUPPORTED_LANGUAGES = systemlist('bat --list-languages')
else
    echomsg 'fz.vim: snippets: missing bat(1) dependency; cannot highlight code in preview window'
endif

# Interface {{{1
export def Fz() # {{{2
    var source: list<string> = UltiSnips#SnippetsInCurrentScope()
        ->items()
        ->map((_, item: list<string>) => item[1] .. DELIMITER .. item[0])
        #                                ^-----^                 ^-----^
        #                              description               trigger

    # If some snippets  start with a "tag" (e.g. `weechat:`  in Python files),
    # set the initial query so that they're all ignored (e.g. `!^weechat:`).
    #
    # Rationale: It might  help reduce  noise.  It  also exposes  all possible
    # tags, which  is useful to narrow  down snippets (e.g. in  an `sshconfig`
    # file, if  you are only  interested in  snippets with the  `client:` tag,
    # remove the bang from `!^client:` in the query).
    var tags: list<string> = source
        ->copy()
        ->map((_, desc: string) => desc->matchstr('^\%(\w\|-\)\+\ze:'))
        ->filter((_, tag: string): bool => tag != '')
        ->sort()
        ->uniq()
    var no_tags: string = tags
        ->map((_, tag: string) => $'!^{tag}:')
        ->join()

    var highlight: string
    # `bat(1)` doesn't support all languages.  For example, it doesn't support `sed(1)`.
    if BAT_SUPPORTED_LANGUAGES->match($'^\c[^:]*\<{&filetype}\>[^:]*:') >= 0
        highlight = $'| bat --color=always --language={&filetype}'
    endif
    fz.Run({
        options: [
            $'--delimiter={DELIMITER}',
            # `{2}` = tab trigger
            '--preview="sed -n ''/^snippet {2} /,/endsnippet/ { /^\(end\)\?snippet/d ; p }'''
            .. $' {SNIPPETS_DIR}/{&filetype}.snippets {highlight}"',
            $'--prompt="Snippets {$FZF_PROMPT}"',
            $'--query="{no_tags} "',
            # we ignore the tab trigger, which can be a meaningless abbreviation
            '--with-nth=1',
        ],
        sink: Sink,
        source: source,
    })
enddef
# }}}1
# Core {{{1
def Sink(chosen: string) # {{{2
    var [_, trigger: string] = chosen
        ->split(DELIMITER)

    var keys: string = 'a' .. trigger
        # open possible folds
        # Alternatively, you could use `normal! ^Ozv` after `feedkeys()`.{{{
        #
        # But in that case, you'll need to delay via a timer.
        #
        # Whatever  you  do,  make  sure  that an  undesirable  space  is  not
        # sometimes inserted.  Make a test in  a C file, using the snippet for
        # a  `switch` statement,  while  the current  line  is indented  (e.g.
        # inside a function).
        # }}}
        .. "\<C-O>zv"
    feedkeys(keys)
enddef
