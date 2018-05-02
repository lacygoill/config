" Compiler {{{1

" What's `latexmk.pl`?{{{
"
" To compile a LaTeX document, you need a LaTeX compiler backend.
" See `:h vimtex-compiler`.
"
" latexmk.pl is one of them.
" You can download it and read its documentation at:
"
"     http://personal.psu.edu/jcc8//software/latexmk-jcc/
"
" Once the script is downloaded, move it in ~/bin.
"}}}
" What's the purpose of `g:vimtex_compiler_latexmk`?{{{
"
" We can configure `latexmk.pl` via `g:vimtex_compiler_latexmk`.
" The default value of this option can be found at
" `:h g:vimtex_compiler_latexmk`.
"}}}
" How do we configure it?{{{
"
" We tweak it so that:
"
"     • the 'backend' key uses Vim's or Neovim's jobs
"     • the 'executable' key matches the right name of the script
"}}}

let g:vimtex_compiler_latexmk = {
    \ 'backend' : has('nvim') ? 'nvim' : 'jobs',
    \ 'background' : 1,
    \ 'build_dir' : '',
    \ 'callback' : 1,
    \ 'continuous' : 1,
    \ 'executable' : 'latexmk.pl',
    \ 'options' : [
    \      '-pdf',
    \      '-verbose',
    \      '-file-line-error',
    \      '-synctex=1',
    \      '-interaction=nonstopmode',
    \ ],
    \ }

" Mappings {{{1

" Why?{{{
"
" vimtex installs some mappings in insert mode to ease the insertion
" of mathematical commands like `\emptyset`.
" By default, they all use the prefix  backtick, which is annoying because I use
" the latter frequently inside comments.
" So, to avoid the  timeout when we want to insert a backtick,  we use the tilde
" as a prefix.
"
" If you want to test this feature, INSIDE a math environment:
"
"     \begin{displaymath}
"     \end{displaymath}
"
" … insert `~0`, it should be replaced with `\emptyset`.
"
" For more info, see:    :h vimtex-imaps
" And:                   :VimtexImapsList
"}}}
let g:vimtex_imaps_leader = '~'

" Quickfix window {{{1

" Never open the qf window automatically.
" Why?{{{
"
" It can quickly become annoying when you have a minor error you can't fixed.
" Every time you update the file with continuous compilations, the qf window
" will be re-opened.
"}}}
" MWE:{{{
"
"     $ cat /tmp/vimrc
"
"         set rtp^=~/.vim/plugged/vimtex/
"         so $HOME/.vim/autoload/plugin_conf/vimtex.vim
"         filetype plugin indent on
"
"     $ cat /tmp/file.tex
"
"         \documentclass{article}
"         \begin{document}
"         \wrong_command
"         \end{document}
"
"     $ vim -Nu /tmp/vimrc
"
"         :e /tmp/file.tex
"         :VimtexCompileSS
"}}}
let g:vimtex_quickfix_mode = 0
let g:vimtex_quickfix_open_on_warning = 0

" Miscellaneous {{{1

" Why?{{{
"
" Depending on the contents of a `.tex` file, Vim may set the filetype to:
"
"     • plain
"     • context
"     • latex
"
" I want 'latex' no matter what.
" See: ft-tex-plugin
"}}}
let g:tex_flavor = 'latex'

" Vimtex ships with an improved version of `matchparen`.
" I don't want it.
let g:vimtex_matchparen_enabled = 0
" TODO: matchup{{{
"
" By default, `vimtex` highlights  matching delimiters, including LaTex specific
" ones, which `matchparen` does not.
" We disable this for the moment, because it's noisy by default.
" I prefer to enable such a feature temporarily on-demand.
" Anyway, there's a better alternative which integrates with `vimtex`:
"
"         vim-matchup
"
" See `:lh g:matchup_override_vimtex`
"
" Try   to  install   vim-matchup,  read   its  doc,   and  integrate   it  with
" vimtex.   You  may  be  able   to  enable  matchup  temporarily  by  resetting
" `b:matchup_matchparen_enabled` and reloading the buffer.
"}}}

