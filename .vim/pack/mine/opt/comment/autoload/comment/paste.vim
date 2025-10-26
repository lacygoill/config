vim9script

import autoload './util.vim'

# Interface {{{1
export def Main( #{{{2
    where: string,
    how: string,
    type = ''
): string

    if type == ''
        &operatorfunc = function(Main, [where, how])
        return 'g@l'
    endif

    var cnt: number = v:count1
    var view: dict<number> = winsaveview()
    # you can get a weird result if you paste some text containing a fold marker;
    # let's disable folding temporarily, to avoid any interference
    var foldenable_save: bool = &l:foldenable | &l:foldenable = false

    var start: number
    var end: number
    var change_pos: list<number>
    # In a markdown file, there're no comments.
    # However, it could still be useful to format the text as code output or quote.
    if &filetype == 'markdown'
        var is_quote: bool = indent('.') == 0
        Paste(where)
        change_pos = getpos("'[")
        start = line("'[")
        end = line("']")
        if is_quote
            :'[,'] CommentToggle
        else
            # Which alternatives could I use?{{{
            #
            #     var wrap_save: bool = &l:wrap
            #     var winid: number
            #     var bufnr: number
            #     try
            #         &l:wrap = false
            #         execute "normal! '[V']\<C-V>0o$A˜"
            #     finally
            #         if winbufnr(winid) == bufnr
            #             var tabnr: number
            #             var winnr: number
            #             [tabnr, winnr] = win_id2tabwin(winid)
            #             settabwinvar(tabnr, winnr, '&wrap', wrap_save)
            #         endif
            #     endtry
            #
            # ---
            #
            #     var reginfo: dict<any> = getreginfo(v:register)
            #     var contents: list<string> = get(reginfo, 'regcontents', [])
            #         ->map((_, v: string) => v .. '˜')
            #     deepcopy(reginfo)
            #         ->extend({regcontents: contents, regtype: 'l'})
            #         ->setreg(v:register)
            #
            #     ...
            #     Paste(where)
            #     ...
            #     setreg(v:register, reginfo)
            #}}}

            # Do *not* use this `normal! '[V']A˜`!{{{
            #
            # This sequence  of keys works  in an interactive usage,  because of
            # our custom mapping `x_A`, but  it would fail with `:normal!` (note
            # the bang).
            # It would  probably work with  `:normal` though, although  it would
            # still fail on a long wrapped line (see next comment).
            #}}}
            silent! keepjumps keeppatterns :'[,'] global/^/normal! A˜
            silent! keepjumps keeppatterns :'[,'] global/^˜$/ substitute/˜//
        endif
    else
        var l: string
        var r: string
        if &commentstring != ''
            [l, r] = util.GetCml()
            l = l->matchstr('\S*')
        else
            l = ''
        endif

        Paste(where)
        change_pos = getpos("'[")

        # some of the next commands may alter the change marks; save them now
        start = line("'[")
        end = line("']")
        var range: string = ':' .. start .. ',' .. end
        # comment
        execute range .. 'CommentToggle'
        # I don't like empty non-commented line in the middle of a multi-line comment.
        execute 'silent! keepjumps keeppatterns ' .. range .. 'global/^$/CommentEmptyLine()'
        # If `>cp` is pressed, increase the indentation of the text *after* the comment leader.{{{
        #
        # This lets us  paste some code and  highlight it as a  codeblock in one
        # single mapping.
        #}}}
        if how == '>'
            var pat: string = '^\s*'
                .. '\V' .. escape(l, '\/')
                .. '\m' .. '\zs\ze.*\S'
                #              ├─────┘
                #              └ don't add trailing whitespace on an empty commented line
            # Do *not* replace `4` with `&l:shiftwidth`.{{{
            #
            # We often press `>cp` on a comment codeblock.
            # Those are always  indented with 4 spaces after  the comment leader
            # (and the space which always needs to follow for readability).
            #
            # And  when we  do,  we usually  expect the  pasted  line to  become
            # a  part  of the  codeblock.   That  wouldn't  happen if  we  wrote
            # `&l:shiftwidth` and the latter was not 4 (e.g. it could be 2).
            #}}}
            var rep: string = repeat(' ', 4 * cnt)
            execute 'silent keepjumps keeppatterns ' .. range .. 'substitute/' .. pat .. '/' .. rep .. '/e'
        endif
    endif
    if how != '' && how != '>'
        execute 'normal! ' .. start .. 'G' .. how .. end .. 'G'
    endif
    &l:foldenable = foldenable_save
    winrestview(view)
    setpos('.', change_pos)
    search('\S', 'cW')

    return ''
enddef
#}}}1
# Core {{{1
def Paste(where: string) #{{{2
    # Make sure the next `]p` command puts  the text as if it was linewise, even
    # if in reality it's characterwise.
    getreginfo(v:register)
        ->extend({regtype: 'l'})
        ->setreg(v:register)
    execute 'normal! "' .. v:register .. where .. 'p'
enddef

def CommentEmptyLine() #{{{2
    var placeholder: string = "\<C-A>"
    var prev_line: string = getline(line('.') - 1)
    var [l: string, r: string] = util.GetCml()
    if prev_line->util.IsCommented(l, r)
        var prev_indent: string = prev_line->matchstr('^\s\+')
        placeholder = prev_indent .. placeholder
    endif
    setline('.', placeholder)
    CommentToggle
    # Don't execute `normal! ==`.{{{
    #
    # It might break the indentation.
    # For example, in a `navi` file, suppose you have this text:
    #
    #     command
    #         # comment
    #
    # And  you  press `""cp`  (while  on  the  commented  line) to  paste  the
    # clipboard which contains 3 lines: `['a', '', 'b']`.
    #
    # If you  re-indent, the  indent level  of the  empty commented  line will
    # unexpectedly be 0 instead of 4.
    #}}}
    substitute/\s*\%x01//e
    # FIXME: `:debug normal "a>cp` under indented line
enddef
