vim9script

# Init {{{1

import 'lg.vim'

# Interface {{{1
export def Op(mode = '', type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(Op, [mode()])
        return 'g@'
    endif

    if !&l:modifiable
        return ''
    endif

    var [lnum1: number, lnum2: number] = GetRange('gq', mode)

    # If  `'formatprg'`  doesn't  invoke   `par(1)`,  but  something  else  like
    # `js-beautify`,  we should  let the  external  program do  its job  without
    # interfering.
    if GetFp() !~ '^par\s'
        execute $'silent normal! {lnum1}Ggq{lnum2}G'
        return ''
    endif

    var cml: string = GetCml(true)

    if HasToFormatList(lnum1)
        FormatList(lnum1, lnum2)
    else
        var kind_of_text: string = GetKindOfText(lnum1, lnum2)
        if kind_of_text == 'mixed'
            echo 'can''t format a mix of diagram and regular lines'
        elseif kind_of_text == 'diagram'
            if search('\s[┐┘]', 'nW', lnum2) > 0
                echo 'can''t format a diagram with branches on the right'
                return ''
            endif
            GqInDiagram(lnum1, lnum2)
        else
            Gq(lnum1, lnum2)
        endif
    endif
    return ''
enddef

export def RemoveDuplicateSpaces(type = ''): string #{{{2
    if !&l:modifiable
        return ''
    endif

    if type == ''
        &operatorfunc = RemoveDuplicateSpaces
        return 'g@'
    endif
    var range: string = $':{line("'[")},{line("']")}'
    execute $'{range}RemoveTabs'
    execute 'keepjumps keeppatterns '
        # `\xa0`: no-break space
        # `\u2002`: EN SPACE
        .. $'{range}substitute/\%([.?!]\@1<=  \S\)\@!\&[[:blank:]\xa0\u2002]\{{2,}}/ /gce'
    #                          ^----------------------^
    #                          preserve french spacing
    # https://en.wikipedia.org/wiki/History_of_sentence_spacing#French_and_English_spacing
    return ''
enddef

# }}}1
# Core {{{1
def Gq(arg_lnum1: number, arg_lnum2: number) #{{{2
    var lnum1: number = arg_lnum1
    var lnum2: number = arg_lnum2
    var was_commented: bool = IsCommented()

    # remove undesired hyphens
    RemoveHyphens(lnum1, lnum2, false)

    # If the text has a reference link with spaces, replace every possible space with ‘C-b’.{{{
    #
    # In a markdown file, if we stumble upon a reference link:
    #
    #     [some description][id]
    #
    # And if the  description, or the reference, contains  some spaces, `par(1)`
    # may break the link on two lines.
    # We don't want that.
    # So, we temporarily replace them with ‘C-b’.
    #}}}
    execute 'silent keepjumps keeppatterns'
        .. $' :{lnum1},{lnum2}'
        .. 'substitute/\[.\{-}\]\[\d\+\]/\=submatch(0)->tr(" ", "\<C-B>")/ge'
    # We do something similar to avoid breaking syntax highlighting in codespans.
    execute 'silent keepjumps keeppatterns'
        .. $' :{lnum1},{lnum2}'
        .. 'substitute/`\@1<!`[^`]\+``\@!/\=submatch(0)->tr(" ", "\<C-D>")/ge'
    # Same thing to preserve italics/bold styles.
    execute 'silent keepjumps keeppatterns'
        .. $' :{lnum1},{lnum2}'
        .. 'substitute/\*[^*`]\+\*/\=submatch(0)->tr(" ", "\<C-D>")/ge'

    # format the text-object
    try
        execute $'silent normal! {lnum1}Ggq{lnum2}G'
        lnum2 = line("']")
    # E20: Mark not set
    # TODO: Why does this error sometimes happen?{{{
    #
    # MRE:
    #
    #     $ vim -Nu NONE +'let &formatprg = "par -e" | eval ["1.2", "1.2"]->setline(1) | normal! gqj'
    #
    # What should we do when it's given?  Return?
    #}}}
    catch /^Vim\%((\a\+)\)\=:E20:/
        return
    endtry

    # `RemoveHyphens()` may have left some ‘C-a’s
    execute 'silent keepjumps keeppatterns'
        .. $' :{lnum1},{lnum2} substitute/\%x01\s*//ge'

    # Why?{{{
    #
    # Since we may have altered the  text after removing some ‘C-a’s, we
    # need  to re-format  it, to  be  sure that  `gq` has  done its  job
    # correctly, and that the operation is idempotent.
    #
    # Had we removed the hyphens before invoking `gq`, we would not need
    # to re-format.
    # But  removing them,  and the  newlines which  follow, BEFORE  `gq`
    # would alter the range.
    # I don't want to recompute the range.
    # It's easier to remove them AFTER `gq`, and re-format a second time.
    #}}}
    execute $'silent normal! {lnum1}Ggq{lnum2}G'
    lnum2 = line("']")

    # If the original text contained a reference link with spaces, replace every
    # possible ‘C-b’ with a space.
    execute 'silent keepjumps keeppatterns '
        .. $':{lnum1},{lnum2}'
        .. 'substitute/\[.\{-}\]\[\d\+\]/\=submatch(0)->tr("\<C-B>", " ")/ge'

    # Same thing if the original text contained a codespan, or an italics/bold style.
    execute 'silent keepjumps keeppatterns'
        .. $' :{lnum1},{lnum2}'
        .. 'substitute/`\@1<!`[^`]\+``\@!\|\*[^*]\+\*/\=submatch(0)->tr("\<C-D>", " ")/ge'

    # If the text was commented, make sure it's still commented.
    # Necessary if  we've pressed `gqq`  on a long commented  line which
    # has been split into several lines.
    if was_commented
        MakeSureProperlyCommented(lnum1, lnum2)
    endif

    # Remove possible superfluous spaces.{{{
    #
    # MRE: Press `gqq` on the following line in a `.conf` file.
    #
    #     # The log suggested that we re-set the "net.core.rmem_max" and "net.core.wmem_max" kernel parameter in `/etc/sysctl.conf`.
    #
    # It gives:
    #
    #       superfluous spaces
    #       vv
    #     #   The   log   suggested   that   we   re-set   the   "net.core.rmem_max"   and
    #     # "net.core.wmem_max" kernel parameter in `/etc/sysctl.conf`.
    #}}}
    var line: string = getline(lnum1)
    var pat: string = '^\s*' .. GetCml() .. '\s\zs\s\+\ze\S'
    if line =~ pat
        line
            ->substitute(pat, '', '')
            ->setline(lnum1)
        execute $'silent normal! {lnum1}Ggq{lnum2}G'
    endif
enddef

def GqInDiagram(arg_lnum1: number, arg_lnum2: number) #{{{2
    var lnum1: number = arg_lnum1
    var lnum2: number = arg_lnum2
    var cml: string = GetCml(true)
    var pos: list<number> = getcurpos()

    # Make sure 2 consecutive branches of a diagram are separated by an empty line:{{{
    #
    # Otherwise, if you have sth like this:
    #
    #     │ some long comment
    #     │         ┌ some long comment
    #
    # The formatting won't work as expected.
    # We need to make sure that all branches are separated:
    #
    #     │ some long comment
    #     │
    #     │         ┌ some long comment
    #}}}
    var g: number = 0
    while search('[┌└]', 'W') > 0 && g < 100
        ++g
        var l: number = line('.')
        # if the previous line is not an empty diagram line
        if getline(l - 1) !~ $'^\s*{cml}\s*│\s*$' && l <= lnum2 && l > lnum1
            # put one above
            var line: string = getline(l)
                ->substitute('\s*┌.*', '', '')
                ->substitute('└\zs.*', '', '')
                ->substitute('└$', '│', '')
            append(l - 1, line)
            ++lnum2
        endif
    endwhile

    # For lower diagrams, we need to put a bar in front of every line which has no diagram character:{{{
    #
    #     └ some comment
    #       some comment
    #       some comment
    # →
    #     └ some comment
    #     | some comment
    #     | some comment
    #}}}
    setpos('.', pos)
    g = 0
    while search('└', 'W', lnum2) > 0 && g <= 100
        ++g
        if GetCharAbove() !~ '[│├┤]'
            continue
        endif
        var pos_: list<number> = getcurpos()
        var gg: number = 0
        while GetCharBelow() == ' ' && GetCharAfter() == ' ' && gg <= 100
            ++gg
            normal! jr|
        endwhile
        setpos('.', pos_)
    endwhile

    # temporarily replace diagram characters with control characters
    execute printf('silent keepjumps keeppatterns :%d,%d substitute/[┌└]/\="│ " .. %s[submatch(0)]/e',
        lnum1, lnum2, {'┌': "\x01", '└': "\x02"})
    execute printf('silent keepjumps keeppatterns :%d,%d substitute/│/|/ge', lnum1, lnum2)

    # format the lines
    execute $'silent normal! {lnum1}Ggq{lnum2}G'

    # `gq` could have increased the number of lines, or reduced it.{{{
    #
    # There's no  guarantee that  `lnum2` still matches  the end  of the
    # original text.
    #}}}
    lnum2 = line("']")

    # restore diagram characters
    execute printf('silent keepjumps keeppatterns :%d,%d substitute/| \([\x01\x02]\)/\=%s[submatch(1)]/ge',
        lnum1, lnum2, {"\x01": '┌', "\x02": '└'})
    # pattern describing a bar preceded by only spaces or other bars
    var pat: string = $'\%(^\s*{cml}[ |]*\)\@<=|'
    execute printf('silent keepjumps keeppatterns :%d,%d substitute/%s/│/ge', lnum1, lnum2, pat)

    # For lower diagrams, there will be an undesired `│` below every `└`.
    # We need to remove them.
    setpos('.', pos)
    g = 0
    while search('└', 'W', lnum2) > 0 && g <= 100
        ++g
        var gg: number = 0
        while GetCharBelow() =~ '[│|]' && gg <= 100
            ++gg
            execute 'normal! jr '
        endwhile
    endwhile

    setpos('.', pos)
enddef

def FormatList(lnum1: number, lnum2: number) #{{{2
    var autoindent_save: bool = &l:autoindent
    var bufnr: number = bufnr('%')
    try
        # `'autoindent'` needs to be set so that `gw` can properly indent the formatted lines
        &l:autoindent = true
        execute $'silent normal! {lnum1}Ggw{lnum2}G'
    catch
        lg.Catch()
    finally
        setbufvar(bufnr, '&autoindent', autoindent_save)
    endtry
enddef

def MakeSureProperlyCommented(lnum1: number, lnum2: number) #{{{2
    for i: number in range(lnum1, lnum2)
        if !IsCommented(i)
            execute $'silent keepjumps keeppatterns :{i} CommentToggle'
        endif
    endfor
enddef

def RemoveHyphens( #{{{2
        lnum1: number,
        lnum2: number,
        split_paragraph: bool
        )
    var range: string = $':{lnum1},{lnum2}'

    # Replace soft hyphens which we sometimes copy from a pdf.
    # They are annoying because they mess up the display of nearby characters.
    execute 'silent keepjumps keeppatterns '
        .. $'{range} substitute/\%u00ad/-/ge'

    # pattern describing a hyphen breaking a word on two lines
    var pat: string = '[\u2010-]\ze\n\s*\S\+'
    # Replace every hyphen breaking a word on two lines, with a ‘C-a’.{{{
    #
    # We don't want them.  So, we mark them now, to remove them later.
    #}}}
    # Why don't you remove them right now?{{{
    #
    # We need to also remove the spaces which may come after on the next line.
    # Otherwise, a word like:
    #
    #     spec-
    #     ification
    #
    # ... could be transformed like this:
    #
    #     spec  ification
    #
    # At that  point, we would  have no way  to determine whether  2 consecutive
    # words are in fact the 2 parts of a single word which need to be merged.
    # So we need to remove the hyphen, the newline, and the spaces all at once.
    # But if we  do that now, we'll  alter the range, which will  cause the next
    # commands (`:join`, `gq`) from operating on the wrong lines.
    #}}}
    execute 'silent keepjumps keeppatterns '
        .. $'{range} substitute/{pat}' .. "/\x01/ge"

    if split_paragraph
        # In a markdown file, we could have a leading `>` in front of quoted lines.
        # The next  `:join` won't remove them.   We need to do  it manually, and
        # keep only the first one.
        # TODO: What happens if there are nested quotes?
        execute 'silent keepjumps keeppatterns :'
            .. (lnum1 + (lnum1 < lnum2 ? 1 : 0)) .. $',{lnum2}'
            .. ' substitute/^>//e'

        # join all the lines in a single one
        execute $'silent keepjumps {range} join'

        # Now that we've joined all the lines, remove every ‘C-a’.
        silent keepjumps keeppatterns substitute/\%x01\s*//ge
    endif
enddef
# }}}1
# Util {{{1
def GetCharAbove(): string #{{{2
    return (line('.') - 1)->getline()->matchstr('\%' .. virtcol('.', true)[0] .. 'v.')
enddef

def GetCharAfter(): string #{{{2
    return getline('.')->strpart(col('.') - 1)[1]
enddef

def GetCharBelow(): string #{{{2
    return (line('.') + 1)->getline()->matchstr('\%' .. virtcol('.', true)[0] .. 'v.')
enddef

def GetCml(with_equal_quantifier = false): string #{{{2
    if &l:commentstring == ''
        return ''
    endif
    var cml: string = &l:commentstring->matchstr('\S*\ze\s*%s')
    return with_equal_quantifier
        ? '\%(' .. '\V' .. escape(cml, '\') .. '\m' .. '\)\='
        : '\V' .. escape(cml, '\') .. '\m'
enddef

def GetFp(): string #{{{2
    return &l:formatprg == ''
        ? &g:formatprg
        : &l:formatprg
enddef

def GetKindOfText(lnum1: number, lnum2: number): string #{{{2
    var kind: string = getline(lnum1) =~ '[│┌└]'
        ? 'diagram'
        : 'normal'

    if lnum2 <= lnum1
        return kind
    endif

    for i: number in range(lnum1 + 1, lnum2)
        if getline(i) =~ '[│┌└]' && kind == 'normal'
        || getline(i) !~ '[│┌└]' && kind == 'diagram'
            return 'mixed'
        endif
    endfor
    return kind
enddef

def GetRange(for_who: string, mode: string): list<number> #{{{2
    var lnum1: number
    var lnum2: number

    if mode =~ "^[vV\<C-V>]$"
        [lnum1, lnum2] = [line("'<"), line("'>")]
        # Why not returning the previous addresses directly?{{{
        #
        # If we select  a diagram, we should exclude the  first/last line, if it
        # looks like this:
        #
        #     │    │
        #
        # Otherwise, `par(1)` will  remove this line, which makes  the diagram a
        # little ugly.
        #
        # And, if the first/last line looks like:
        #
        #     ┌──┤    ┌──┤
        #
        # The formatting is wrong.
        # So, in both cases, we should ignore those lines.
        #}}}
        var cml: string = GetCml(true)
        var pat: string = $'^\s*{cml}\%(\s*│\)\+\s*$'
        if getline(lnum1) =~ pat
            ++lnum1
        elseif getline(lnum2) =~ pat
            --lnum2
        elseif getline(lnum2) =~ '[├┤]'
            --lnum2
        elseif getline(lnum1) =~ '[├┤]'
            ++lnum1
        endif
        return [lnum1, lnum2]
    endif

    if for_who == 'gq'
        return [line("'["), line("']")]
    endif

    var firstline: number = line("'{")
    var lastline: number = line("'}")

    # get the address of the first line
    lnum1 = firstline == 1 && getline(1) =~ '\S'
        ? 1
        : firstline + 1

    # get the address of the last line of the paragraph
    lnum2 = getline(lastline) =~ '^\s*$'
        ? lastline - 1
        : lastline

    return [lnum1, lnum2]
enddef

def HasToFormatList(lnum1: number): bool #{{{2
    # Format sth like this:
    #    - the quick brown fox jumps over the lazy dog the quick brown fox jumps over the lazy dog
    #    - the quick brown fox jumps over the lazy dog the quick brown fox jumps over the lazy dog
    return getline(lnum1) =~ &l:formatlistpat && GetFp() =~ '^par\s'
enddef

def IsCommented(i = 0): bool #{{{2
    if &l:commentstring == ''
        return false
    endif
    var line: string = getline(i == 0 ? '.' : i)
    return line =~ '^\s*' .. GetCml()
enddef
