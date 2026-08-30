vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# FAQ {{{1
# What's the meaning of ...?{{{2
# %<{{{3
#
# It means: “you can truncate what comes right after”.
#
#     $ vim -Nu NONE +'set laststatus=2 statusline=abcdef%<ghijklmnopqrstuvwxyz' +':10 vsplit'
#     abcdef<xyz
#
# Notice how the  *start* of the text `ghi...xyz` has  been truncated, not the
# end.  This is why  `<` was chosen for the item `%<` (and  not `>`), and this
# is why `<` is positioned *before* the truncated text.
#
# However, if the  text that comes before  `%<` is too long, Vim  will have to
# truncate it too:
#
#     $ vim -Nu NONE +'set laststatus=2 statusline=abcdefghijklmn%<opqrstuvwxyz' +':10 vsplit'
#     abcdefghi>
#
# Notice  that this  time, it's  the  *end* of  the *previous*  text which  is
# truncated, and that `>` is positioned after it.
#
# To summarize:
# `%<` describes a point from which Vim can truncate the text if needed.
# It starts by truncating as much text as necessary right *after* the point.
# If that's not enough, it goes on by truncating the text right *before* the point.
#
#     very long %< text
#
# If `very long  text`  is too  long for  the status line,  Vim will  start by
# truncating the start of ` text`:
#
#     very long %< text
#                 ---->
#                 as much as necessary
#
# and if truncating  all of ` text` is  not enough, it will  then truncate the
# end of `very long `:
#
#     very long %< text
#     <---------
#     as much as necessary
#
# ---
#
# If you omit `%<`, Vim assumes it's at the start, and truncates from the very
# beginning:
#
#     $ vim -Nu NONE +'set laststatus=2 statusline=abcdefghijklmnopqrstuvwxyz' +':10 vsplit'
#     <rstuvwxyz
#
# ---
#
# To control truncations, you must use:
#
#    - `%<` outside `%{}`
#    - `.123` inside `%{}` (e.g. `%.123{...}`)
#
# Note that `.123` truncates the start of the text, just like `%<`.

# %(%) {{{3
#
# Useful to set the desired width / justification of a group of items.
#
# Example:
#
#      ┌ left justification
#      │ ┌ width of the group
#      │ │
#      │ │ ┌ various items inside the group (%l, %c, %V)
#      │ │ ├─────┐
#     %-15(%l,%c%V%)
#     │           ├┘
#     │           └ end of group
#     │
#     └ beginning of group
#       the percent is separated from the open parenthesis because of the width field
#
# For more info, `:help 'statusline`:
#
#    > ( - Start of item group.  Can  be used for setting the width and alignment
#    >                           of a section.  Must be followed by %) somewhere.
#
#    > ) - End of item group.    No width fields allowed.

# -123  field {{{3

# Set the width of a field to 123 cells.
#
# Can be used (after the 1st percent sign) with all kinds of items:
#
#    - `%l`
#    - `%{...}`
#    - `%(...%)`
#
# Useful to append a space to an item, but only if it's not empty:
#
#     %-12item
#         ├──┘
#         └ suppose that the width of the item is 11
#
# The width of  the field is one unit  greater than the one of the  item, so a
# space will  be added; and the  left-justifcation will cause it  to appear at
# the end (instead of the beginning).

# .123  field {{{3
#
# Limit the width of an item to 123 cells:
#
#     %.123item
#
# Can be used (after the 1st percent sign) with all kinds of items:
#
#    - `%l`
#    - `%{...}`
#    - `%(...%)`
#
# Truncation occurs with:
#
#    - a '<' at the start for text items
#    - a '>' at the end for numeric items (only `maxwid - 2` digits are kept)
#      the number after '>' stands for how many digits are missing
#}}}2
# What's the difference between `g:statusline_winid` and `g:actual_curwin`?{{{2
#
# The former can be used in a `%!` expression, the latter inside a `%{}` item.

# How to make sure two consecutive flags A and B are visually well separated?{{{2
#
# If the length of A is fixed (e.g. 12), and A is not highlighted:
#
#     %-13{item}
#      ^^^
#      make the length of the flag one cell longer than the text it displays
#      and left-align it
#
# You could also append a space manually:
#
#     '%{item} '
#             ^
#
# But the space would be displayed unconditionally which you probably don't want.
#
# ---
#
# If the length of  A is fixed, and A *is* highlighted, don't  try to append a
# space; it would get highlighted which would be ugly.
#
# ---
#
# If  the  length of  A  can  vary, highlight  it  with  a HG  different  than
# `StatusLine` so that it clearly stands out.

