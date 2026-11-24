vim9script

# Interface {{{1
export def Main(use_curfile: bool) #{{{2
    if use_curfile
        SetFt()
    else
        SplitWindow()
    endif

    DumpTermcap(use_curfile)
    SeparateTerminalKeysWithoutOptions()
    MoveKeynamesIntoInlineComments()
    AddAssignmentOperators()
    CommentSectionHeaders()
    AlignInlineComment()
    AddSetCommands()
    EscapeSpacesInOptionsValues()
    TrimTrailingWhitespace()
    TranslateSpecialKeys()
    SortLines()
    Fold()
    InstallMappings()

    # turn into Vim9 script
    ['vim9script', '']->append(0)
    if has('syntax_items')
        doautocmd Syntax
    endif

    # bang to  suppress error  when we  don't have our  autocmd which  creates a
    # missing directory
    silent! update
enddef
#}}}1
# Core {{{1
def SetFt() #{{{2
    if &filetype != 'vim'
        &filetype = 'vim'
    endif
enddef

def SplitWindow() #{{{2
    var tmp_file: string = tempname() .. '/termcap.vim'
    execute 'split ' .. tmp_file
enddef

def DumpTermcap(use_curfile: bool) #{{{2
    execute('set! termcap')->split('\n')->setline(1)
    # The bang  after silent is necessary  to suppress `E486` in  the GUI, where
    # there may be no `Terminal keys` section.
    search('Terminal codes')
    append('.', '')
    search('Terminal keys')
    append(line('.') - 1, '')
    append('.', '')
    silent keepjumps keeppatterns :% substitute/^ *//e
enddef

