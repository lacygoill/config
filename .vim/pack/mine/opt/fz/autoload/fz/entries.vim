vim9script

import autoload '../fz.vim'

const ENTRY: dict<string> = {
    cheatkeys: '^[^[:blank:]#].*\%41c\S',
    markdown: '^#\+\s',
    navi: '^#\s',
    snippets: '^snippet\s',
}

# Interface {{{1
export def Fz() # {{{2
    if !ENTRY->has_key(&filetype)
        return
    endif

    fz.Run({
        options: [
            '--delimiter="\t"',
            '--with-nth=2..',
        ],
        sink: (chosen: string) => {
            var lnum: string = chosen->matchstr('^\d\+')
            execute $'normal! {lnum}G{&filetype == 'cheat' ? '41|' : ''}zMzvzz'
        },
        source: Entries(),
    })
enddef
# }}}1
# Core {{{1
def Entries(): list<string> # {{{2
    var source: list<string>
    for [lnum: number, line: string] in getline(1, '$')->items()
        if line =~ ENTRY[&filetype]
            source->add((lnum + 1) .. "\t" .. line)
        endif
    endfor

    if &filetype == 'markdown' || &filetype == 'navi'
        source->map((_, line: string) => line->substitute('\t\zs#\+\s\+', '', ''))
    elseif &filetype == 'snippets'
        source->map((_, line) => line->substitute('\t\zs[^"]*"\|".*', '', 'g'))
    endif

    return source
enddef
