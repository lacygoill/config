vim9script

const PATTERNS: list<string> = [
    # file path
    '^[./]\%(\f\| \)\+',

    # URL
    'https\=://\S\+',

    # past shell command in fish prompt
    '^٪ \zs.\{-}\ze\%($\|  \)',
    #                    ^^
    #           ignore "last command took 12 minutes" right prompt in fish

    # shell command printed as a tip{{{
    #
    # For example, our `doc` fish function might give such a tip:
    #
    #     tip: You can get a list of ... with: $ some command
    #                                            ^----------^
    #}}}
    '\$ \zs[-_. 0-9a-zA-Z]\+',
    # Package installation command, given  by the `command-not-found` script, when
    # we try  to execute a  command which  is provided by  a package which  is not
    # installed yet.
    'sudo apt install \S\+',

    #     Failed to start some.unit: Unit some.unit has a bad unit file setting.
    #     See user logs and 'systemctl --user status some.unit' for details.
    #                        ^-------------------------------^
    #     ...
    #
    #     See "systemctl --user status some.service" and "journalctl --user -xe" for details.
    #          ^----------------------------------^       ^-------------------^
    "'\\zs[^']\\+\\ze'",
    '"\zs[^"]\+\ze"'
]

const ALPHABET: string = 'fjdkslqm'
const BUF: number = bufnr('%')

var chosen_hint: string

def GetHintsColors(): list<string>
    var incsearch: dict<any> = hlget('IncSearch')[0]
    if incsearch.cterm->has_key('reverse')
            && incsearch.cterm.reverse
        return [incsearch.ctermbg, incsearch.ctermfg]
    endif
    return [incsearch.ctermfg, incsearch.ctermbg]
enddef
const [FG: string, BG: string] = GetHintsColors()
[{name: 'virtual_hints', ctermbg: BG, ctermfg: FG, cterm: {bold: 1}}]
    ->hlset()
prop_type_add('virtual_hints', {highlight: 'virtual_hints', bufnr: BUF})
prop_type_add('interesting', {highlight: 'Visual', bufnr: BUF})

var matches: list<dict<any>> = matchbufline(BUF, PATTERNS->join('\|'), 1, line('$'))

var hints: list<string>
if matches->len() <= ALPHABET->strcharlen()
    hints = ALPHABET->split('\zs')
else
    for char1: string in ALPHABET
        for char2: string in ALPHABET
            hints->add(char1 .. char2)
        endfor
    endfor
endif

var i: number = 0
for match: dict<any> in matches
    match.hint = hints[i]
    ++i
endfor

# Interface {{{1
export def Main() #{{{2
    if matches->len() == 0
        return
    endif

    # dim everything
    :$ Limelight

    foreach(matches, (_, match: dict<any>) =>
        Prop_add(match.lnum, match.byteidx, match.hint, match.text))

    [{
        group: 'UpdateHints',
        event: 'CmdlineChanged',
        pattern: '@',
        cmd: 'UpdateHints()',
        replace: true,
    }]->autocmd_add()

    nnoremap <buffer><nowait> f <ScriptCmd>input('hint: ')<CR>
enddef
#}}}1
# Core {{{1
def UpdateHints() #{{{2
    chosen_hint = getcmdline()

    i = matches
        ->indexof((_, match: dict<any>): bool => match.hint == chosen_hint)
    if i >= 0
        @+ = matches[i].text
        timer_start(10, (_) => execute('quitall!'))
        return
    endif

    prop_remove({type: 'virtual_hints', bufnr: BUF, all: true})
    prop_remove({type: 'interesting', bufnr: BUF, all: true})
    redraw

    foreach(matches, (_, match: dict<any>) => {
        if match.hint =~ '^\V' .. chosen_hint
            Prop_add(match.lnum, match.byteidx, match.hint, match.text)
        endif
    })
enddef
#}}}1
# Util {{{1
def Prop_add(lnum: number, byteidx: number, hint: string, text: string) #{{{2
    prop_add(lnum, byteidx + 1, {
        type: 'virtual_hints',
        text: hint,
        combine: false,
    })
    prop_add(lnum, byteidx + 1, {
        type: 'interesting',
        length: text->strlen(),
    })
    redraw
enddef