def SeparateTerminalKeysWithoutOptions() #{{{2
    # move terminal keys not associated to any terminal option at the end of the buffer
    silent! keepjumps keeppatterns :/Terminal keys/,$ global/^</move $
    # separate them from the terminal keys associated with a terminal option{{{
    #
    #     t_kP <PageUp>    ^[[5~ 
    #     <í>        ^[m
    #
    #     →
    #
    #     t_kP <PageUp>    ^[[5~ 
    #
    #     <í>        ^[m
    #}}}
    silent! :1/^<\%(.*# t_\S\S\)\@!/ put! _
enddef

def MoveKeynamesIntoInlineComments() #{{{2
    #     t_#2 <S-Home>    ^[[1;2H
    #     →
    #     <S-Home>    ^[[1;2H  # t_#2
    silent! keepjumps keeppatterns :/Terminal keys/,$ substitute/^\(t_\S\+ \+\)\(<.\{-1,}>\)\(.*\)/\2\3# \1/e
enddef

def AddAssignmentOperators() #{{{2
    # Only necessary for terminal keys (not codes):
    #
    #     <S-Home>    ^[[1;2H  # t_#2
    #     →
    #     <S-Home>=^[[1;2H  # t_#2
    silent! keepjumps keeppatterns :/Terminal keys/,$ substitute/^<.\{-1,}>\zs \+/=/e
enddef

def AlignInlineComment() #{{{2
# https://developer.ibm.com/tutorials/l-vim-script-2/#a-function-to-help-you-code

#     <S-Home>=^[[1;2H  # t_#2
#     <F4>=^[OS     # t_k4
#
#     →
#
#     <S-Home>=^[[1;2H # t_#2
#     <F4>=^[OS        # t_k4

    # locate block of code to be considered
    var firstline: number = search('# Terminal keys', 'n') + 1
    var lastline: number = search('^<.*\n\n\%>' .. firstline .. 'l', 'n')
    if lastline == 0
        lastline = line('$')
    endif
    if firstline <= 0 || lastline <= 0
        return
    endif

    # find the column at which the inline comments should be aligned
    var max_align_col: number
    for line: string in getline(firstline, lastline)
        # Does this line have an inline comment in it?
        var left_width: number = line->match('\s*#')

        # if so, track the maximal comment column
        if left_width >= 0
            max_align_col = [max_align_col, left_width]->max()
         endif
    endfor

    # to take into account the comment leader
    ++max_align_col

    # code needed to reformat lines so as to align inline comments
    var Formatter: func = (m: list<string>): string =>
        printf('%-*s%s', max_align_col, m[1], m[2])

    # reformat lines with inline comments aligned in the appropriate column
    for linenum: number in range(firstline, lastline)
        var oldline: string = getline(linenum)
        var newline: string = oldline->substitute('^\(^.\{-}\)\s*\(#\)', Formatter, '')
        newline->setline(linenum)
    endfor
enddef

def AddSetCommands() #{{{2
    silent keepjumps keeppatterns :% substitute/^\ze\%(t_\|<\)/set /e
enddef

def EscapeSpacesInOptionsValues() #{{{2
    #     set t_EI=^[[2 q
    #     →
    #     set t_EI=^[[2\ q
    #                  ^
    silent keepjumps keeppatterns :% substitute/\%(set.\{-}=.*[^#]\)\@<= [^# ]/\\&/ge
enddef

def TrimTrailingWhitespace() #{{{2
    silent! keepjumps keeppatterns :/Terminal keys/,$ substitute/ \+$//e
enddef

def TranslateSpecialKeys() #{{{2
    # translate caret notation of control characters
    Ref = (): string => eval('"' .. '\x' .. (submatch(1)->char2nr() - 64) .. '"')
    silent keepjumps keeppatterns :% substitute/\^\[/\="\<Esc>"/ge
    silent keepjumps keeppatterns :% substitute/\^\(\u\)/\=Ref()/ge
    silent keepjumps keeppatterns :% substitute/\^?/\="\x7f"/ge
    silent keepjumps keeppatterns :% substitute/\\\@1<!|/\\|/ge

    #     <á>=^[a    →    <M-a>=^[a
    silent keepjumps keeppatterns :% substitute/^set <\zs.\ze>=\e\(\l\)/M-\1/e
enddef
var Ref: func: string

def SortLines() #{{{2
    # sort terminal codes: easier to find a given terminal option name
    # sort terminal keys: useful later when vimdiff'ing the output with another one
    silent! keepjumps :1/Terminal codes/+1,/Terminal keys/-2 sort
    silent! keepjumps :1/Terminal keys/+2;/^$/-1 sort
    silent! keepjumps :1/Terminal keys//^$//^$/+1;$ sort
enddef

def CommentSectionHeaders() #{{{2
    #     --- Terminal codes ---    →    # Terminal codes
    #     --- Terminal keys ---     →    # Terminal keys
    silent keepjumps keeppatterns :% substitute/^--- Terminal \(\S*\).*/# Terminal \1/e
enddef

def Fold() #{{{2
    silent keepjumps keeppatterns :% substitute/^# .*\zs/\=' {{' .. '{1'/e
enddef

def InstallMappings() #{{{2
    # make sure `K` opens a help page (necessary if filetype detection is OFF)
    &l:keywordprg = ':help'
    nnoremap <buffer><expr><nowait> q reg_recording() != '' ? 'q' : '<ScriptCmd>quit!<CR>'
    # mapping to compare value on current line with the one in output of `:set! termcap`{{{
    #
    # Note that  `:filter` is able  to filter the “Terminal  codes” section,
    # but not the “Terminal keys” section.
    # So, no  matter the line  where you press  `!!`, you'll always  get the
    # whole “Terminal codes” section.
    # The  mapping is  still useful:  if you  press `!!`  on a  line in  the
    # “Terminal codes” section,  it will correctly filter out  all the other
    # terminal codes.
    #}}}
    nnoremap <buffer><nowait> !!
        \ <ScriptCmd>execute 'filter /' .. getline('.')->matchstr('t_[^=]*') .. '/ set! termcap'<CR>
    # open relevant help tag to get more info about the terminal option under the cursor
    nnoremap <buffer><nowait> <CR> <ScriptCmd>GetHelp()<CR>
    # get help about mappings
    nnoremap <buffer><nowait> g? <ScriptCmd>PrintHelp()<CR>
enddef

def GetHelp() #{{{2
    var tag: string = getline('.')->matchstr('\%(^set \|# \)\@4<=t_[^=]*')
    if tag != ''
        try
            execute "help '" .. tag
        # some terminal options have no help tags (e.g. `'t_FL'`)
        catch /^Vim\%((\a\+)\)\=:E149:/
            echohl ErrorMsg
            echomsg v:exception
            echohl NONE
        endtry
    else
        echo 'no help tag on this line'
    endif
enddef

def PrintHelp() #{{{2
    var help: list<string> =<< trim END
        Enter    open relevant help tag to get more info about the terminal option under the cursor
        !!       compare value on current line with the one in output of `:set! termcap`
        g?       print this help
    END
    echo help->join("\n")
enddef