# What are the “buffer”, “window”, “tabpage” and “global” scopes?{{{2
#
# A flag might give an information about:
#
#    - a buffer; we say it's in the *buffer scope*
#    - a window; we say it's in the *window scope*
#    - all buffers in a tabpage; we say it's in the *tabpage scope*
#    - some setting which applies to all buffers/windows/tabpages; we say it's in the *global scope*
#
# By convention, we display a flag in:
#
#    - the buffer scope, on the left of the status line
#    - the window scope, on the right of the status line
#    - the tabpage scope, at the end of a tab label
#    - the global scope, on the right of the tab line
#
# That's more or  less what `vim-flagship` does.  This is  a useful convention
# because it makes a flag give more information; its position tells us what is
# affected.

# How to set a flag in the tabpage scope?{{{2
#
# Like for any other scope:
#
#     autocmd User MyFlags g:StatusLineFlag('tabpage', '[on]')
#
# However, if your flag  depends on the tab page in  which it's displayed, you
# might need the  special placeholder `{tabnr}`.  For example,  to include the
# number of windows inside a tab page, you would write:
#
#     autocmd User MyFlags g:StatusLineFlag('tabpage', '[%{tabpagewinnr({tabnr}, "$")}]')
#                                                                       ^-----^
#
# If your expression is too complex to  fit directly in the function call, and
# you need  to compute  the flag via  another function, make  sure to  pass it
# `{tabnr}` as an argument:
#
#                                                            v-----v
#     autocmd User MyFlags g:StatusLineFlag('tabpage', 'Func({tabnr})')
#     def Func(tabnr: number): string
#              ^---^
#         # compute the flag using `tabnr` to refer to the tab page number
#                                   ^---^
#         return '...'
#     enddef

# What is a “volatile” flag?{{{2
#
# If a flag A is  on for one minute, then off for one  minute, then on for one
# minute etc.  while a flag B  is on for  five consecutive minutes, then  A is
# more **volatile** than B.
#
# The more  volatile a flag  is, the more on  the right of  the buffer/tabpage
# scope –  or on the left  of the window/global  scope – it should  be, so
# that it disturbs the position of as fewer flags as possible.

# I have 2 flags A and B in the same scope.  I don't know which one should be displayed first!{{{2
#
# Ask yourself this: how  frequently could I be in a situation  where B is on,
# and the state of A changes (on → off, off → on)?
#
# If the answer is “often”, then B should be displayed:
#
#    - before A if they are in the buffer/tabpage scope
#    - after A if they are in the window/global scope
#
# The goal is  to prevent as much  as possible that a  recently displayed flag
# disturbs the positions of existing flags.
#
# ---
#
# Don't think about it too much.  Tweak the priorities by experimentation.  If
# the display of A often disturbs the  position of B, increase A's priority so
# that it's greater than B's priority.

# For the priorities, what type of numbers should I use?{{{2
#
# Follow this useful convention: any flag installed from this file should have
# a  priority which  is a  multiple  of 10.   For flags  installed from  other
# plugins, use priorities which are not multiples of 10.

# I have a flag checking whether the value of an option has been altered.{{{2
# It is still displayed even when I restore the original value of the option!{{{3
#
# For a  comma-separated list  of items,  the order  matters.  Your  new value
# might  contain the  same items  as the  original value,  but in  a different
# order.
#
#    1. you should not restore the option manually; your plugin/script  should
#       do  it, and  it should  not use  a "relative" assignment operator like
#       `+=`, but an "absolute" one like `=`
#
#    2. if your plugin/script  fails to restore the option, and  you need to
#       quickly fix it, just reload your  buffer (for a buffer-local option)
#       or restart Vim (for a global option)
#
# You could try to  make the flags insensitive to the order  of the items, but
# it would add some complexity for a too small benefit.  If one day you try to
# make them insensitive, make sure our `:Vo` command still works as expected.
#}}}1

# Init {{{1

silent! import autoload 'fold/adhoc.vim' as fold

# no more than `x` characters in a tab label
const TABLABEL_MAX_CHARS: number = 20

# no more than `x` tab labels on the right/left of the tab label currently focused
const TABLABELS_MAX_NEIGHBORS: number = 1

# highlight group for the flags in the tab line
const TABLINE_HIGHLIGHT_FLAGS: string = '%#StatusLineTermNC#'

const SCOPES: list<string> = ['global', 'tabpage', 'buffer', 'window']
var flags_db: dict<list<any>>
var flags: dict<string>

# Options {{{1

# always show the status line and the tab line
&laststatus = 2
&showtabline = 2

&tabline = '%!Tabline()'
&statusline = '%!Statusline()'

# For our tabline to take effect in the GUI, we need to remove the `e` flag from 'guioptions'.{{{
#
# From `:help 'go-e'`:
#
#    > When 'e' is missing a non-GUI tab pages line may be used.
#}}}
set guioptions-=e

# Functions {{{1
def g:StatusLineFlag( #{{{2
        scope: string,
        aflag: string,
        priority = 0,
        source = '',
        )

    unlockvar! flags_db
    if SCOPES->index(scope) == -1
        throw $'statusline: "{scope}" is not a valid scope'
    endif
    var flag: string = aflag
    var pat: string = '^%[1-9]\*\|^%#[^#]\+#'
    # if a flag is highlighted, restore normal highlight
    if flag =~ pat
        if scope == 'global'
            flag ..= TABLINE_HIGHLIGHT_FLAGS
        else
            flag ..= '%*'
        endif
    endif
    flags_db[scope]->add({
        flag: flag,
        priority: priority,
        source: source,
    })
    lockvar! flags_db
