vim9script noclear

if exists('loaded') || stridx(&runtimepath, '/sneak,') == -1
    finish
endif
var loaded = true

# Mappings {{{1
# How to find the mappings installed by `vim-sneak` in{{{
# }}}
#   normal mode?{{{
#
#     :new | vim9cmd execute('nmap')
#         ->split('\n')
#         ->filter((_, v) => v =~ '\csneak' && v !~ '^\cn\s\+\%([ft,;]\\|<Plug>\)')
#         ->setline(1)
#
# We invoke `filter()` to ignore:
#
#    - the `<Plug>` mappings (they can't be typed directly,
#      so they can't interfer in our work)
#
#    - [fFtT,;]
#      we ignore those because, contrary to  [sSzZ]  , they ARE consistent
#}}}
#   visual mode?{{{
#
#     :new | vim9cmd execute('xmap')
#         ->split('\n')
#         ->filter((_, v) => v =~ '\csneak' && v !~ '^\cx\s\+\%([ft,;]\\|<Plug>\)')
#         ->setline(1)
#}}}
#   operator-pending mode?{{{
#
#     :new | vim9cmd execute('omap')
#         ->split('\n')
#         ->filter((_, v) => v =~ '\csneak' && v !~ '^\co\s\+\%([ft,;]\\|<Plug>\)')
#         ->setline(1)
#}}}

for key: string in ['f', 'F', 't', 'T', 'ss', 'SS', ';', ',']
    execute 'nnoremap ' .. key .. ' <ScriptCmd>FTS("' .. key[0] .. '")<CR>'
    execute 'xnoremap ' .. key .. ' <ScriptCmd>FTS("' .. key[0] .. '")<CR>'
    # operator-pending mappings don't seem to work with our `FTS()`
    execute 'omap ' .. key .. ' <Plug>Sneak_' .. key[0]
endfor

def FTS(cmd: string)
    # if we jump into a closed fold, open it
    autocmd CursorMoved * ++once normal! zv
    # now, jump
    feedkeys(v:count1 .. "\<Plug>Sneak_" .. cmd, 'i')
enddef

# Variables {{{1

# Repeat via `;` or `,` always goes forward or backward respectively,
# no matter the previous command (`f`, `F`, `t`, `T`, `s`, `S`).
const g:sneak#absolute_dir = 1

# Case sensitivity is determined by 'ignorecase' and 'smartcase'.
const g:sneak#use_ic_scs = 1

# Label-mode minimizes the steps to jump to a location, using a clever interface
# similar to vim-easymotion[2].
# Sneak label-mode is faster, simpler, and more predictable than vim-easymotion.

# To enable label-mode:
#
#     const g:sneak#label = 1
