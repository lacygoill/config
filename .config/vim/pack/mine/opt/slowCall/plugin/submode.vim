vim9script noclear

if exists('loaded') || stridx(&runtimepath, '/submode,') == -1
    finish
endif
var loaded = true

import autoload 'submode.vim'

# Normal mode {{{1
# ]o   (prefix) {{{2
# ]oC {{{3

def CurrentCompiler(): string
    return &l:makeprg->matchstr('\S\+')
enddef

execute submode.Enter('compiler', 'n', 'r', '[oC', '<Plug>([oC)', CurrentCompiler)
execute submode.Enter('compiler', 'n', 'r', ']oC', '<Plug>(]oC)', CurrentCompiler)

# ]oD {{{3

execute submode.Enter('diff-everything', 'n', 'r', '[oD', '<Plug>([oD)')
execute submode.Enter('diff-everything', 'n', 'r', ']oD', '<Plug>(]oD)')

# ]oL {{{3

execute submode.Enter('cursorline', 'n', 'r', '[oL', '<Plug>([oL)')
execute submode.Enter('cursorline', 'n', 'r', ']oL', '<Plug>(]oL)')

# ]oc {{{3

execute submode.Enter('conceal-level', 'n', 'r', '[oc', '<Plug>([oc)')
execute submode.Enter('conceal-level', 'n', 'r', ']oc', '<Plug>(]oc)')

# ]od {{{3

execute submode.Enter('diff', 'n', 'r', '[od', '<Plug>([od)')
execute submode.Enter('diff', 'n', 'r', ']od', '<Plug>(]od)')

# ]oh {{{3

execute submode.Enter('hlsearch', 'n', 'r', '[oh', '<Plug>([oh)')
execute submode.Enter('hlsearch', 'n', 'r', ']oh', '<Plug>(]oh)')

# ]oi {{{3

execute submode.Enter('invisible-chars', 'n', 'r', '[oi', '<Plug>([oi)')
execute submode.Enter('invisible-chars', 'n', 'r', ']oi', '<Plug>(]oi)')

# ]ol {{{3

execute submode.Enter('lightness', 'n', 'r', '[ol', '<Plug>([ol)')
execute submode.Enter('lightness', 'n', 'r', ']ol', '<Plug>(]ol)')

# ]on {{{3

execute submode.Enter('number', 'n', 'r', '[on', '<Plug>([on)')
execute submode.Enter('number', 'n', 'r', ']on', '<Plug>(]on)')

# ]op {{{3

execute submode.Enter('matchparen', 'n', 'r', '[op', '<Plug>([op)')
execute submode.Enter('matchparen', 'n', 'r', ']op', '<Plug>(]op)')

# ]oq {{{3

execute submode.Enter('formatprg', 'n', 'r', '[oq', '<Plug>([oq)')
execute submode.Enter('formatprg', 'n', 'r', ']oq', '<Plug>(]oq)')

# ]os {{{3

execute submode.Enter('spell', 'n', 'r', '[os', '<Plug>([os)')
execute submode.Enter('spell', 'n', 'r', ']os', '<Plug>(]os)')

# ]ot {{{3

execute submode.Enter('foldtitle', 'n', 'r', '[ot', '<Plug>([ot)')
execute submode.Enter('foldtitle', 'n', 'r', ']ot', '<Plug>(]ot)')

# ]ov {{{3

execute submode.Enter('virtualedit', 'n', 'r', '[ov', '<Plug>([ov)')
execute submode.Enter('virtualedit', 'n', 'r', ']ov', '<Plug>(]ov)')

# ]ow {{{3

execute submode.Enter('wrap', 'n', 'r', '[ow', '<Plug>([ow)')
execute submode.Enter('wrap', 'n', 'r', ']ow', '<Plug>(]ow)')

# ]oz {{{3

execute submode.Enter('auto-open-folds', 'n', 'r', '[oz', '<Plug>([oz)')
execute submode.Enter('auto-open-folds', 'n', 'r', ']oz', '<Plug>(]oz)')
#}}}2
# ]    (prefix) {{{2
# ]`        codespans {{{3

execute submode.Enter('codespans', 'nx', 'r', ']`', '<Plug>(next-codespan)')
execute submode.Enter('codespans', 'nx', 'r', '[`', '<Plug>(prev-codespan)')

