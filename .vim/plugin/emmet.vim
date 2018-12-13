if exists('g:loaded_emmet') || stridx(&rtp, 'emmet-vim') == -1
    finish
endif

" Options {{{1

" We don't want global mappings. We prefer buffer-local ones.
let g:user_emmet_install_global = 0

" We only need mappings in insert and visual mode (not normal).
let g:user_emmet_mode = 'iv'

" We use `C-g` as a prefix key instead of `C-y`.
let g:user_emmet_leader_key = '<c-g>'

" https://github.com/mattn/emmet-vim/issues/378#issuecomment-329839244
"
" Issue1: Sometimes it's annoying:{{{
"
"     • write a url and press `C-g a`
"     • expand this abbreviation:    #page>div.logo+ul#navigation>li*5>a{Item $}
"}}}
" Issue2: It can break `C-g N` (jump to previous point).{{{
" The issue is in this function:
"
"     emmet#lang#html#moveNextPrev()
"
" From this file:
"     $HOME/.vim/plugged/emmet-vim/autoload/emmet/lang/html.vim:887
"
" The pattern is right, but sometimes, it needs to be searched twice
" instead of once.
"
"}}}
let g:user_emmet_settings = {
    \     'html': {
    \         'block_all_childless' : 1,
    \     },
    \ }

" For more options see:
"     ~/.vim/plugged/emmet-vim/autoload/emmet.vim:999
"
" The keys of the first level are names of filetypes.
" The keys of the second level are names of abbreviations, snippets and options.

" Autocmds {{{1

