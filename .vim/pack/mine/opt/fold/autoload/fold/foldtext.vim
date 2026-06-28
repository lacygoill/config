vim9script

# Don't give an error if we don't have the markdown plugin.
# Could happen while we're debugging an issue.
silent! import autoload 'markdown/fold/foldexpr.vim'

export def Get(): string #{{{1
    var foldstartline: string = getline(v:foldstart)
    var indent: string
    var level: number
    # get the desired level of indentation for the title
    if get(b:, 'title_like_in_markdown', false)
        if exists_compiled('*foldexpr.HeadingDepth')
            level = foldexpr.HeadingDepth(v:foldstart)
            indent = repeat(' ', (level - 1) * 3)
        endif
    else
        indent = foldstartline =~ '{{\%x7b\d\+\s*$'
            ?     repeat(' ', (v:foldlevel - 1) * 3)
            :     foldstartline->matchstr('^\s*')
    endif

    # If you don't care about html and css, you could probably simplify the code
    # of this function, and get rid of `cml_right`.
    var cml_left: string
    var cml_right: string
    if &filetype == 'vim'
        cml_left = '["#]'
        cml_right = '\V\m'
    else
        cml_left = '\V' .. &commentstring->matchstr('\S*\ze\s*%s')->escape('\') .. '\m'
        cml_right = '\V' .. &commentstring->matchstr('.*%s\s*\zs.*')->escape('\') .. '\m'
    endif

    # remove comment leader
    # Why 2 spaces in the bracket expression?{{{
    #
    # The first is a space, the other is a no-break space.
    # We sometimes use the latter when we want the title to be indented compared
    # to the title of the previous fold (outside markdown).
    # This  can be  useful to  prevent  the title  from being  highlighted as  a
    # codeblock.
    #}}}
    var pat: string = '^\s*' .. cml_left .. '[  \t]\='
    # remove fold markers
    if cml_right == '\V\m'
        pat ..= '\|\s*\%(' .. cml_left .. '\)\=\s*{{\%x7b\d*\s*$'
    else
         pat ..= '\|\s*' .. cml_right .. '\s*' .. cml_left .. '\s*{{\%x7b\d*\s*' .. cml_right .. '\s*$'
    endif

    # we often use backticks for codespans, but a codespan's highlighting is not
    # visible in a fold title, so backticks are just noise; remove them
    pat ..= '\|`'

    var title: string = foldstartline->substitute(pat, '', 'g')

    # remove filetype specific noise
    if get(b:, 'title_like_in_markdown', false)
        title = foldstartline->substitute('^[-=#]\+\s*', '', '')
    elseif &filetype == 'bash'
        title = title->substitute('^\s*function\s\+\(.*\)\s*\%({\|(\)', '\1', '')
    elseif &filetype == 'diff'
        title = title->substitute('diff --git a/\| b/.*', '', 'g')
    elseif &filetype == 'fish'
        title = title
            ->substitute('^function\s.\{-}\zs\%(-[de]\|--argument-names\|--description\|--no-scope-shadowing\|--on-event\)\>.*', '', '')
            ->substitute('^function\s\+', '', '')
    elseif &filetype == 'lua'
        title = title
            ->substitute('^\C\%(\s*local\s\+\)\=function\s\+\(\%(\w\+\|\.\)\+\).*', '\1', '')
            #     mymodule.myfunc = function(param)
            #                    ^----------------^
            ->substitute( '\s*=\s*function([^)]*)', '', '')
    elseif &filetype == 'python'
        if title =~ '^def\s'
            title = title->matchstr('^def\s\+\zs[^[:blank:](]*')
        endif
    elseif &filetype == 'vim'
        pat = '^\s*\%(fu\%[nction]\|\%(export\s\+\)\=def\)!\='
            # ignore `aaa#bbb#` in `aaa#bbb#func()`
            .. ' \%(.*#\)\='
            # capture the function name
            .. '\(.\{-}\)'
            # but not the function arguments
            .. '(.*'
        title = title->substitute(pat, '\1', '')
    endif

    if get(b:, 'foldtitle_full', false)
        var foldsize: number = v:foldend - v:foldstart
        var linecount: string = printf('%-6s', $'[{foldsize}]')
        # `foldsize > 0`: the size might be `0` when we fold the output of `$ ps --forest`.{{{
        #
        # Even  if  we  set  `'foldminlines'`  to  `1`  (see  our  comment  in
        # `autoload/fold/adhoc.vim`).  If  that happens, we don't  want to see
        # `[0]` when we toggle the fold  sizes.  Actually, it's helpful not to
        # print that info,  to spot the "real" folds (i.e.  the ones which are
        # hiding something).
        #}}}
        return $'{indent}{foldsize > 0 ? linecount : ''}{title}'
    endif
    return $'{indent}{title}'
enddef