# ]'       marks {{{3

execute submode.Enter('marks', 'nx', '', "['", "['")
execute submode.Enter('marks', 'nx', '', "]'", "]'")

# ]"       comments {{{3

execute submode.Enter('comments', 'nx', 'r', ']"', '<Plug>(next-comment)')
execute submode.Enter('comments', 'nx', 'r', '["', '<Plug>(prev-comment)')

# ])       unmatched parens {{{3

execute submode.Enter('unmatched-parens', 'n', '', '])', '])')
execute submode.Enter('unmatched-parens', 'n', '', '[(', '[(')

# ]}       unmatched brackets {{{3

execute submode.Enter('unmatched-brackets', 'n', '', ']}', ']}')
execute submode.Enter('unmatched-brackets', 'n', '', '[{', '[{')

# ][       sections {{{3

# Commented because it's often used by accident, while we're trying to re-enter a submode.
#
#     execute submode.Enter('sections', 'n', '', '][', '][')
#     execute submode.Enter('sections', 'n', '', '[]', '[]')

# ]/       C comments {{{3

# `]*` is a synonym.
execute submode.Enter('C-comments', 'n', '', ']/', ']/')
execute submode.Enter('C-comments', 'n', '', '[/', '[/')

# ]#       preproc directives {{{3

execute submode.Enter('directives', 'nx', '', ']#', ']#')
execute submode.Enter('directives', 'nx', '', '[#', '[#')

# ]-       horizontal rules {{{3

execute submode.Enter('horizontal-rules', 'nx', 'r', ']-', '<Plug>(next-rule)')
execute submode.Enter('horizontal-rules', 'nx', 'r', '[-', '<Plug>(prev-rule)')

# ];       locations {{{3

execute submode.Enter('locations', 'nx', 'r', '];', '<Plug>(next-location)')
execute submode.Enter('locations', 'nx', 'r', '[;', '<Plug>(prev-location)')

# ]a       arglist {{{3

execute submode.Enter('arglist', 'n', 'r', ']a', '<Plug>(next-file-in-arglist)')
execute submode.Enter('arglist', 'n', 'r', '[a', '<Plug>(prev-file-in-arglist)')

# ]c       diff changes {{{3

execute submode.Enter('diff-changes', 'nx', '', ']c', ']c')
execute submode.Enter('diff-changes', 'nx', '', '[c', '[c')

# ]e       move line {{{3

execute submode.Enter('mv-line', 'n', 'r', ']e', '<Plug>(mv-line-below)')
execute submode.Enter('mv-line', 'n', 'r', '[e', '<Plug>(mv-line-above)')

# ]f       files {{{3

execute submode.Enter('files', 'n', 'r', ']f', '<Plug>(next-file)')
execute submode.Enter('files', 'n', 'r', '[f', '<Plug>(prev-file)')

# ]h       paths {{{3

execute submode.Enter('paths', 'nx', 'r', ']h', '<Plug>(next-path)')
execute submode.Enter('paths', 'nx', 'r', '[h', '<Plug>(prev-path)')

# ]l       location list {{{3

def PosInLocationList(): string
    var size: number = getloclist(0, {size: 0}).size
    if size == 0
        return ''
    endif
    var pos: number = getloclist(0, {idx: 0}).idx
    return pos .. '/' .. size
enddef

execute submode.Enter('location-list', 'n', 'r', ']l', '<Plug>(next-entry-in-loclist)', PosInLocationList)
execute submode.Enter('location-list', 'n', 'r', '[l', '<Plug>(prev-entry-in-loclist)', PosInLocationList)

# ]M       end of methods {{{3

execute submode.Enter('methods-end', 'n', '', ']M', ']M')
execute submode.Enter('methods-end', 'n', '', '[M', '[M')

# ]m       start of methods {{{3

execute submode.Enter('methods-start', 'n', '', ']m', ']m')
execute submode.Enter('methods-start', 'n', '', '[m', '[m')

# ]q       quickfix list {{{3

def PosInQuickfixList(): string
    var size: number = getqflist({size: 0}).size
    if size == 0
        return ''
    endif
    var pos: number = getqflist({idx: 0}).idx
    return pos .. '/' .. size
enddef