augroup my_emmet
    au!
    au FileType css,html  call s:install_mappings()
    " enable emmet mappings in our notes about web-related technologies (html, css, emmet, ...){{{
    "
    " TODO:
    " However, maybe we could enable them to all markdown files...
    "
    "     au FileType css,html,markdown  call s:install_mappings()
    "                          ^^^^^^^^
    "}}}
    au BufReadPost,BufNewFile  */wiki/web/*.md  call s:install_mappings()
augroup END

" Functions {{{1
fu! s:install_mappings() abort "{{{2
    " The default mappings are not silent (and they probably don't use `<nowait>` either).
    " We prefer to make them silent.

    " Why this guard?{{{
    "
    " We need `:EmmetInstall` later at the end of the function.
    " But if we disable `emmet.vim`, it won't exist.
    " Besides, if  `emmet.vim` is disabled,  there's no point in  installing the
    " next mappings (C-g, ...).
    "}}}
    if exists(':EmmetInstall') !=# 2
        return
    endif

    " Where did you find all the `{rhs}`?{{{
    "
    "     :h emmet-customize-key-mappings
    "}}}
    " Why `C-g C-u` instead of simply `C-g u`? {{{
    "
    " To  avoid a  conflict with  the default  `C-g u`  command (:h  i^gu) which
    " breaks the undo sequence.
    "}}}
    " Same question for `C-g C-[jkm]`.{{{
    "
    " To  avoid a  conflict with  our custom mappings:
    "
    "     C-g j    scroll window downward
    "     C-g k    scroll window upward
    "     C-g m    :FzMaps
    "}}}

    imap  <buffer><nowait><silent>  <c-g>,      <plug>(emmet-expand-abbr)
    imap  <buffer><nowait><silent>  <c-g>;      <plug>(emmet-expand-word)
    imap  <buffer><nowait><silent>  <c-g><c-u>  <plug>(emmet-update-tag)
    " mnemonics: `s` for select
    imap  <buffer><nowait><silent>  <c-g>s      <plug>(emmet-balance-tag-inward)
    imap  <buffer><nowait><silent>  <c-g>S      <plug>(emmet-balance-tag-outword)
    "                                                                        ^ necessary typo
    imap  <buffer><nowait><silent>  <c-g>n      <plug>(emmet-move-next)
    imap  <buffer><nowait><silent>  <c-g>N      <plug>(emmet-move-prev)
    imap  <buffer><nowait><silent>  <c-g>i      <plug>(emmet-image-size)
    imap  <buffer><nowait><silent>  <c-g>/      <plug>(emmet-toggle-comment)
    imap  <buffer><nowait><silent>  <c-g><c-j>  <plug>(emmet-split-join-tag)
    imap  <buffer><nowait><silent>  <c-g><c-k>  <plug>(emmet-remove-tag)
    imap  <buffer><nowait><silent>  <c-g>a      <plug>(emmet-anchorize-url)
    imap  <buffer><nowait><silent>  <c-g>A      <plug>(emmet-anchorize-summary)

    xmap  <buffer><nowait><silent>  <c-g>,      <plug>(emmet-expand-abbr)
    xmap  <buffer><nowait><silent>  <c-g>;      <plug>(emmet-expand-word)
    xmap  <buffer><nowait><silent>  <c-g><c-u>  <plug>(emmet-update-tag)
    xmap  <buffer><nowait><silent>  <c-g>s      <plug>(emmet-balance-tag-inward)
    xmap  <buffer><nowait><silent>  <c-g>S      <plug>(emmet-balance-tag-outword)
    xmap  <buffer><nowait><silent>  <c-g>n      <plug>(emmet-move-next)
    xmap  <buffer><nowait><silent>  <c-g>N      <plug>(emmet-move-prev)
    xmap  <buffer><nowait><silent>  <c-g>i      <plug>(emmet-image-size)
    xmap  <buffer><nowait><silent>  <c-g>/      <plug>(emmet-toggle-comment)
    xmap  <buffer><nowait><silent>  <c-g><c-j>  <plug>(emmet-split-join-tag)
    xmap  <buffer><nowait><silent>  <c-g><c-k>  <plug>(emmet-remove-tag)
    xmap  <buffer><nowait><silent>  <c-g>a      <plug>(emmet-anchorize-url)
    xmap  <buffer><nowait><silent>  <c-g>A      <plug>(emmet-anchorize-summary)

    " these 2 mappings are specific to visual mode
    xmap  <buffer><nowait><silent>  <c-g><c-m>  <plug>(emmet-merge-lines)
    xmap  <buffer><nowait><silent>  <c-g>p      <plug>(emmet-code-pretty)

    " now, we also need to install the `<plug>` mappings
    EmmetInstall
    " Would this work if I lazy-loaded emmet?{{{
    "
    " No.
    "
    " Its interface would not be installed until we read an html or css file.
    " So, the  first time  we would  read an html  or css  file, `:EmmetInstall`
    " would  not exist,  and we  couldn't use  it here  to install  the `<plug>`
    " mappings.
    "}}}
    " Would there be solutions?{{{
    "
    " You could execute `:EmmetInstall` from a filetype plugin:
    "
    "     if exists(':EmmetInstall') ==# 2
    "         EmmetInstall
    "     endif
    "
    " When a  filetype plugin is sourced,  it seems the interface  of the plugin
    " would  be finally  installed (contrary  to  when the  current function  is
    " sourced).
    " Or you could install a fire-once autocmd to slightly delay the execution
    " of `:EmmetInstall`:
    "
    "     augroup my_emmet_install
    "         au!
    "         au BufWinEnter * if index(['html', 'css'], &ft) >= 0 | EmmetInstall | endif
    "         \ | exe 'au! my_emmet_install' | aug! my_emmet_install
    "     augroup END
    "}}}
    " Why don't you lazy-load emmet?{{{
    "
    " emmet starts already  quickly (less than a fifth  of millisecond), because
    " the core of its code is autoloaded.
    "
    " Besides, we would need to write the same code in different filetype plugins
    " (violate DRY, DIE).
    "
    " Finally, we've had enough issues with lazy-loading in the past.
    " I prefer to avoid it as much as possible now.
    " It's a hack anyway, and you should use  it only as a last resort, and only
    " if the plugin is slow to start because it hasn't been autoloaded:
    "
    "     “Premature optimization is the root of all evil.“
    "}}}

    call s:set_undo_ftplugin()
endfu

fu! s:set_undo_ftplugin() abort "{{{2
    let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
        \ . (empty(get(b:, 'undo_ftplugin', '')) ? '' : '|')
        \ . "
        \   exe 'iunmap <buffer> <c-g>,'
        \ | exe 'iunmap <buffer> <c-g>;'
        \ | exe 'iunmap <buffer> <c-g><c-u>'
        \ | exe 'iunmap <buffer> <c-g>s'
        \ | exe 'iunmap <buffer> <c-g>S'
        \ | exe 'iunmap <buffer> <c-g>n'
        \ | exe 'iunmap <buffer> <c-g>N'
        \ | exe 'iunmap <buffer> <c-g>i'
        \ | exe 'iunmap <buffer> <c-g>/'
        \ | exe 'iunmap <buffer> <c-g><c-j>'
        \ | exe 'iunmap <buffer> <c-g><c-k>'
        \ | exe 'iunmap <buffer> <c-g>a'
        \ | exe 'iunmap <buffer> <c-g>A'
        \
        \ | exe 'xunmap <buffer> <c-g>,'
        \ | exe 'xunmap <buffer> <c-g>;'
        \ | exe 'xunmap <buffer> <c-g><c-u>'
        \ | exe 'xunmap <buffer> <c-g>s'
        \ | exe 'xunmap <buffer> <c-g>S'
        \ | exe 'xunmap <buffer> <c-g>n'
        \ | exe 'xunmap <buffer> <c-g>N'
        \ | exe 'xunmap <buffer> <c-g>i'
        \ | exe 'xunmap <buffer> <c-g>/'
        \ | exe 'xunmap <buffer> <c-g><c-j>'
        \ | exe 'xunmap <buffer> <c-g><c-k>'
        \ | exe 'xunmap <buffer> <c-g>a'
        \ | exe 'xunmap <buffer> <c-g>A'
        \ | exe 'xunmap <buffer> <c-g><c-m>'
        \ | exe 'xunmap <buffer> <c-g>p'
        \ "
endfu

