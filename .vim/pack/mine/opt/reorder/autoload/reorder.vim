vim9script

import 'lg.vim'

# Interface {{{1
export def Main(how: string, type = ''): string #{{{2
    if type == ''
        &operatorfunc = function(lg.Opfunc, [{funcname: function(Main, [how])}])
        return 'g@'
    endif

    if type == 'line'
        ReorderLines(how)
    else
        ReorderNonLinewiseText(how, type)->PasteNewText(type)
    endif

    return ''
enddef
#}}}1
# Core {{{1
def PasteNewText(contents: list<string>, type: string) #{{{2
    var reg_save: dict<any> = getreginfo('"')
    var clipboard_save: string = &clipboard
    var selection_save: string = &selection

    var new: dict<any> = deepcopy(reg_save)
    var regtype: string = type == 'block' ? 'b' : 'c'
    extend(new, {regcontents: contents, regtype: regtype})

    try
        setreg('"', new)
        &clipboard = ''
        &selection = 'inclusive'
        normal! gvp`[
    catch
        lg.Catch()
    finally
        [&clipboard, &selection] = [clipboard_save, selection_save]
        setreg('"', reg_save)
    endtry
enddef

def ReorderLines(how: string) #{{{2
    var range: string = ":'[,']"
    var firstline: number = line("'[")
    var lastline: number = line("']")

    if how == 'sort'
        var lines: list<string> = getline(firstline, lastline)
        var flag: string = ContainsOnlyDigits(lines) ? ' n' : ''
        execute range .. 'sort' .. flag

    elseif how == 'reverse'
        var foldenable_save: bool = &l:foldenable
        var winid: number = win_getid()
        var bufnr: number = bufnr('%')
        [foldenable_save, winid, bufnr] = [&l:foldenable, win_getid(), bufnr('%')]
        try
            &l:foldenable = false
            execute 'keepjumps keeppatterns '
                .. range .. 'global/^/move ' .. (firstline - 1)
        finally
            if winbufnr(winid) == bufnr
                var tabnr: number
                var winnr: number
                [tabnr, winnr] = win_id2tabwin(winid)
                settabwinvar(tabnr, winnr, '&foldenable', foldenable_save)
            endif
        endtry

    elseif how == 'shuf'
        # Alternative:
        #     execute 'silent keepjumps keeppatterns ' .. range .. '!shuf'
        var randomized: list<string> = getline(firstline, lastline)->Randomize()
        setline(firstline, randomized)
    endif
enddef

def ReorderNonLinewiseText(how: string, type: string): list<string> #{{{2
    var text: list<string> = getreg('"', true, true)
    if len(text) == 0
        return []
    endif

    var sep_join: string
    var texts_to_reorder: list<string>
    if type == 'block'
        # `text` is a list of possibly multiple strings
        # We write the splitting pattern explicitly to preserve possible NULs.{{{
        #
        # NULs are translated  into newlines; and, without  a pattern, `split()`
        # splits at newlines (the default pattern is probably: `\_s\+`).
        #}}}
        texts_to_reorder = text
            ->mapnew((_, v: string): list<string> => split(v, '\s\+'))
            ->flattennew()

    elseif type == 'char'
        # `text` is a list containing a single string
        var text_inside: string = text[0]
        # ask the user what is the separator between the texts they want to sort
        var sep_split: string = input('separator> ')
        if sep_split->strcharlen() == 1
            sep_split ..= '\s*'
        endif

        texts_to_reorder = text_inside
            ->split(sep_split)
            # remove surrounding whitespace
            ->map((_, v: string) => trim(v))

        # `join()` doesn't interpret its 2nd argument the same way `split()` does:{{{
        #
        #     split():  regex
        #     join():   literal string
        #
        # `sep_join` may be:
        #
        #     ', '
        #     '; '
        #     ' '
        #     ','
        #     ';'
        #     ';'
        #}}}
        var pat: string = '^\\s\\+$\|\\s\*$'
        var rep: string = text_inside =~ '\s' ? ' ' : ''
        # separator which will be added between 2 consecutive texts
        sep_join = sep_split->substitute(pat, rep, '')
        if sep_join == '  '
            sep_join = ' '
        endif
    endif

    var sorted: list<string>
    if how == 'sort'
        var func: string = ContainsOnlyDigits(texts_to_reorder) ? 'N' : ''
        sorted = sort(texts_to_reorder, func)
    elseif how == 'reverse'
        sorted = reverse(texts_to_reorder)
    else
        sorted = Randomize(texts_to_reorder)
    endif

    if type == 'block'
        return sorted
    endif
    return [sorted->join(sep_join)]
enddef
#}}}1
# Utility {{{1
def ContainsOnlyDigits(to_reorder: list<string>): bool #{{{2
# if  the  text  contains  only  digits,   we  want  a  numerical  sorting  (not
# lexicographic)

    var texts: list<string> = to_reorder
        # Vim passes a variable  to a function by reference not  by copy, and we
        # don't want `map()` nor `filter()` to alter the text; hence `copy()`
        ->copy()
        ->map((_, v: string) => v->matchstr('\D'))
        ->filter((_, v: string): bool => v != '')

    return empty(texts)
enddef

def Randomize(list: list<string>): list<string> #{{{2
    # Alternative:
    #     silent return systemlist('shuf', list)
    return len(list)
        ->range()
        ->map((_, _) => list->remove(srand()->rand() % len(list)))
enddef
