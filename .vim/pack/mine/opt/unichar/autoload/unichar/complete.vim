vim9script

import autoload './Session.vim'
import autoload 'fz.vim'

# sets the color for the glyph of a unicode character
const COLOR: number = 30

# Interface {{{1
export def Fuzzy() #{{{2
    if fuzzy_source == []
        SetFuzzySource()
    endif
    fz.Run({
        source: fuzzy_source,
        options: ['--ansi', '--nth=2..', '--tiebreak=index', '--multi'],
        sink: InjectUnicodeCharacter,
    })
enddef

var fuzzy_source: list<string>
#}}}1
# Core {{{1
def Translate(lists: list<list<string>>): list<list<string>> #{{{2
    for list: list<string> in lists
        list[0] = eval('"\U' .. printf('%x', list[0]->str2nr()) .. '"')
    endfor
    return lists
enddef

def InjectUnicodeCharacter(line: string) #{{{2
    feedkeys((col('.') >= col('$') - 1 ? 'a' : 'i') .. line[0], 'in')
enddef

def SetFuzzySource() #{{{2
    fuzzy_source = Session.Dict()
        ->items()
        ->Translate()
        # Some weird unicode characters can prevent us from accessing a match in the fzf window.{{{
        #
        # For example, search for `single`, then press `C-p` to visit all matches.
        # You  won't  be  able  to  finish, because  eventually,  `c6`  will  be
        # automatically appended to the command-line:
        #
        #     single6c
        #           ^^
        #
        # In this example, I think the culprit is `SINGLE CHARACTER INTRODUCER`.
        #
        # BTW, this is probably a bug in st:
        # https://github.com/tmux/tmux/issues/2124#issuecomment-601301882
        #
        # ---
        #
        # Anyway,  if a character  is not printable, I  doubt I'll ever  want to
        # insert it.
        #}}}
        ->filter((_, v: list<string>): bool => v[0] !~ '[^[:print:]]')
        ->mapnew((_, v: list<string>): string =>
            "\x1b[38;5;" .. COLOR .. 'm' .. v[0] .. "\x1b[0m\<Tab>" .. v[1])
enddef
#}}}1
