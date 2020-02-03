if exists('g:loaded_fzf') || stridx(&rtp, 'fzf.vim') == -1
    finish
endif

" For more information about the available settings, read `:h fzf` *and* `:h fzf-vim`.

" Variables{{{1

fu s:snr() abort
    return matchstr(expand('<sfile>'), '.*\zs<SNR>\d\+_')
endfu
let s:snr = get(s:, 'snr', s:snr())

" Do *not* use `{'window': 'split'}`!{{{
"
" Otherwise, in  Neovim, when you  invoke an fzf  Ex command (like  `:FZF`), you
" will have 2 windows with an identical terminal buffer.
"}}}
" I have an issue!{{{
"
" See this: https://github.com/junegunn/fzf/issues/1055
"}}}
let g:fzf_layout = {'window': 'call '..s:snr..'fzf_window(0.9, 0.6, "Comment")'}
" Source: https://github.com/junegunn/fzf/blob/master/README-VIM.md#starting-fzf-in-neovim-floating-window
fu s:fzf_window(width, height, border_highlight) abort
    " Size and position
    let width = float2nr(&columns * a:width)
    let height = float2nr(&lines * a:height)
    let row = float2nr((&lines - height) / 2)
    let col = float2nr((&columns - width) / 2)

    " Border
    let top = '╭' . repeat('─', width - 2) . '╮'
    let mid = '│' . repeat(' ', width - 2) . '│'
    let bot = '╰' . repeat('─', width - 2) . '╯'
    let border = [top] + repeat([mid], height - 2) + [bot]

    let args1 = [a:border_highlight, {'row': row, 'col': col, 'width': width, 'height': height}]
    let args2 = ['Normal', {'row': row + 1, 'col': col + 2, 'width': width - 4, 'height': height - 2}]
    if has('nvim')
        " Draw frame
        let frame = call('s:create_float', args1)
        call nvim_buf_set_lines(frame, 0, -1, v:true, border)
        "                              │   │  │{{{
        "                              │   │  └ out-of-bounds indices should be an error
        "                              │   │
        "                              │   └ up to the last line
        "                              │
        "                              │     actually `-1` stands for the index *after* the last line,
        "                              │     but since this argument is exclusive, here,
        "                              │     `-1` matches the last line
        "                              │
        "                              └ start replacing from the first line
        " }}}
        " Draw viewport
        call call('s:create_float', args2)
    else
        let frame = call('s:create_popup_window', args1)
        call setbufline(frame, 0, border)
        call call('s:create_popup_window', args2)
    endif

    " Wipe frame buffer when viewport is quit
    exe 'au BufWipeout <buffer> bw!'..frame
endfu

if has('nvim')
    fu s:create_float(hl, opts) abort
        "                         ┌ not listed ('buflisted' off){{{
        "                         │        ┌ scratch buffer
        "                         │        │}}}
        let buf = nvim_create_buf(v:false, v:true)
        " What's the effect of `relative: editor`?{{{
        "
        " It sets the window layout to "floating", placed at (row,col) coordinates
        " relative to the global editor grid.
        "}}}
        "   What about `style: minimal`?{{{
        "
        " It displays  the window  with many UI  options disabled  (e.g. 'number',
        " 'cursorline', 'foldcolumn', ...).
        "}}}
        let opts = extend({'relative': 'editor', 'style': 'minimal'}, a:opts)
        let win = nvim_open_win(buf, v:true, opts)
        "                            │{{{
        "                            └ enter the window (to make it the current window)
        "}}}
        call setwinvar(win, '&winhighlight', 'NormalFloat:'..a:hl)
        call setwinvar(win, '&colorcolumn', '')
        return buf
    endfu