enddef

def SetFlags()
    unlockvar flags
    for scope: string in keys(flags)
        var flags_for_this_scope: list<dict<any>> = flags_db[scope]
            ->deepcopy()
            ->sort((a: dict<any>, b: dict<any>): number => a.priority - b.priority)
        if scope == 'global' || scope == 'window'
            reverse(flags_for_this_scope)
        endif
        flags[scope] = flags_for_this_scope
            ->mapnew((_, v: dict<any>): string => v.flag)
            ->join('')
    endfor
    lockvar! flags
enddef

def g:Statusline(): string #{{{2
    if g:statusline_winid != win_getid()
        return ' %1*%{StatuslineTailOfPath()}%* '
            .. '%='
            .. '%{&l:scrollbind ? "[scb]" : ""}'
            .. '%{&l:diff ? "[diff]" : ""}'
            .. '%{&l:previewwindow ? "[pvw]" : ""}'
            .. (win_id2win(g:statusline_winid)->getwinvar('&previewwindow') ? '%4p%% ' : '')
    else
        return $'{flags.buffer}%={flags.window}'
    endif
enddef

def g:Tabline(): string #{{{2
    var s: string
    var curtab: number
    var lasttab: number
    [curtab, lasttab] = [tabpagenr(), tabpagenr('$')]

    # Shortest Distance From Ends
    var sdfe: number = min([curtab - 1, lasttab - curtab])
    # How did you get this expression?{{{
    #
    # We don't want to see a label for a tab page which is too far away:
    #
    #                          v------v
    #     if abs(curtab - n) > max_dist
    #         return ''
    #     endif
    #
    # Now, suppose we want to see 2 labels  on the left and right of the label
    # currently focused, but not more:
    #
    #                          v
    #     if abs(curtab - n) > 2
    #         return ''
    #     endif
    #
    # If we're in the middle of a big enough tabline, it will look like this:
    #
    #       | | | a | a | A | a | a | | |
    #                 │   │
    #                 │   └ label currently focused
    #                 └ some label
    #
    # Problem:
    #
    # Suppose we focus the last but two tab page, the tabline becomes:
    #
    #     | | | a | a | A | a | a
    #
    # Now suppose we focus the last but one tab page, the tabline becomes:
    #
    #     | | | | a | a | A | a
    #
    # Notice how the tabline only contains 4 named labels, while it had 5 just
    # before.  We  want the tabline  to always have  the same amount  of named
    # labels, here 5:
    #
    #     | | | a | a | a | A | a
    #           ^
    #           to get this one we need `max_dist = 3`
    #
    # It appears that  focusing the last but  one tab page is  a special case,
    # for which  `max_dist` should  be `3`  and not  `2`.  Similarly,  when we
    # focus the last tab page, we need `max_dist` to be `4` and not `2`:
    #
    #     | | | a | a | a | a | A
    #           ^   ^
    #           to get those, we need `max_dist = 4`
    #
    # So, we need to add a number to `2`:
    #
    #    ┌──────────────────────────────────────────┬──────────┐
    #    │              where is focus              │ max_dist │
    #    ├──────────────────────────────────────────┼──────────┤
    #    │ not on last nor on last but one tab page │ 2 + 0    │
    #    ├──────────────────────────────────────────┼──────────┤
    #    │ on last but one tab page                 │ 2 + 1    │
    #    ├──────────────────────────────────────────┼──────────┤
    #    │ on last tab page                         │ 2 + 2    │
    #    └──────────────────────────────────────────┴──────────┘
    #
    # But what is the expression to get this number?
    # Answer:
    # We need to consider two cases depending on whether `lasttab - curtab >= 2`
    # is true or false.
    #
    # If it's true, it means that we're not near enough the end of the tabline
    # to  worry; we  are  in  the general  case  for  which `max_dist = 2`  is
    # correct.
    #
    # If it's false, it  means that we're too close from the  end, and we need
    # to  increase  `max_dist`.   By  how  much? The  difference  between  the
    # operands:
    #
    #     2 - (lasttab - curtab)
    #
    # The pseudo-code to get `max_dist` is thus:
    #
    #     if lasttab - curtab >= 2
    #         max_dist = 2
    #     else
    #         max_dist = 2 + (2 - (lasttab - curtab))
    #
    # Now we  also need  to handle  the case  where we're  too close  from the
    # *start* of the tabline:
    #
    #     if curtab - 1 >= 2
    #         max_dist = 2
    #     else
    #         max_dist = 2 + (2 - (curtab - 1))
    #
    # Finally, we have to merge the two snippets:
    #
    #     sdfe = min([curtab - 1, lasttab - curtab])
    #     if sdfe >= 2
    #         max_dist = 2
    #     else
    #         max_dist = 2 + (2 - sdfe)
    #
    # Which can be generalized to an  arbitrary number of labels, by replacing
    # `2` with a variable `x`:
    #
    #     sdfe = min([curtab - 1, lasttab - curtab])
    #     if sdfe >= x
    #         max_dist = x
    #     else
    #         max_dist = x + (x - sdfe)
    #}}}
    var max_dist: number = TABLABELS_MAX_NEIGHBORS
        + (sdfe >= TABLABELS_MAX_NEIGHBORS ? 0 : TABLABELS_MAX_NEIGHBORS - sdfe)
    # Alternative:{{{
    # for 3 labels:{{{
    #
    #     var max_dist: number =
    #         [1, lasttab]->index(curtab) >= 0 ? 1 + 1
    #         :                                  1 + 0
    #}}}
    # for 5 labels:{{{
    #
    #     var max_dist: number =
    #           [1, lasttab]->index(curtab)     >= 0 ? 2 + 2
    #         : [2, lasttab - 1]->index(curtab) >= 0 ? 2 + 1
    #         :                                        2 + 0
    #}}}
    # for 7 labels:{{{
    #
    #     var max_dist: number =
    #           [1, lasttab]->index(curtab)     >= 0 ? 3 + 3
    #         : [2, lasttab - 1]->index(curtab) >= 0 ? 3 + 2
    #         : [3, lasttab - 2]->index(curtab) >= 0 ? 3 + 1
    #         :                                        3 + 0
    #}}}
    #}}}

    var truncation_pos_set: bool
    for i: number in range(1, lasttab)
        if !truncation_pos_set && i > curtab + TABLABELS_MAX_NEIGHBORS
            s ..= '%<'
            truncation_pos_set = true
        endif

        # color the label of the current tab page with the HG `TabLineSel` the
        # others with `TabLine`
        s ..= i == curtab ? '%#TabLineSel#' : '%#TabLine#'

        # set the tab page nr (used by the mouse to recognize the tab page on which we click)
        # If you can't create enough tab pages because of `E541`,{{{
        #
        # you might  want to  comment this  line to reduce  the number  of `%`
        # items used in `'tabline'` which will increase the limit.
        #}}}
        s ..= $'%{i}T'

        # set the label
        var label: string
        if abs(curtab - i) > max_dist
            label = string(i)
        else
            label = $' %{{StatuslineTabpageLabel({i}, {curtab})}} '
            var tab_flags: string = flags.tabpage->substitute('\C{tabnr}', i, 'g')
            if tab_flags != ''
                label ..= TABLINE_HIGHLIGHT_FLAGS
                    .. tab_flags
                    .. '%#TabLine#'
                    .. (i != curtab ? ' ' : '')
            endif
        endif

        s ..= $'{label}│'
    endfor

    # color the  rest of the  line with  `TabLineFill` (until the  flags), and
    # reset tab page nr (`%T`)
    s ..= '%#TabLineFill#%T'

    # append global flags on the right of the tab line
    s ..= $'%={TABLINE_HIGHLIGHT_FLAGS}{flags.global}'

    # If you want to get a closing label, try this:{{{
    #
    #                        %X    = closing label
    #                        999   = nr of the tab page to close when we click on the label
    #                                (big nr = last tab page currently opened)
    #                        close = text to display
    #                        v--------v
    #     s ..= '%=%#TabLine#%999Xclose'
    #            ^^
    #            right-align next labels
    #}}}
    return s
