vim9script
# Don't specify `noclear`.{{{
#
# With it, an error is given when we (re-)load our color scheme:
#
#     E1130: Cannot add to null list
#
# The error comes from:
#
#     highlights->add({name: 'DiffChange', cleared: true, linksto: 'NONE'})
#
# As a  workaround, you  could specify  an empty list  for the  initializer of
# `highlights`, but `noclear` might cause other issues later.
#}}}

import '../import/RgbMap.vim'
import autoload '../autoload/seoul.vim'
const RGB_MAP: dict<string> = RgbMap.RGB_MAP

import '../import/util.vim'

# TODO: We should set a few more highlight groups like `diffNoEOL`.
# It's only created once you open a file whose filetype is `diff`,
# from here:
#
#     $VIMRUNTIME/syntax/diff.vim
#
# There might be more; look here:
# https://github.com/vim/colorschemes/blob/master/colors/evening.vim
#
# Also, don't forget the recent `CursorLineSign` and `CursorLineFold` highlight groups.
#
# ---
#
# BTW, notice how this code is much nicer to read than ours.
# It supports gui, &t_Co == 256 and &t_Co == 16.
# As a summary, it also provides the values of the colors at the end via comments.
#
# We have a lot of room for improvement.  Simplify our script much more.

# FIXME: We currently don't support the console.
# That's because we use decimal numbers beyond 16 for the colors.
# In the console, we can only use simple color names (like `red`), or decimal
# numbers below 16.

# We want this to be a good approximation of our terminal foreground color.{{{
#
# Because Vim  uses the  latter to  set the foreground  color of  the text  in a
# terminal buffer:
#
#    > The default foreground and background colors are taken from Vim,
#    > the Normal highlight group.
#
# See `:help terminal-size-color`.
#
# Besides, on  the README for  the seoul plugin,  the range of  valid background
# colors in  the dark version of  the theme, goes from  233 to 239.  And  236 is
# right in the middle, so it seems like a good choice.
#
# Finally, in practice,  236 seems to be  the closest to the hex  value we chose
# for the foreground color in our terminal config file.
#}}}
const FG: number = 236
# Values taken from: https://github.com/junegunn/seoul256.vim#change-background-color
const BG_MIN: number = 251
const BG_MAX: number = 256
const BG_DEFAULT: number = 253

# background colors
var current_bg: number = get(g:, 'SEOUL', {})->get('current', BG_DEFAULT)
var last_bg: string = $'{$HOME}/.local/share/vim/seoul_last_bg'
if has('vim_starting') && last_bg->filereadable()
    current_bg = last_bg
        ->readfile('', 1)
        ->get(0, '')
        ->str2nr() ?? current_bg
endif
# sanitize `current_bg`
if !(BG_MIN <= current_bg && current_bg <= BG_MAX)
    current_bg = BG_DEFAULT
endif
g:SEOUL = {current: current_bg, min: BG_MIN, max: BG_MAX}
augroup SeoulColorScheme
    autocmd!
    autocmd VimLeave * [current_bg]->writefile(last_bg)
    # only  once a  terminal window  has  been open,  to  not slow  Vim down  on
    # startup; it's useless before anyway
    autocmd TerminalWinOpen * ++once seoul.SetTerminalAnsiColors()
augroup END

const BG_1: number = [current_bg + 1, BG_MAX]->min()
const BG_2: number = [current_bg + 2, BG_MAX]->min()
const REPEAT_FG: number = 67
const STATEMENT_FG: number = 66
const TABLINE_BG: number = current_bg - 4
const WARNINGMSG_FG: number = 88