else
    fu s:create_popup_window(hl, opts) abort
        " TODO: Implement sth equivalent for Vim.{{{
        "
        " Not possible right now:
        " https://github.com/vim/vim/issues/4063#issuecomment-565808502
        "
        " Update: It should be possible starting from 8.2.0191.
        " However, I don't know how to make fzf use the popup window.
        " It seems fzf uses whatever window has the focus when it's invoked, and
        " a Vim popup window never has the focus.
        "}}}
        " FIXME: report crash.{{{
        "
        " Start Vim.
        " Press `SPC fr`.
        " Press `Esc`.
        " Press `C-\ C-n`.
        " Press `!w`.
        "}}}

        "     let top = '┌'..repeat('─', width - 2)..'┐'
        "     let mid = '│'..repeat(' ', width - 2)..'│'
        "     let bot = '└'..repeat('─', width - 2)..'┘'
        "     let border = [top] + repeat([mid], height - 2) + [bot]
        "     let line = ((&lines - height) / 2) - 1
        "     let col = (&columns - width) / 2
        "     call popup_create(border, #{
        "         \ line: line,
        "         \ col: col,
        "         \ minwidth: width,
        "         \ minheight: height,
        "         \ mask: [[col-8, col+width-11, line-2, line+height-5]]})

        let buf = term_start(&shell, #{hidden: 1})
        call popup_create(buf, #{
            \ line: a:opts.row,
            \ col: a:opts.col,
            \ minwidth: a:opts.width,
            \ minheight: a:opts.height,
            \ })
        return buf
        exe 'au BufWipeout * ++once bw!'..buf
    endfu
endif

let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-s': 'split',
    \ 'ctrl-v': 'vsplit',
    \ }

" When we use `:[Fz]Buffers`, and we select a buffer which is already displayed
" in a window, give the focus to it, instead of loading it in the current one.
let g:fzf_buffers_jump = 1

let g:fzf_command_prefix = 'Fz'

" Commands{{{1

" How do I toggle the preview window?{{{
"
" Press `?`.
" If you want to use another key:
"
"     fzf#vim#with_preview("right:50%:hidden", "?")
"                                               ^
"                                               change this
"}}}
" Where did you find this command?{{{
"
" For the most part, at the end of `:h fzf-vim-advanced-customization`.
"
" We've also tweaked it to make fzf ignore the first three fields when filtering.
" That is the file path, the line number, and the column number.
" More specifically, we pass to `fzf#vim#with_preview()` this dictionary:
"
"     {"options": "--delimiter=: --nth=4.."}
"
" Which, in turn, pass `--delimiter: --nth=4..` to `fzf(1)`.
"
" See: https://www.reddit.com/r/vim/comments/b88ohz/fzf_ignore_directoryfilename_while_searching/ejwn384/
"}}}
exe 'com -bang -nargs=* '..g:fzf_command_prefix..'Rg
    \ call fzf#vim#grep(
    \   "rg 2>/dev/null --column --line-number --no-heading --color=always --smart-case "..shellescape(<q-args>), 1,
    \   <bang>0 ? fzf#vim#with_preview({"options": "--delimiter=: --nth=4.."}, "up:60%")
    \           : fzf#vim#with_preview({"options": "--delimiter=: --nth=4.."}, "right:50%:hidden", "?"),
    \   <bang>0)'

exe 'com -bang -nargs=? -complete=dir '
    \ ..g:fzf_command_prefix..'Files call fzf#vim#files(<q-args>, fzf#vim#with_preview("right:50%"), <bang>0)'

" `:FzSnippets` prints the description of the snippets (✔), but doesn't use it when filtering the results (✘).{{{

" The  issue  is  due to  `:FzSnippets`  which  uses  the  `-n 1`  option  in  the
" `'options'` key of a dictionary.
" To fix this, we replace `-n 1` with `-n ..`.
" From `man fzf`:
"
"     /OPTIONS
"     /Search mode
"     -n, --nth=N[,..]
"           Comma-separated list of field  index expressions for limiting search
"           scope.  See FIELD INDEX EXPRESSION for the details.
"
"     /FIELD INDEX EXPRESSION
"     ..     All the fields
"}}}
exe 'com -bar -bang '..g:fzf_command_prefix..'Snippets call fzf#vim#snippets({"options": "-n .."}, <bang>0)'

" Autocmds{{{1

