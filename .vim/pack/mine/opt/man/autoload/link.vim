vim9script

# Interface {{{1
export def Main() #{{{2
    var curline: string = getline('.')
    var man_page: string = expand('%:p')->matchstr('//\zs[^(]*')
    # Warning: the section is not necessarily a number.
    # For example, it can be `3posix`.
    var section: string = expand('%:p')
        ->matchstr('//[^(]*(\zs[^)]*\ze)')
    if section != '1'
        man_page = $'{section} {man_page}'
    endif

    var section_heading: string
    var sub_heading: string

    # special case: the cursor is on a section heading
    if curline =~ '^\S'
        section_heading = curline
        printf('`man %s /%s`', man_page, section_heading)
            ->SetRegister()
        return
    # special case: the cursor is on a sub heading
    elseif curline =~ '^\s\s\s\S'
        section_heading = search('^\S', 'bncW')->getline()
        sub_heading = curline->trim()
        printf('`man %s /%s/;/%s`', man_page, section_heading, sub_heading)
            ->SetRegister()
        return
    endif

    var curword: string = expand('<cword>')
    var lnum: number = search('^\S', 'bncW')
    if lnum <= 1
        return
    endif
    section_heading = lnum->getline()
    sub_heading = search('^\s\s\s\S', 'bncW', lnum + 1)
        ->getline()
        ->trim()
    if sub_heading->empty()
        printf('`man %s /%s/;/%s`', man_page, section_heading, curword)
            ->SetRegister()
    else
        printf('`man %s /%s/;/%s/;/%s`', man_page, section_heading, sub_heading, curword)
            ->SetRegister()
    endif
enddef
#}}}1
# Core {{{1
def SetRegister(line: string) #{{{2
    setreg('d', line)
    echowindow line
enddef