# TODO: Import this function.
# Move `RGB_MAP` in the importable script.
const NO_COLOR_BEYOND: number = 255
# for some reason, 231 is whiter than 255
const MAX_WHITE: number = 231
export def Highlight(
    group: string,
    afg: number,
    abg: number,
    style = ''
)
    # Necessary sanitization.{{{
    #
    # We don't always pass simple numbers to the current function.
    # Sometimes, we pass it an expression whose value is computed at runtime.
    # But there is no  color beyond 255.  So, if a  computation goes beyond 255,
    # we need to fall back on a valid color.
    #
    # We  should not  fall back  on any  value.   255 is  a white  color in  the
    # grayscale ramp; we should choose an even more white color.
    #}}}
    var fg: number = afg > NO_COLOR_BEYOND ? MAX_WHITE : afg
    var bg: number = abg > NO_COLOR_BEYOND ? MAX_WHITE : abg

    #     execute 'highlight SpellBad   gui=undercurl guisp=' .. RGB_MAP[168]
    #     execute 'highlight SpellCap   gui=undercurl guisp=' .. RGB_MAP[110]
    #     execute 'highlight SpellLocal gui=undercurl guisp=' .. RGB_MAP[153]
    #     execute 'highlight SpellRare  gui=undercurl guisp=' .. RGB_MAP[218]

    if fg == -1
        execute printf('highlight %s ctermfg=NONE guifg=NONE', group)
    elseif fg != 0
        execute printf('highlight %s ctermfg=%s guifg=%s', group, fg, get(RGB_MAP, fg, 'NONE'))
    endif

    if bg == -1
        execute printf('highlight %s ctermbg=NONE guibg=NONE', group)
    elseif bg != 0
        execute printf('highlight %s ctermbg=%s guibg=%s', group, bg, get(RGB_MAP, bg, 'NONE'))
    endif

    if style != ''
        execute printf('highlight %s term=%s cterm=%s gui=%s', group, style, style, style)
    endif
enddef

# `'background'` needs to bet set *before* `:highlight clear`.{{{
#
# `:highlight clear` causes `$VIMRUNTIME/syntax/syncolor.vim` to be sourced.
# The latter needs to know what kind  of color scheme you're going to use; light
# or dark.  And for this information  to be always correct, `'background'` needs
# to be set *before*, not after.
#}}}
&background = 'light'
highlight clear
# Do *not* try to set `g:colors_name` earlier.{{{
#
# It's automatically cleared by `:highlight clear`.
#}}}
g:colors_name = 'seoul'

# FIXME: Run `:source %`:
#
#     Error detected while processing /home/lgc/.vim/pack/mine/opt/seoul/colors/seoul.vim:
#     line  119:
#     E1041: Redefining script item highlights
#
# I think that when the previous `&background = 'light'` is run, `highlights` is
# set.  But I don't understand why there is an error.
var highlights: list<dict<any>>

Highlight('Normal', FG, current_bg)

Highlight('LineNr', 101, current_bg - 2)
# useful when `'relativenumber'`
util.Link('LineNrAbove', 'DiffDelete')
Highlight('Visual', 0, 152)
Highlight('VisualNOS', 0, 152)

Highlight('Comment', 65, 0)
util.Link('CommentListItem', 'Repeat')
Highlight('CommentBlockquote', STATEMENT_FG, 0)
Highlight('CommentListItemBlockquote', STATEMENT_FG, 0)

Highlight('CommentBold', 65, 0, 'bold')
Highlight('CommentItalic', 65, 0, 'italic')
Highlight('CommentBoldItalic', 65, 0, 'bold,italic')
Highlight('CommentListItemBold', REPEAT_FG, 0, 'bold')
Highlight('CommentListItemItalic', REPEAT_FG, 0, 'italic')
Highlight('CommentListItemBoldItalic', REPEAT_FG, 0, 'bold,italic')
Highlight('CommentBlockquoteBold', STATEMENT_FG, 0, 'bold')
Highlight('CommentBlockquoteItalic', STATEMENT_FG, 0, 'italic')
Highlight('CommentBlockquoteBoldItalic', STATEMENT_FG, 0, 'bold,italic')
Highlight('CommentCodeSpan', 65, TABLINE_BG + 2)
Highlight('CommentListItemCodeSpan', REPEAT_FG, TABLINE_BG + 2)
Highlight('CommentBlockquoteCodeSpan', STATEMENT_FG, TABLINE_BG + 2)
Highlight('markdownCodeSpan', 0, TABLINE_BG + 2)
Highlight('CommentQuotationMarks', STATEMENT_FG, 0)

Highlight('CommentUnderlined', 65, 0, 'underline')

util.Link('CommentKey', 'Special')
# `Type` is what the help syntax plugin uses.
util.Link('CommentOption', 'Type')
# `Delimiter` seems to be the most meaningful choice.{{{
#
# From `:help group-name`:
#
#    > Delimiter character that needs attention
#}}}
util.Link('CommentPointer', 'Delimiter')
util.Link('CommentRule', 'Delimiter')
util.Link('CommentTable', 'Structure')