execute submode.Enter('quickfix-list', 'n', 'r', ']q', '<Plug>(next-entry-in-qfl)', PosInQuickfixList)
execute submode.Enter('quickfix-list', 'n', 'r', '[q', '<Plug>(prev-entry-in-qfl)', PosInQuickfixList)

# ]r       reference links {{{3

execute submode.Enter('reference-links', 'nx', 'r', ']r', '<Plug>(next-reference-link)')
execute submode.Enter('reference-links', 'nx', 'r', '[r', '<Plug>(prev-reference-link)')

# ]S       scroll line {{{3

execute submode.Enter('scroll-line', 'n', 'r', ']S', '<Plug>(scroll-line-fwd)')
execute submode.Enter('scroll-line', 'n', 'r', '[S', '<Plug>(scroll-line-bwd)')

# ]s       bad words {{{3

execute submode.Enter('bad-words', 'nx', '', ']s', ']s')
execute submode.Enter('bad-words', 'nx', '', '[s', '[s')

# ]t       tag stack {{{3

def PosInTagstack(): string
    var tagstack: dict<any> = gettagstack()
    if tagstack.length == 0
        return ''
    endif
    var size: number = tagstack.length
    var pos: number = tagstack.curidx
    return pos .. '/' .. size
enddef

execute submode.Enter('tag-stack', 'n', 'r', ']t', '<Plug>(next-tag)', PosInTagstack)
execute submode.Enter('tag-stack', 'n', 'r', '[t', '<Plug>(prev-tag)', PosInTagstack)

# ]U       concealed urls {{{3

execute submode.Enter('concealed-urls', 'nx', 'r', ']U', '<Plug>(next-concealed-url)')
execute submode.Enter('concealed-urls', 'nx', 'r', '[U', '<Plug>(prev-concealed-url)')

# ]u       urls {{{3

execute submode.Enter('urls', 'nx', 'r', ']u', '<Plug>(next-url)')
execute submode.Enter('urls', 'nx', 'r', '[u', '<Plug>(prev-url)')

# ]z       folds {{{3

execute submode.Enter('folds', 'nx', 'r', ']z', '<Plug>(next-fold)')
execute submode.Enter('folds', 'nx', 'r', '[z', '<Plug>(prev-fold)')

# ] C-l    files in location list {{{3

execute submode.Enter('files-in-loclist', 'n', 'r', ']<C-L>', '<Plug>(next-file-in-loclist)', PosInLocationList)
execute submode.Enter('files-in-loclist', 'n', 'r', '[<C-L>', '<Plug>(prev-file-in-loclist)', PosInLocationList)

# ] C-q    files in quickfix list {{{3

execute submode.Enter('files-in-qfl', 'n', 'r', ']<C-Q>', '<Plug>(next-file-in-qfl)', PosInQuickfixList)
execute submode.Enter('files-in-qfl', 'n', 'r', '[<C-Q>', '<Plug>(prev-file-in-qfl)', PosInQuickfixList)
#}}}2
# `>`    (prefix) {{{2
# `>l`       stack of location lists {{{3

def PosInLoclistStack(): string
    var size: number = getloclist(0, {nr: '$'}).nr
    if size == 0
        return ''
    endif
    var pos: number = getloclist(0, {nr: 0}).nr
    return pos .. '/' .. size
enddef

execute submode.Enter('loclists-stack', 'n', 'r', '>l', '<Plug>(next-loclist)', PosInLoclistStack)
execute submode.Enter('loclists-stack', 'n', 'r', '<l', '<Plug>(prev-loclist)', PosInLoclistStack)

# `>q`       stack of location lists {{{3

def PosInQuickfixStack(): string
    var size: number = getqflist({nr: '$'}).nr
    if size == 0
        return ''
    endif
    var pos: number = getqflist({nr: 0}).nr
    return pos .. '/' .. size
enddef

execute submode.Enter('qflists-stack', 'n', 'r', '>q', '<Plug>(next-qflist)', PosInQuickfixStack)
execute submode.Enter('qflists-stack', 'n', 'r', '<q', '<Plug>(prev-qflist)', PosInQuickfixStack)
#}}}2
# g    (prefix) {{{2
# g, g;         changelist {{{3

def PosInChangelist(): string
    var changelist: list<any> = getchangelist('%')
    if changelist[0]->empty()
        return ''
    endif
    var pos: number = changelist[1]
    var size: number = changelist[0]->len() - 1
    return pos .. '/' .. size
