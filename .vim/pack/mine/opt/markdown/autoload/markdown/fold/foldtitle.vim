vim9script

import autoload './foldexpr.vim'

export def Get(): string #{{{1
    var foldstartline: string = getline(v:foldstart)
    # get the desired level of indentation for the title
    var level: number = foldexpr.HeadingDepth(v:foldstart)
    var indent: string = repeat(' ', (level - 1) * 3)
    # remove noise
    var title: string = foldstartline->substitute('^#\+\s*\|`', '', 'g')
    if get(b:, 'foldtitle_full', false)
        var foldsize: number = v:foldend - v:foldstart
        var linecount: string = printf('%-6s', $'[{foldsize}]')
        return $'{indent}{foldsize > 1 ? linecount : ''}{title}'
    endif
    return $'{indent}{title}'
enddef