Highlight('Number', 95, 0)
Highlight('Float', 95, 0)
Highlight('Boolean', 166, 0)
Highlight('String', 30, 0)
Highlight('Constant', 23, 0)
Highlight('Character', 30, 0)
Highlight('Delimiter', 94, 0)
Highlight('StringDelimiter', 94, 0)
Highlight('Statement', STATEMENT_FG, 0)
# case, default, etc.
# highlight Label ctermfg=

# if else end
Highlight('Conditional', 31, 0)

# while end
Highlight('Repeat', REPEAT_FG, 0)
Highlight('Todo', 125, BG_2)
Highlight('Function', 58, 0)

# Macros
Highlight('Define', 131, 0)
Highlight('Macro', 131, 0)
Highlight('Include', 131, 0)
Highlight('PreCondit', 131, 0)


# #!
Highlight('PreProc', 58, 0)

# @abc
Highlight('Identifier', 96, 0)

# AAA Abc
Highlight('Type', 94, 0)

# + - * / <<
Highlight('Operator', 131, 0)

# super yield
Highlight('Keyword', 168, 0)

# raise
Highlight('Exception', 161, 0)
Highlight('Structure', 23, 0)

Highlight('Error', BG_1, 174)
Highlight('ErrorMsg', BG_1, 168)
Highlight('Underlined', 31, 0, 'underline')

# set textwidth=80
# set colorcolumn=+1
Highlight('ColorColumn', 0, current_bg - 2)

# set cursorline cursorcolumn
Highlight('CursorLine', 0, current_bg - 1)
Highlight('CursorLineNr', 131, current_bg - 1)
Highlight('CursorColumn', 0, current_bg - 1)

Highlight('Directory', 95, 0)

Highlight('DiffAdd',    -1, 151)
Highlight('DiffDelete', -1, 181)
# `DiffChange` adds too much noise.{{{
#
# When you compare  two windows in diff mode, `DiffChange`  is used to highlight
# the text which has *not* changed on a line which *has* changed.
# I don't care about the text which didn't change.
# It adds visual clutter.
#}}}
highlights->add({name: 'DiffChange', cleared: true, linksto: 'NONE'})
Highlight('DiffText',   -1, 224)

# Only draw 1 vertical line when we split a window vertically (not 2).
util.Link('VertSplit', 'Normal')
Highlight('Folded', 101, current_bg - 2)

# set foldcolumn=1
Highlight('FoldColumn', 94, current_bg - 2)

Highlight('MatchParen', 0, current_bg - 3)

# -- INSERT --
Highlight('ModeMsg', 173, 0)

# let &showbreak = '> '
Highlight('NonText', 145, 0)

Highlight('MoreMsg', 173, 0)

# Popup menu
Highlight('Pmenu', 238, 224)
Highlight('PmenuSel', BG_MIN, 89)
Highlight('PmenuSbar', 0, 65)
Highlight('PmenuThumb', 0, 23)

Highlight('Search', 255, 74)
Highlight('IncSearch', 220, 238)
util.Link('CurSearch', 'IncSearch')

# String delimiter, interpolation
Highlight('Special', 173, 0)

# :map, listchars
util.Link('SpecialKey', 'Special')

if has('gui_running')
    execute 'highlight SpellBad   gui=undercurl guisp=' .. RGB_MAP[168]
    execute 'highlight SpellCap   gui=undercurl guisp=' .. RGB_MAP[110]
    execute 'highlight SpellLocal gui=undercurl guisp=' .. RGB_MAP[153]
    execute 'highlight SpellRare  gui=undercurl guisp=' .. RGB_MAP[218]
else
    # Red / Blue / Cyan / Magenta
    Highlight('SpellBad', 168, -1, 'underline')
    Highlight('SpellCap', 110, -1, 'underline')
    Highlight('SpellLocal', 153, -1, 'underline')
    Highlight('SpellLocal', 218, -1, 'underline')
endif

