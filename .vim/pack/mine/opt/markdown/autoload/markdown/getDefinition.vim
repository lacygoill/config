vim9script

export def Main()
    # Special  Case: We're  in  some  source  code file  (C,  python,  ...),  in
    # a  `code/`  directory  of one  of  our  wikis,  and  the cursor  is  on  a
    # non-commented line.  We want the builtin `gd` command to be executed.
    if &filetype != 'markdown'
            && synstack('.', col('.'))
            ->indexof((_, id: number): bool => id->synIDattr('name') =~ '\ccomment') == -1
        try
            normal! gd
        # E349: No identifier under cursor
        catch /^Vim\%((\a\+)\)\=:E349:/
            echohl ErrorMsg
            echomsg v:exception
            echohl NONE
        endtry
        return
    endif

    var word: string
    if mode() =~ "^[vV\<C-V>]$"
        normal! y
        word = @"
    else
        word = expand('<cWORD>')
    endif
    word = word
        ->substitute('[[(“]\|[])”].*\|[[:punct:]s]\{,2}$\|^[[:punct:]]', '', 'g')

    var cwd: string = getcwd()
    var pat: string

    # Handle the case where we press `gd` on a verb conjugated to past tense.
    # For example, if  the word under the  cursor is "fetched", we  want to look
    # for "fetch" in the glossary.
    if word =~ '^\<\a\+ed\>$'
        word = word->substitute('ed$', '', '')
    endif
    pat = '^#.*\c\V' .. word->escape('\')

    var glossary_file: string = findfile('Glossary.md', '.;')
    if !glossary_file->filereadable()
        # The CWD might be wrongly set.
        # Try to fix it by triggering our vim-cwd autocmd.
        var pos: list<number> = getcurpos()
        doautocmd <nomodeline> BufWinEnter
        setpos('.', pos)
        cwd = getcwd()

        glossary_file = findfile('Glossary.md', '.;')
        if !glossary_file->filereadable()
            echo 'cannot find "Glossary.md" file'
            return
        endif
    endif
    if glossary_file->readfile()->match(pat) == -1
        echo $'no definition for "{word}"'
        return
    endif

    if expand('%:p:t') != 'Glossary.md'
        var width: number = &columns * 2 / 5
        execute $':{width} vsplit {glossary_file}'
    endif

    var items: list<dict<any>> = getline(1, '$')
        ->map((lnum: number, line: string): dict<any> =>
                ({bufnr: bufnr('%'), lnum: lnum + 1, text: line}))
        ->filter((_, d: dict<any>): bool => d.text =~ pat)
    # erase possible previous 'no definition for' message
    redraw!
    setloclist(0, [], ' ', {items: items, title: word})
    doautocmd <nomodeline> QuickFixCmdPost lwindow

    if &filetype != 'qf'
        return
    endif

    lfirst
    normal! zMzvzt
    if items->len() == 1
        lclose
    endif
enddef