enddef
# What does `Tabline()` return ?{{{
#
# Suppose we have 3 tab pages, and the focus is currently in the 2nd one.
# The value of `'tabline'` could be similar to this:
#
#     %#TabLine#%1T %{MyTabLabel(1)}
#     %#TabLineSel#%2T %{MyTabLabel(2)}
#     %#TabLine#%3T %{MyTabLabel(3)}
#     %#TabLineFill#%T%=%#TabLine#%999Xclose
#
# Rules:
#
# - any item must begin with `%`
# - an expression must be surrounded with `{}`
# - the HGs must be surrounded with `#`
# - we should only use one of the 3 following HGs, to highlight:
#
#    ┌─────────────────────────┬─────────────┐
#    │ the non-focused labels  │ TabLine     │
#    ├─────────────────────────┼─────────────┤
#    │ the focused label       │ TabLineSel  │
#    ├─────────────────────────┼─────────────┤
#    │ the rest of the tabline │ TabLineFill │
#    └─────────────────────────┴─────────────┘
#}}}

def g:StatuslineTabpageLabel(n: number, curtab: number): string #{{{2
    var winnr: number = tabpagewinnr(n)
    var bufnr: number = win_getid(winnr, n)->winbufnr()
    var bufname: string = bufname(bufnr)
    if bufname != ''
        bufname = bufname->fnamemodify(':p')
    endif

    var label: string
    # don't display anything in the label of  the current tab page if we focus
    # a special buffer
    if n == curtab && &buftype != ''
        label = ''
    # Display the CWD if, and only if:{{{
    #
    #    - the buffer has a name
    #
    #    - the file is in a version-controlled project,
    #      or the label is for the current tab page
    #
    #      In the latter case, we don't care about the name of the current file:
    #
    #        - it's already in the status line
    #        - it's complete in the status line
    #}}}
    # `b:root_dir` is set by `vim-cwd`
    elseif bufname != '' && (n == curtab || getbufvar(bufnr, 'root_dir', '') != '')
        var cwd: string = getcwd(winnr, n)
            ->substitute('^\V' .. escape($HOME, '\') .. '/', '', '')
            ->pathshorten()
        # append a slash to avoid confusion with a buffer name
        if cwd !~ '/'
            cwd ..= '/'
        endif
        label = cwd
    # otherwise, just display the name of the focused buffer
    else
        label = bufname->fnamemodify(':t')
    endif
    # I'm not satisfied with the labels!{{{
    #
    # Have a look at this for more inspiration:
    # https://github.com/tpope/vim-flagship/issues/2#issuecomment-113824638
    #}}}

    # make sure the label never exceeds our chosen maximum of characters
    label = label[: TABLABEL_MAX_CHARS - 1]
    if n != curtab
        return label
    endif
    # Add padding whitespace around the current tab label.{{{
    #
    # This is useful to prevent the tabline from “dancing” when we focus a
    # different window in the same tab page.
    #}}}
    var len: number = strcharlen(label)
    var cnt: number = (TABLABEL_MAX_CHARS - len) / 2
    return repeat(' ', cnt) .. label .. repeat(' ', cnt + len % 2)
enddef

def g:StatuslineTabpageWinnr(tabnr: number): string #{{{2
    # return the number of windows inside the tab page `tabnr`
    var last_winnr: number = tabpagewinnr(tabnr, '$')
    # We are not interested in the number of windows inside:{{{
    #
    #    - the current tab page
    #    - another tab page if it only contains 1 window
    #}}}
    return tabpagenr() == tabnr || last_winnr == 1 ? '' : $'[{last_winnr}]'
enddef

def g:StatuslineTailOfPath(): string #{{{2
    if bufname('%') == ''
        return ''
    endif

    var tail: string = expand('%:t')->strtrans()

    return &buftype == 'terminal'
        ?     '[term]'
        : tail == ''
        ?     (&buftype == 'nofile' ? '[Scratch]' : '[No Name]')
        :     tail
enddef
# The following comment is kept for educational purpose, but no longer relevant.{{{
# It applied to a different expression than the one currently used.  Sth like:
#
#     return &buftype != 'terminal'
#         ? &filetype != 'dirvish'
#         ? &buftype != 'quickfix'
#         ? tail != ''
#         ?     tail
#         :     '[No Name]'
#         :     win_gettype() == 'loclist' ? '[LL]' : '[QF]'
#         :     '[dirvish]'
#         :     '[term]'
#}}}
# How to read the returned expression:{{{
#
#    - pair the tests and the values as if they were an imbrication of
#      parentheses
#
#      Example:
#
#         1st test = &buftype != 'terminal'
#         last value = [term]
#
#         2nd test = &filetype != 'dirvish'
#         penultimate value = [dirvish]
#
#         ...
#
#     - when a test fails, the returned value is immediately known:
#       it's the one paired with the test
#
#     - when a test succeeds, the next test is evaluated:
#       all the previous ones are known to be true
#
#     - If all tests succeed, the value which is used is `tail`.
#       It's the only one which isn't paired with any test.
#       It means that it's used if, and only if, all the tests have NOT failed.
#       It's the default value used for a buffer without any peculiarity:
#       random type, random name
#}}}

def SetFlagForLocalOption( #{{{2
        longopt: string,
        shortopt: string,
        priority: number,
        scope: string
        )

    # *n*ame*s*pace
    var ns: string = scope == 'window' ? 'w' : 'b'
    [{
        group: 'SaveOriginalOptions',
        event: ['BufNewFile', 'BufReadPost', 'FileType'],
        pattern: '*',
        cmd: $'if !exists("{ns}:_ORIG_OPTS") | {ns}:_ORIG_OPTS = {{}} | endif | {ns}:_ORIG_OPTS.{longopt} = &l:{longopt}',
    },
    # Install a  flag whose purpose  is to warn us  whenever the value  of the
    # option is altered.
    #
    # `mode(v:true)`: Don't display the flag temporarily while we're completing some text.{{{
    #
    # If  you think  you can  refactor this  check into  something else  (e.g.
    # `!pumvisible()`), make a  test while using our  custom `C-x C-n` mapping
    # in insert mode (which temporarily resets `'iskeyword'`).
    #}}}
    {
        group: 'SaveOriginalOptions',
        event: 'User',
        pattern: 'MyFlags',
        cmd: $'g:StatusLineFlag("{scope}", ''%2*%{{mode(v:true) ==# "n" && exists("{ns}:_ORIG_OPTS") && &l:{longopt} != {ns}:_ORIG_OPTS.{longopt} ? "[{shortopt}]" : ""}}'', {priority})'
    }]->autocmd_add()
enddef

augroup SaveOriginalOptions
    autocmd!
augroup END

def CPOptionsFlag(): string #{{{2
    return &g:cpoptions->split('\zs')->sort() != get(g:_ORIG_OPTS, 'cpoptions', []) ? '[cpo]' : ''
enddef

def CompleteOptFlag(): string #{{{2
    return mode(true) == 'n'
        && &g:completeopt->split(',')->sort() != g:_ORIG_OPTS.completeopt ? '[cot]' : ''
enddef

def IsfnameFlag(): string #{{{2
    # Don't display a flag in a Perl file.{{{
    #
    # The Perl filetype  plugin (`$VIMRUNTIME/ftplugin/perl.vim`) purposefully
    # reset the  option.  It also  automatically fixes the option  whenever we
    # focus a buffer with a different filetype.
    #}}}
    return &filetype != 'perl'
        && &g:isfname != g:_ORIG_OPTS.isfname ? '[isf]' : ''
enddef

def IskeywordFlag(): string #{{{2
    return &g:iskeyword != g:_ORIG_OPTS.iskeyword ? '[isk]' : ''
enddef

def VirtualEditFlag(): string #{{{2
    # The `m`  and `x` flags are  so that we  don't briefly see a  `[ve]` flag
    # when we press `%` on a parenthesis to jump to the opposite one, while on
    # a very long line.
    return state('mox') == ''
        && &g:virtualedit != g:_ORIG_OPTS.virtualedit
        ? '[ve]' : ''
enddef

def FixOptions() #{{{2
    var did_fix_options: bool = false

    for ns: string in ['g', 'b', 'w']
        var is_local: bool = ns == 'b' || ns == 'w'
        if is_local && !exists($'{ns}:_ORIG_OPTS')
            continue
        endif

        var lg: string = is_local ? 'l' : 'g'
        for opt: string in $'{ns}:_ORIG_OPTS'->eval()->keys()
            var orig_val: any = $'{ns}:_ORIG_OPTS.{opt}'->eval()
            # The option's value is a list of items.
            if orig_val->typename() =~ '^list<'
                # Items might be  separated by a comma  (e.g. `'completeopt'`), or
                # by nothing (e.g. `'cpoptions'`).
                var sep: string = orig_val
                    ->indexof((_, item: string): bool => item->len() > 1) >= 0 ? ',' : ''
                if orig_val != $'&{lg}:{opt}'
                        ->eval()
                        ->split(sep == '' ? '\zs' : ',')
                        ->sort()
                    execute $'&{lg}:{opt} = {orig_val->join(sep)->string()}'
                    did_fix_options = true
                endif
            # The  option's value  is *not*  a list  of items  (it might  be a
            # string,  a bool,  a number,  ...),  and its  original value  was
            # altered.
            elseif orig_val != $'&{lg}:{opt}'->eval()
                execute $'&{lg}:{opt} = {orig_val->string()}'
                did_fix_options = true
            endif
        endfor
    endfor

    # We might press `=o` to remove a global flag from the tabline.
    # If so, we need to update the latter to see the effect immediately.
    redrawtabline

    if !did_fix_options
        echo 'could not find any option which needs to be fixed'
    endif
enddef

def Init() #{{{2
    unlockvar! flags
    unlockvar! flags_db
    # Why not init these variable right when we declare them, at the script level?{{{
    #
    # We might  need to  re-init them,  if we want  to add  some flags  from a
    # plugin which we source *after*  `VimEnter`, with `:packadd`.  The latter
    # could include its flags with:
    #
    #     doautocmd <nomodeline> MyStatusline VimEnter
    #}}}
    flags = {global: '', tabpage: '', buffer: '', window: ''}
    flags_db = {global: [], tabpage: [], buffer: [], window: []}
enddef
# Make sure the  variables are init immediately so that  we don't get unexpected
# errors when we're debugging and starting Vim in weird ways (i.e. with `-S` or `+`).
Init()
#}}}1
# Autocmds {{{1

augroup MyStatusline
    autocmd!

    # get flags (including the ones from other plugins)
    autocmd VimEnter * {
        if exists('#User#MyFlags')
            Init()
            doautocmd <nomodeline> User MyFlags
            SetFlags()
        endif
    }

    # Some flag is temporarily displayed while I'm using some command.  It's too distracting!{{{
    #
    # Try to add this check: `state("mox") == ""`.
    #}}}
    autocmd User MyFlags g:StatusLineFlag('global', '%{&diffopt =~# "iwhiteall" ? "[dip~iwa]" : ""}', 10)
    # Option which has too many side effects.
    autocmd User MyFlags g:StatusLineFlag('global', '%2*%{&paste ? "[paste]" : ""}', 20)
    # You'll probably need to temporarily reset it while replaying a recursive macro.{{{
    #
    # Otherwise, it could  be stuck in an infinite loop.   We currently have a
    # mapping to  toggle the  option, but  we need some  visual clue  to check
    # whether the option is indeed reset.
    #}}}
    autocmd User MyFlags g:StatusLineFlag('global', '%{!&wrapscan ? "[nows]" : ""}', 30)
    autocmd User MyFlags g:StatusLineFlag('global', '%2*%{&eventignore != "" ? "[ei]" : ""}', 40)
    autocmd User MyFlags g:StatusLineFlag('global', '%2*%{' .. expand('<SID>') .. 'CompleteOptFlag()}', 50)
    # The perl filetype plugin unexpectedly includes `:` in the option.{{{
    #
    # That breaks `C-w f` when pressed on this kind of line:
    #
    #     /path/to/file:lnum:col
    #
    # We don't want to lose time debugging this kind of issues.
    #}}}
    autocmd User MyFlags g:StatusLineFlag('global', '%2*%{' .. expand('<SID>') .. 'IsfnameFlag()}', 60)
    # Similar issue with the netrw plugin.{{{
    #
    # If you  press `C-w f` on  a URL while  your network connection  is down,
    # netrw  includes `/`  (and `*`)  inside the  global value  of the  buffer
    # created for the split window.  If that happens, all subsequently created
    # buffers will init  the local value of the option  with this wrong value.
    # Among other things,  that can break `\<`/`\>` in a  regex which might be
    # used in a filetype detection script.
    #}}}
    autocmd User MyFlags g:StatusLineFlag('global', '%2*%{' .. expand('<SID>') .. 'IskeywordFlag()}', 70)
    autocmd User MyFlags g:StatusLineFlag('global', '%2*%{' .. expand('<SID>') .. 'VirtualEditFlag()}', 80)
    # Do *not* try to add a flag for `'lazyredraw'`.{{{
    #
    # We tried in the past, but it was too tricky.
    #
    # For example, if you try:
    #
    #     autocmd User MyFlags g:StatusLineFlag('global', '%{!&lazyredraw ? "[nolz]" : ""}', 40)
    #
    # Then execute `:redrawtabline`: the `[nolz]` flag is displayed in the tab
    # line.  I think that when `:redrawtabline`  is run, Vim resets the option
    # temporarily.  Anyway, because of this,  the flag could also be displayed
    # if we have an autocmd running `:redrawtabline`.
    #}}}

    # We want  to be warned *immediately*  if an option has  been altered, but
    # the tab line  is not redrawn as  often as the status line;  let's try to
    # compensate.
    autocmd OptionSet completeopt,isfname,iskeyword,diffopt,eventignore,paste,virtualedit,wrapscan redrawtabline

    # the lower the priority, the closer to the left end of the status line the flag is
    # Why the arglist at the very start?{{{
    #
    # So that the  index is always in the same  position.  Otherwise, when you
    # traverse the arglist,  the index position changes every  time the length
    # of the  filename also  changes; this is  jarring when  you're traversing
    # fast and you're looking for a particular index.
    #}}}
    autocmd User MyFlags g:StatusLineFlag('buffer', '%#StatusLineArgList#%a%*', 10)
    autocmd User MyFlags g:StatusLineFlag('buffer', ' %1*%{StatuslineTailOfPath()}%* ', 20)
    autocmd User MyFlags g:StatusLineFlag('buffer', '%r', 30)
    # We don't want the modifier flag in special buffers (like terminal or prompt).
    autocmd User MyFlags g:StatusLineFlag('buffer',
            \ '%2*%{&modified && bufname("%") != "" && &buftype == "" ? "[+]" : ""}', 50)
    autocmd User MyFlags g:StatusLineFlag('buffer',
            \   '%{&buftype !=# "terminal" || mode() ==# "t" ? ""'
            \ .. ' : bufnr("")->term_getstatus() ==# "finished" ? "[finished]" : "[n]"}', 60)
    SetFlagForLocalOption('autoindent', 'ai', 70, 'buffer')
    SetFlagForLocalOption('iskeyword', 'isk', 80, 'buffer')

    # the lower the priority, the closer to the right end of the status line the flag is
    autocmd User MyFlags g:StatusLineFlag('window', '%5p%% ', 10)
    autocmd User MyFlags g:StatusLineFlag('window', '%9(%.5l,%.3v%)', 20)
    autocmd User MyFlags g:StatusLineFlag('window', '%{&l:previewwindow ? "[pvw]" : ""}', 30)
    autocmd User MyFlags g:StatusLineFlag('window', '%{&l:diff ? "[diff]" : ""}', 40)
    autocmd User MyFlags g:StatusLineFlag('window', '%{&l:scrollbind ? "[scb]" : ""}', 50)
    autocmd User MyFlags g:StatusLineFlag('window', '%{&l:spell ? "[spell]" : ""}', 60)
    # We handle `'cpoptions'` here, even though it's not a buffer-local option (but a global one).{{{
    #
    # In the tab line, its flag would be sometimes briefly displayed, which is
    # distracting.  For  example, that happens  when we press  `<Space>fr` for
    # the first time (to fuzzy search a recent file).
    #}}}
    autocmd User MyFlags g:StatusLineFlag('buffer', '%2*%{' .. expand('<SID>') .. 'CPOptionsFlag()}', 70)
    SetFlagForLocalOption('virtualedit', 've', 80, 'window')

    # TODO: Add a tabpage flag to show whether the focused project is dirty?{{{
    #
    # I.e. the project contains non-commited changes.
    #
    # If you try to  implement this flag, cache the state of  the project in a
    # buffer  variable.  But  when  would  we update  the  cache?  Running  an
    # external shell command (here `git(1)`) is costly...
    #}}}
    autocmd User MyFlags g:StatusLineFlag('tabpage', '%{StatuslineTabpageWinnr({tabnr})}', 10)

    autocmd CmdwinEnter * &l:statusline = ' %l'
augroup END

# Commands {{{1

command -bar -nargs=? -range=% -complete=custom,Complete StatusLineFlags DisplayFlags(<q-args>)

def Complete(_, _, _): string
    return SCOPES->join("\n")
enddef

def DisplayFlags(ascope: string)
    var scopes: list<string> = ascope == '' ? SCOPES : [ascope]
    var lines: list<string>
    # Purpose:{{{
    #
    # If there is one  flag, and only one flag in a given  scope, the flags in
    # the subsequent scopes will not  be formatted correctly.  This is because
    # the ranges in our next global  commands work under the assumption that a
    # scope always contains several flags.
    #
    # To fix this issue, we temporarily add a dummy flag.
    #
    # ---
    #
    # Our global commands still give the  desired result when a scope contains
    # no flag.
    #}}}
    var dummy_flag: string = '123 │ dummy flag'
    for scope: string in scopes
        # Underline each `scope ...` line with a `===` line.{{{
        #
        # Don't underline with `───`; it would break folding.
        #}}}
        lines += ['', $'scope {scope}', $'scope {scope}'->substitute('.', '=', 'g'), '']
        var Rep: func = (m: list<string>): string =>
            repeat("\u2588", m[0]->strcharlen())
        lines += flags_db[scope]
            ->mapnew((_, v: dict<any>): string =>
                v.priority->printf('%3d')
                .. $' │ {v.flag}'
                # make sure a trailing whitespace in a flag is visible
                ->substitute('\s\+$', Rep, ''))

        if flags_db[scope]->len() == 1
            lines->add(dummy_flag)
        endif
    endfor
    execute $'pedit {tempname()}'
    wincmd P
    if !&previewwindow
        return
    endif
    &l:buftype = 'nofile'
    &l:buflisted = false
    &l:swapfile = false
    lines->append(0)
    range = ':/^===//^\s*\d\+/ ; /^\s*\d\+//^\s*$\|\%$/-1'
    # For each scope, sort the flags according to their priority.
    # `silent!`  to suppress  a  possible error  in case  the  scope does  not
    # contain any flag.
    silent! keepjumps keeppatterns global/^===/execute $'{range} sort n'
    execute $'silent! keepjumps keeppatterns global/{dummy_flag}/delete _'
    keepjumps :1 delete _
    # highlight flags installed from other plugins
    matchadd('DiffAdd', '^[^│]*[1-9]\s*│.*', 0)
    silent! fold.Main()
    &l:wrap = false
    silent! g:ToggleSettingsAutoOpenFold(true)
    nmap <buffer><nowait> q <Plug>(my-quit)
    nmap <buffer><nowait> <CR> <ScriptCmd>echo GetSourceFile()<CR>
    nmap <buffer><nowait> <C-W>F <ScriptCmd>OpenSourceFile()<CR>
enddef
var range: string

def GetSourceFile(): string
    var lnum: number = search('^scope\s\+\w\+', 'bnW')
    if lnum == 0
        return ''
    endif
    var scope: string = lnum
        ->getline()
        ->matchstr('^scope \zs\w\+')
    var priority_under_cursor: number = getline('.')
        ->matchstr('^\s*\d\+\s*│')
        ->str2nr()
    var source: string = flags_db[scope]
        ->deepcopy()
        ->filter((_, v: dict<any>): bool => v.priority == priority_under_cursor)
        ->get(0, {})
        ->get('source', '')
    return source
enddef

def OpenSourceFile()
    var source: string = GetSourceFile()
    if empty(source)
        return
    endif
    var file: string
    var lnum: string
    [file, lnum] = matchlist(source, '\(.*\):\(\d\+\)')[1 : 2]
    execute $'split +{lnum} {file}'
    normal! zv
enddef

# Mapping {{{1

nnoremap <unique> =o <ScriptCmd>FixOptions()<CR>