enddef

execute submode.Enter('changelist', 'n', 'r', 'g;', '<Plug>(next-change)', PosInChangelist)
execute submode.Enter('changelist', 'n', 'r', 'g,', '<Plug>(prev-change)', PosInChangelist)

# gt gT         move tab page {{{3

execute submode.Enter('move-tabpage', 'n', 'r', 'gt', '<Plug>(move-tabpage-fwd)')
execute submode.Enter('move-tabpage', 'n', 'r', 'gT', '<Plug>(move-tabpage-bwd)')

# gj gk         vertical jump {{{3

execute submode.Enter('vertical-jump', 'nx', 'r', 'gj', '<Plug>(vertical-jump-fwd)')
execute submode.Enter('vertical-jump', 'nx', 'r', 'gk', '<Plug>(vertical-jump-bwd)')
#}}}2
# C-w  (prefix) {{{2
# C-w g[hjkl]    tradewinds {{{3

execute submode.Enter('tradewinds', 'n', 'r', '<C-W>gh', '<Plug>(tradewinds-h)')
execute submode.Enter('tradewinds', 'n', 'r', '<C-W>gj', '<Plug>(tradewinds-j)')
execute submode.Enter('tradewinds', 'n', 'r', '<C-W>gk', '<Plug>(tradewinds-k)')
execute submode.Enter('tradewinds', 'n', 'r', '<C-W>gl', '<Plug>(tradewinds-l)')

# C-w [rR]       rotate windows {{{3

execute submode.Enter('rotate-window', 'n', '', '<C-W>r', '<C-W>r')
execute submode.Enter('rotate-window', 'n', '', '<C-W>R', '<C-W>R')
#}}}2
# !e             help last errors {{{2

# cycle through help topics relevant for last errors
execute submode.Enter('help-last-errors', 'n', 'r', '!e', '<Plug>(help-last-errors)')

# s C-a          switchable tokens {{{2

execute submode.Enter('switchable-tokens', 'nx', 'r', 's<C-A>', '<Plug>(next-switchable-token)')
execute submode.Enter('switchable-tokens', 'nx', 'r', 's<C-X>', '<Plug>(prev-switchable-token)')

# M-m [jk]       quickhl {{{2

var prefix: string
if &t_TI != "\<Esc>\\[>4;[12]m" || &term =~ 'kitty' || has('gui_running')
    prefix = '<M-M>'
else
    import 'lg/mapping.vim'
    prefix = mapping.KEY2FUNC.m
endif

execute submode.Enter('quickhl', 'n', 'r', prefix .. 'j', '<Plug>(quickhl-jump-to-next-hl)')
execute submode.Enter('quickhl', 'n', 'r', prefix .. 'k', '<Plug>(quickhl-jump-to-prev-hl)')

# z C-[hjkl]     resize windows {{{2

execute submode.Enter('resize-window', 'n', 'r', 'z<C-H>', '<Plug>(window-resize-h)')
execute submode.Enter('resize-window', 'n', 'r', 'z<C-J>', '<Plug>(window-resize-j)')
execute submode.Enter('resize-window', 'n', 'r', 'z<C-K>', '<Plug>(window-resize-k)')
execute submode.Enter('resize-window', 'n', 'r', 'z<C-L>', '<Plug>(window-resize-l)')
#}}}1
# Insert mode {{{1
# C-g [<>]       indent {{{2

# We lost the ability to change the level of indentation on the line.
# Because we prefer to use `C-d` and `C-t` with their readline meanings.
# So, we remap the Vim default `C-d` and `C-t`, to `C-g <` and `C-g >`.
# Besides, these key sequences make much more sense, imho.
#
# Also, make the mappings repeatable without the prefix `C-g`.

execute submode.Enter('change-indent', 'i', '', '<C-G>>', '<C-T>')
execute submode.Enter('change-indent', 'i', '', '<C-G><', '<C-D>')

# C-x [jk]       duplicate char below/above {{{2

execute submode.Enter('char-around', 'i', 'r', '<C-X>j', '<Plug>(duplicate-char-below)' )
execute submode.Enter('char-around', 'i', 'r', '<C-X>k', '<Plug>(duplicate-char-above)' )
#}}}1