augroup fzf_open_folds
    au!
    " press `zv` the next time Vim has nothing to do, *after* a buffer has been displayed in a window
    if !has('nvim')
        au FileType fzf au BufWinEnter * ++once au SafeState * ++once norm! zv
    else
        " Why the `mode()` guard?{{{
        "
        " To avoid this issue when we execute an fzf command twice:
        "
        "     Error detected while processing function <lambda>443:
        "     line    1:
        "     Can't re-enter normal mode from terminal mode
        "}}}
        au FileType fzf au BufWinEnter * ++once call timer_start(0, {-> mode() is# 'n' && execute('norm! zv')})
    endif
augroup END

" Mappings{{{1

exe 'nno <silent> <space>fmn :<c-u>'..g:fzf_command_prefix..'Maps<cr>'
nmap <space>fmi i<plug>(fzf-maps-i)
nmap <space>fmx v<plug>(fzf-maps-x)
nmap <space>fmo y<plug>(fzf-maps-o)
" don't press `fm` (search for next `m` character) if we cancel `SPC fm`
nno <space>fm<esc> <nop>

fu s:fuzzy_mappings() abort
    nno <silent> <space>fF :<c-u>FZF $HOME<cr>

    let key2cmd = {
        \ 'M' : 'Marks',
        \ 'R' : 'Rg',
        \ 'bt': 'BTags',
        \ 'c' : 'Commands',
        \ 'f' : 'Files',
        \ 'gf': 'GFiles',
        "\ `gC` for Git Changed files
        \ 'gC': 'GFiles?',
        \ 'h' : 'Helptags',
        "\ `l` for :ls (listing)
        \ 'l' : 'Buffers',
        \ 'r' : 'History',
        "\ `:FzSnippets` only returns snippets whose tab trigger contains the text before the cursor
        \ 's' : 'Snippets',
        \ 't' : 'Tags',
        \ 'w' : 'Windows',
        \ }

    for [char, cmd] in items(key2cmd)
        exe 'nno <silent> <space>f'..char..' :<c-u>'..g:fzf_command_prefix..cmd..'<cr>'
    endfor

    augroup remove_gvfs_from_oldfiles
        au!
        " Rationale:{{{
        "
        " If you've opened ftp files with Vim:
        "
        "     $ gvim ftp://ftp.vim.org/pub/vim/patches/8.0/README
        "
        " `v:oldfiles` will contain filepaths such as:
        "
        "     /run/user/1000/gvfs/ftp:host=ftp.vim.org/pub/vim/patches/8.0/README
        "
        " Those kind of paths make `:FzHistory` slow to start.
        " This is because the command  calls `filereadable()`, and the latter is
        " slow on such a path:
        "
        "     :Time echo filereadable('~/.bashrc')
        "     :Time echo filereadable('/run/user/1000/gvfs/ftp:host=ftp.vim.org/pub/vim/patches/8.0/README')
        "
        " The first command is instantaneous.
        " The second command takes more than a tenth of a second.
        "
        " And the  effect is cumulative: the  more paths like the  previous one,
        " the slower `:FzHistory` opens its fzf window.
        "
        " The value of `v:oldfiles` is built from the viminfo file.
        " The latter is read after our vimrc, so we can't clean `v:oldfiles` right now.
        " We need to wait for Vim to have fully started up.
        "}}}
        au VimEnter * call filter(v:oldfiles, {_,v -> v !~# '/gvfs/'})
    augroup END
endfu
call s:fuzzy_mappings()

nno <silent> <space>fgc :<c-u>call <sid>fuzzy_commits('')<cr>
nno <silent> <space>fgbc :<c-u>call <sid>fuzzy_commits('B')<cr>
fu s:fuzzy_commits(char) abort
    let cwd = getcwd()
    " To use `:FzBCommits` and `:FzCommits`, we first need to be in the working tree of the repo:{{{
    "
    "    - in which the current file belongs
    "
    "    - in which we are interested;
    "      let's say, again, the one where the current file belong
    "}}}
    noa exe 'lcd '..fnameescape(expand('%:p:h'))
    exe g:fzf_command_prefix..a:char..'Commits'
    noa exe 'lcd '..cwd
endfu

" Why not `C-r C-r`?{{{
"
" Already taken (`:h c^r^r`).
"}}}
" Why not `C-r C-r C-r` ?{{{
"
" Would cause a timeout when we press `C-r C-r` to insert a register literally.
"}}}
cno <expr> <c-r><c-h>
\    getcmdtype() =~ ':' ?  '<c-e><c-u>'..g:fzf_command_prefix..'History:<cr>'
\  : getcmdtype() =~ '[/?]' ? '<c-e><c-u><c-c>:'..g:fzf_command_prefix..'History/<cr>' : ''
"                                        ^^^^^
"                                        don't use `<esc>`; an empty pattern would search for the last pattern
"                                        and raise an error if it can't be found