Highlight('StatusLine', 95, 187)
Highlight('StatusLineNC', current_bg - 2, TABLINE_BG - 6)
Highlight('StatusLineTerm', 95, 187, 'bold,reverse')
Highlight('StatusLineTermNC', current_bg - 2, 238, 'bold,reverse')
util.Link('StatusLineArgList', 'Title')
Highlight('User1', 95, 187, 'bold')
Highlight('User2', 187, 125, 'bold')
Highlight('TabLineFill', current_bg - 2, 0)
Highlight('TabLineSel', 187, 66)
# We need `NONE` because we don't want `TabLine` to be reset with the underline attribute.{{{
#
# That can happen when `:highlight clear` is run.
#
# Note that it's not reset by some runtime script.
# It's reset right from some C code.
#
# You can see when it happens like so:
#
#     :highlight clear TabLine
#     :debug highlight clear
#     :highlight TabLine        xxx cleared
#     TabLine        xxx cleared˜
#     >step
#     >highlight TabLine
#     TabLine        xxx term=underline cterm=underline ...˜
#                             ^-------^       ^-------^
#}}}
Highlight('TabLine', current_bg - 12, TABLINE_BG, 'NONE')

Highlight('WildMenu', 95, 184)

# We need `NONE` because we don't want `Title` to be reset with the bold attribute.
Highlight('Title', 88, 0, 'NONE')
# Those are custom HGs that we need in our markdown syntax plugin.
Highlight('TitleBold', 88, 0, 'bold')
Highlight('TitleItalic', 88, 0, 'italic')
Highlight('TitleBoldItalic', 88, 0, 'bold,italic')
Highlight('QuotationMarks', STATEMENT_FG, 0)

Highlight('Question', 88, 0)

# Search hit bottom
Highlight('WarningMsg', WARNINGMSG_FG, 0)

# Sign column
Highlight('SignColumn', 173, current_bg)

# Diff
Highlight('diffAdded',   65, 0)
Highlight('diffRemoved', 131, 0)
util.Link('diffLine', 'Constant')

Highlight('Conceal', FG - 2, current_bg + 2)
Highlight('Ignore',  current_bg - 3, current_bg)

# Why `ctermbg=NONE` and `guibg=NONE`?{{{
#
# To make `CursorLine` transparent in case of a conflict between two HGs.
# It happens when `'cursorline'` is set,  and the *background* of the text under
# the cursor is highlighted by a syntax item.
#}}}
# It's not visible enough!{{{
#
# Add the bold value:
#
#     highlight CursorLine cterm=bold,underline gui=bold,underline ctermbg=NONE guibg=NONE
#                                ^--^               ^--^
#}}}
highlight CursorLine cterm=underline gui=underline ctermbg=NONE guibg=NONE
highlight CursorLineNr cterm=NONE

# It is not always easy to read the selected entry in a popup menu (created with `popup_menu()`).{{{
#
# Especially when the  text is already highlighted (either  via text properties,
# or via `win_execute(id, 'set syntax=foo')`).
#
# Indeed,  the  default  color  is  set  by `PmenuSel`  which  is  ok  when  the
# surrounding background  is highlighted by  `Pmenu`; but there is  no guarantee
# that `Pmenu` will be  used.  It can be overridden in any  given popup with the
# `highlight` key; often, it's overridden with `Normal`.
# And `PmenuSel`  on `Normal`  doesn't look great.   OTOH, `Visual`  should look
# better.
#}}}
util.Link('PopupSelected', 'Visual')
# We need a HG to draw signs in a popup window.{{{
#
# `WarningMsg` is a good fit for that, but there's one issue.
# If  we  use  `WarningMsg`  to  define  a  sign  via  `sign_define()`,  Vim
# highlights the  foreground of the  screen cells with `WarningMsg`  but the
# background with `Pmenu`, because our color scheme only sets the foreground
# color of `WarningMsg`.
#
# This is a bit jarring because:
#
#    - in a popup window, the sign column is highlighted by `SignColumn`
#    - the background of `SignColumn` is identical to `Normal`
#
# So, the background of the sign column is highlighted like `Normal`, except
# where there are signs; in those locations, `Pmenu` is used.
#
# To solve this, we set `PopupSign` with the same colors as `WarningMsg`, except
# the background color which is like `Normal`.
#}}}
Highlight('PopupSign', WARNINGMSG_FG, current_bg)

hlset(highlights)
