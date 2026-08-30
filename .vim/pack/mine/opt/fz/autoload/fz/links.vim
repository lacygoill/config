vim9script

import autoload '../fz.vim'

# paths (files or URLs) displayed on the screen

# TEST:
#
# https://unix.stackexchange.com/
# ~/.vim/vimrc
# ~/.vim/vimrc line 123

# Config {{{1

const URL: string = '\C\%(https\=\|ftps\=\|www\)://\S\+'

# Interface {{{1
export def Fz() #{{{2
    var lines: string = Getlines()
    var paths: list<string> = ExtractPaths(lines)
    var urls: list<string> = copy(paths)
        ->filter((_, v: string): bool => v =~ URL)
    var paths_with_lnum: list<string> = copy(paths)
        ->filter((_, v: string): bool => v !~ URL && v =~ '\s\+line\s\+\d\+$')
    var paths_without_lnum: list<string> = copy(paths)
        ->filter((_, v: string): bool => v !~ URL && v =~ '\%\(\s\+line\s\+\d\+\)\@<!$')
    AlignFields(paths_with_lnum)
    var maxwidth: number = (urls + paths_with_lnum + paths_without_lnum)
        ->copy()
        ->map((_, v: string): number => strcharlen(v))
        ->max()
    var source: list<string> = urls
        + paths_with_lnum
        + paths_without_lnum
    if empty(source)
        return
    endif
    fz.Run({
        options: [
            '--expect=ctrl-s,ctrl-v,alt-T',
            $'--prompt="Visible Links {$FZF_PROMPT}"'
        ],
        sinklist: Open,
        source: source,
    })
enddef
# }}}1
# Core {{{1
def Getlines(): string #{{{2
    var lines: list<string>
    var line: list<string>
    for row: number in range(1, &lines)
        line = []
        for col: number in range(1, &columns)
            line->add(screenstring(row, col))
        endfor
        lines->add(line->join(''))
    endfor
    return lines->join("\n")
enddef

def ExtractPaths(lines: string): list<string> #{{{2
    var paths: list<string>
    var pat: string = URL .. '\|\f\+\%(\s\+line\s\+\d\+\)\='
    var Rep: func = (m: list<string>): string =>
        paths->add(m[0])->string()
    # a side-effect of this substitution is to invoke `add()` to populate `paths`
    lines->substitute(pat, Rep, 'g')
    paths
        ->filter((_, v: string): bool =>
            v =~ '^' .. URL .. '$'
            ||
            v =~ '/'
            &&
            v->substitute('\s\+line\s\+\d\+$', '', '')
            ->expand()
            ->filereadable())
        # for `markdownAutomaticLink`
        ->map((_, v: string): string => v->trim('>', 2))
        ->uniq()
    return paths
enddef

def AlignFields(paths: list<string>) #{{{2
    var path_width: number = paths
        ->copy()
        ->map((_, v: string): number => strcharlen(v))
        ->max()
    var lnum_width: number = paths
        ->copy()
        ->map((_, v: string): number =>
            v->matchstr('\s\+line\s\+\zs\d\+$')->strcharlen())
        ->max()
    paths->map((_, v: string) => Aligned(v, path_width, lnum_width))
enddef

def Aligned( #{{{2
        path: string,
        path_width: number,
        lnum_width: number
        ): string

    var matchlist: list<string> = matchlist(path, '\(.*\)\s\+line\s\+\(\d\+\)$')
    var actualpath: string = matchlist[1]
    var lnum: number = matchlist[2]->str2nr()
    return printf('%-*s line %*d', path_width, actualpath, lnum_width, lnum)
enddef

def Open(choice: list<string>) #{{{2
    var opening_key: string = choice[0]
    var what: string = choice[1]

    var pat: string = '\(.\{-}\)\%(\s\+line\s\+\(\d\+\)\)\=$'
    var matchlist: list<string> = matchlist(what, pat)
    var fpath: string = matchlist[1]
    var lnum: string = matchlist[2]
    if what =~ '^' .. URL .. '$'
        silent! system('xdg-open ' .. what)
        if v:shell_error != 0
            echomsg 'could not open URL: ' .. what
        endif
    else
        var opening_cmd: string = get({
            ctrl-s: 'split',
            ctrl-v: 'vsplit',
            alt-T: 'tabedit'
        }, opening_key, 'edit')
        # Alternative:{{{
        #
        #     execute $'{opening_cmd} {fpath}'
        #     execute printf('autocmd SafeState * ++once keepjumps normal! %szvzz',
        #         empty(lnum) ? '' : lnum .. 'G')
        # }}}
        execute printf($'{opening_cmd} +execute\ "keepjumps\ normal!\ %szvzz" %s',
            !empty(lnum) ? lnum .. 'G' : '', fpath)
    endif
enddef
