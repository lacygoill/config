" Options 1 {{{1

" Do *not* use two config files; one for Nvim (init.vim), and one for Vim (vimrc).{{{
"
" We did that  in the past; and we  included a `:so ~/.vim/vimrc` at  the end of
" the init.vim.  But this lead to many issues.
"
" Just use one file (at the Vim or  Nvim location), and create a symlink for the
" other editor.  KISS.
"}}}

if has('nvim') && has('vim_starting')
    " https://neovim.io/doc/user/nvim.html#nvim-from-vim
    set rtp^=~/.vim
    set rtp+=~/.vim/after
    " Do *not* do this `ln -s ~/.vim/after ~/.config/nvim/after`!{{{
    "
    " Neovim automatically includes `~/.config/nvim/after` in the rtp.
    "
    " So,  if   you  symlink  the   latter  to  `~/.vim/after`,  AND   manually  add
    " `~/.vim/after` to the rtp, `~/.vim/after` will be effectively present twice.
    " Because of that, the filetype plugins will be sourced twice, which will cause errors.
    " For example, `b:undo_ftplugin` will often contain 2 unmap commands for the same key.
    " The 2nd time, the command will fail because the mapping has already been deleted.
    "
    " Summary:
    " one of them work as expected, but not both:
    "
    "     :set rtp+=~/.vim/after
    "     $ ln -s ~/.vim/after ~/.config/nvim/after
    "}}}

    " What does it do?{{{
    "
    " It adds to `'pp'`:
    "
    "     ~/.fzf
    "     ~/.vim              because we've manually added it to 'rtp' just before
    "     ~/.vim/after        "
    "     ~/.vim/plugged/*    all directories inside
    "}}}
    let &packpath = &rtp

    " disable Python 2 support (it's deprecated anyway)
    let g:loaded_python_provider = 0
    " Purpose:{{{
    "
    " On Ubuntu 16.04, we've installed the deb package `usrmerge`.
    " As a result, `/bin` is a symlink to `/usr/bin`.
    " So, the python3 interpreter can be found with 2 paths:
    "
    "     /bin/python3
    "     /usr/bin/python3
    "
    " Because of this, `:CheckHealth` contains the following message:
    "
    "    - INFO: Multiple python3 executables found.  Set `g:python3_host_prog` to avoid surprises.
    "    - INFO: Executable: /usr/bin/python3
    "    - INFO: Other python executable: /bin/python3
    "
    " To get rid of the message, we explicitly tell Neovim which path it must use
    " to invoke the python3 interpreter.
    "
    " Also, this provides these additional benefits:
    "
    "    - it helps Neovim find the interpreter faster, which makes startup faster too
    "    - no surprise (Neovim won't use a possible old installation we forgot to remove)
    "    - in case of an issue `:CheckHealth` will give better advice
    "}}}
    let g:python3_host_prog = '/usr/bin/python3'

    " disable Perl, Ruby, and Node.js support (we don't need them, and the less code, the fewer issues)
    let g:loaded_perl_provider = 0
    let g:loaded_ruby_provider = 0
    let g:loaded_node_provider = 0
endif

" Why this setting?{{{
"
" When we use gVim, we don't want `$VIMRUNTIME/menu.vim` to be sourced.
" We won't use the menu. It makes Vim start around 50ms slower.
" https://www.reddit.com/r/vim/comments/5l939k/recommendation_deinvim_as_a_plugin_manager/dbu74zd/
"
" The default value is 'aegimrLtT'.
" We could also let 'go' unchanged, and write this instead:
"
"     let did_install_default_menus = 1
"     let did_install_syntax_menu = 1
"
" In this case, we would keep the menu bar but avoid loading the default menus.
" For more info, see :h menu.vim
"}}}
" Why here, before the plugins, and not after, with the other options?{{{
"
" From `:h 'go-M`:
"
" Note that  this flag  must be added  in the .vimrc  file, before  switching on
" syntax  or filetype  recognition (...;  the  `:syntax on`  and `:filetype  on`
" commands load the menu too). `:filetype on` and `:syntax on` source menu.vim.
"}}}
set guioptions=M

" Plugins {{{1
" Disable plugins {{{2

" I never use these plugins:{{{
"
"    - getscript
"    - logipat
"    - vimball
"
" The less code, the fewer bugs.
" Besides, they install some custom commands which pollute tab completion on the
" command-line.
"}}}
let g:loaded_getscriptPlugin = 1

" https://github.com/neovim/neovim/issues/5040#issuecomment-232151477
let g:loaded_logiPat = 1

" interface + autoload
let g:loaded_vimballPlugin = 1
let g:loaded_vimball = 1

" How to disable netrw?{{{
"
"     " no interface
"     let g:loaded_netrwPlugin = 1
"
"     "no autoload/
"     let g:loaded_netrw = 1
"
" See `:h netrw-noload`.
"}}}
"   Why would it be a bad idea?{{{
"
" `let  g:loaded_netrw =  1`  would  break the  `:Gbrowse`  command provided  by
" `vim-fugitive` and `vim-rhubarb`.
" If the file you're working on is hosted on GitHub, `:Gbrowse` lets you read it
" in your webbrowser.
"
" Although, you could disable `netrw` and still use `:Gbrowse`:
"
"     com -bar -nargs=* Browse sil call system('xdg-open '..shellescape(<q-args>))
"
" `:Browse` is an undocumented feature of `vim-fugitive`.
" See: https://github.com/tpope/vim-fugitive/blob/2564c37d0a2ade327d6381fef42d84d9fad1d057/autoload/fugitive.vim#L3446-L3447
"
" I still prefer to enable `netrw`, because  other plugins may rely on it, and I
" don't want to lose time debugging them.
"
" ---
"
" Update: netrw also allows you to edit a remote file located at an arbitrary url.
"
" For example, if you press `Zf` on this url:
" https://salsa.debian.org/printing-team/cups/raw/debian/master/cups/utf8demo.txt
"
" It will open the `utf8demo.txt` file in a new split.
"
" Same thing with this file:
" ftp://ftp.vim.org/pub/vim/patches/8.1/README
"}}}

" vim-plug:  installation {{{2

" We install vim-plug if it's not already.
"
" To know whether vim-plug is installed or not, we check whether the file:
"
"     ~/.vim/autoload/plug.vim
"
" ... exists.

if empty(glob('~/.vim/autoload/plug.vim'))
    sil !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    au VimEnter * PlugInstall | so $MYVIMRC
endif

" Disable shallow cloning.
"
" We want the full copy of a repo, to see all the commit history.
" Can be explored later with `:[Fz][B]Commits`.
" Useful to understand why a particular change was introduced in a plugin
" without having to go to github.    Cost more bandwidth though.

let g:plug_shallow = 0

" vim-plug:  usage  {{{2

" Why this check?{{{
"
" We shouldn't reload  the interface of all our plugins  every time we re-source
" the vimrc.
" If a plugin is missing a guard, this could have unexpected effects.
"}}}
" Is there a drawback?{{{
"
" Yes.
"
" If you remove  the `Plug` line of  a plugin, `:PlugClean` will  not remove its
" files, because `vim-plug` won't be informed.
" You need to restart Vim.
"}}}
if has('vim_starting')

" Plugins must be declared after this line.
" They will be downloaded inside `~/.vim/plugged/`.
call plug#begin('~/.vim/plugged')

" To Assimilate:
Plug 'lacygoill/vim-abolish', {'branch': 'assimil'}
Plug 'lacygoill/asyncmake', {'branch': 'assimil'}
Plug 'lacygoill/vim-autoread', {'branch': 'assimil'}
Plug 'lacygoill/vim-cheat', {'branch': 'assimil'}
Plug 'lacygoill/vim-cookbook'
Plug 'lacygoill/vim-cwd'
Plug 'lacygoill/vim-debug'
Plug 'junegunn/vim-easy-align'
Plug 'lacygoill/vim-exchange'
Plug 'lacygoill/vim-fex'
Plug 'tpope/vim-fugitive'
" You can pass more arguments to the fzf installer:
"     $ ~/.fzf/install --help
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all --no-bash'}
Plug 'junegunn/fzf.vim'
Plug 'lacygoill/goyo.vim', {'branch': 'assimil'}
Plug 'lacygoill/vim-graph'
" TODO: remove `vim-gutentags`{{{
"
" Use git hooks instead.
" Less code, more control, occasion to better understand git.
"
" https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration
" https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
" https://git-scm.com/docs/githooks
"
" https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html
" https://github.com/tpope/tpope/tree/master/.git_template
" https://github.com/tpope/tpope/blob/master/.gitconfig
"
" Update:
" A file watcher (like entr) may be even better.
" http://eradman.com/entrproject/
" See:
"     ~/bin/entr-reload-browser
"     ~/bin/entr-watch
"
" Try:
"     % ( ls ~/wiki/web/practice/htdocs/*.html | entr entr-reload-browser Firefox &! )
"     % vim ~/wiki/web/practice/htdocs/index.html
"     open the file in firefox too, then edit the file in Vim, then watch the page in firefox
"
" Issue:
" Your tags will be generated only in git projects.
" Not in projects using other VCS systems (`.hg/`, `.bzr/`, ...).
"
" Also:
" Use `entr(1)`  to automatically rename  files whose names contain  spaces, and
" replace them with underscores.
" Don't do that everywhere; just in some specific directories like `~/Downloads/`.
" The purpose  is to  make it  easier for `fasd(1)`  to log  files we  open with
" `mpv(1)`, `zathura(1)`, ...
" Indeed, by default, fasd ignore files  with spaces, unless you quote the name,
" but we always forget to quote it.
"}}}
Plug 'ludovicchabant/vim-gutentags'
Plug 'tweekmonster/helpful.vim'
Plug 'lacygoill/limelight.vim', {'branch': 'assimil'}
Plug 'foxik/vim-makejob'
" TODO: Remove this condition whenever you can.{{{
"
" We should use the neovim `man` plugin even in Vim, because it's better.
" However,  it doesn't  support  our custom  motions such  as  `]r`, and  Nvim's
" folding is not as good as Vim folding.
" So, we'll need to add those features when we re-implement the plugin.
"
" Also, remove `~/.vim/plugin/man.vim` once you use your own man plugin.
"
" Also:
"
"     $ nvim
"     :PlugClean
"     Directories to delete:~
"     - ~/.vim/plugged/vim-man/~
"
" Because of this `!has('nvim')` condition, we  run the risk of locally deleting
" the plugin by accident when we run `:PlugClean` from Nvim.
" No big deal, unless we have uncommitted changes...
"
" ---
"
" When you  re-implement the man  plugin, make sure  to support motions  such as
" `]r`, and commands such as `C-]`.
"}}}
if !has('nvim')
    Plug 'lacygoill/vim-man'
endif
Plug 'lacygoill/vim-markdown'
Plug 'andymass/vim-matchup'
Plug 'lacygoill/vim-quickhl', {'branch': 'assimil'}
Plug 'lacygoill/vim-repeat', {'branch': 'assimil'}
Plug 'tpope/vim-rhubarb'
" Alternative: https://github.com/t9md/vim-textmanip
Plug 'lacygoill/vim-schlepp'
Plug 'junegunn/seoul256.vim'
Plug 'justinmk/vim-sneak'
Plug 'lacygoill/vim-submode', {'branch': 'assimil'}
Plug 'lacygoill/vim-tmux', {'branch': 'assimil'}
Plug 'lacygoill/vim-tmuxify', {'branch': 'assimil'}
" Alternative: https://github.com/vim/vim/pull/3220#issuecomment-538651011
Plug 'andymass/vim-tradewinds'
Plug 'lacygoill/vim-unix'

" Done:
Plug 'lacygoill/vim-awk'
Plug 'lacygoill/vim-brackets'
Plug 'lacygoill/vim-breakdown'
Plug 'lacygoill/vim-bullet-list'
Plug 'lacygoill/vim-capslock'
Plug 'lacygoill/vim-cmdline'
Plug 'lacygoill/vim-column-object'
Plug 'lacygoill/vim-comment'
Plug 'lacygoill/vim-completion'
Plug 'lacygoill/vim-doc'
Plug 'lacygoill/vim-draw'
Plug 'lacygoill/vim-fold'
Plug 'lacygoill/vim-freekeys'
Plug 'lacygoill/vim-git'
Plug 'lacygoill/vim-gx'
Plug 'lacygoill/vim-help'
Plug 'lacygoill/vim-hydra'
Plug 'lacygoill/vim-iabbrev'
Plug 'lacygoill/vim-interactive-lists'
Plug 'lacygoill/vim-latex'
Plug 'lacygoill/vim-lg-lib'
Plug 'lacygoill/vim-logevents'
Plug 'lacygoill/vim-math'
Plug 'lacygoill/vim-my-fzf'
Plug 'lacygoill/vim-par'
Plug 'lacygoill/vim-qf'
Plug 'lacygoill/vim-readline'
Plug 'lacygoill/vim-reorder'
Plug 'lacygoill/vim-repmap'
Plug 'lacygoill/vim-save'
Plug 'lacygoill/vim-search'
Plug 'lacygoill/vim-selection-ring'
Plug 'lacygoill/vim-session'
Plug 'lacygoill/vim-sh'
Plug 'lacygoill/vim-snippets'
Plug 'lacygoill/vim-source'
Plug 'lacygoill/vim-stacktrace'
Plug 'lacygoill/vim-statusline'
Plug 'lacygoill/vim-xterm'
Plug 'lacygoill/vim-terminal'
Plug 'lacygoill/vim-cookbook'
Plug 'lacygoill/vim-titlecase'
Plug 'lacygoill/vim-toggle-settings'
Plug 'lacygoill/vim-unichar'
Plug 'machakann/vim-Verdin'
Plug 'lacygoill/vim-vim'
Plug 'lacygoill/vim-window'
Plug 'lacygoill/vim-xkb'

" Read Doc:
Plug 'justinmk/vim-dirvish'
Plug 'mattn/emmet-vim'
Plug 'machakann/vim-sandwich'
Plug 'SirVer/ultisnips'
Plug 'lervag/vimtex'

" Other:
Plug 'mbbill/undotree'
Plug 'chrisbra/unicode.vim'

" Some functions installing an interface are  too slow to be called during Vim's
" startup. We delay them.
fu s:delay_slow_call() abort
    au! delay_slow_call
    aug! delay_slow_call
    runtime autoload/toggle_settings.vim
    runtime! autoload/slow_call/*.vim
endfu

augroup delay_slow_call
    au!
    " Do *not* use a simple timer:{{{
    "
    "     au VimEnter * call timer_start(1000, {->
    "         \       execute('runtime  autoload/toggle_settings.vim
    "         \ |              runtime! autoload/slow_call/*.vim', '')
    "         \ })
    "
    " It could cause issues, for example, if you enter insert mode quickly (i.e.
    " before  the  callback),  and  some  custom  code  of  yours  rely  on  the
    " lazy-loaded interface.
    "
    " If you  still have issues because  you execute some normal  command before
    " the lazy-loaded  interface has  been installed, maybe  try to  add another
    " event to the autocmd.
    "}}}
    " Before adding an event to the list, make sure it doesn't increase Vim's startup time.{{{
    "
    " In particular, avoid `SafeState`, `VimEnter`, `BufEnter`.
    "
    " ---
    "
    " When you check with `--startuptime`, don't make Vim execute `:q` automatically:
    "
    "                                                ✘
    "                                                vv
    "     $ rm /tmp/log ; vim --startuptime /tmp/log +q && vim /tmp/log
    "
    " It could give numbers which are much lower than what you'll experience.
    " It  depends on  the events  you  listen to;  e.g.  if you  only listen  to
    " `CursorMoved`,  the  numbers  are  much  lower  when  you  make  Vim  quit
    " automatically, compared to when you quit manually.
    "
    " So, make sure to quit manually:
    "
    "     $ rm /tmp/log ; vim --startuptime /tmp/log
    "     :q
    "     $ vim /tmp/log
    "}}}
    let s:events =<< trim END
        CursorHold
        InsertEnter
        WinEnter
        CmdWinEnter
        BufReadPost
        BufWritePost
        QuickFixCmdPost
        TextYankPost
        TextChanged
    END
    exe 'au '..join(s:events, ',')..' * call s:delay_slow_call()' | unlet! s:events
    " Do *not* call the function when we enter debug mode.
    " It could raise spurious errors when we debug Vim (`$ vim -D`).
    au CmdlineEnter :,/,\?,@ call s:delay_slow_call()
augroup END

call plug#end()
endif
" }}}1
" Options 2 {{{1
" Encoding {{{2
" Why should you leave this section at the top of our options configurations.{{{
"
" If for some reason (shell environment), 'encoding' = 'latin1', and we use an
" exotic character in our vimrc, it will raise an error. As an example, see
" the value we give to 'listchars'.
" We need to make sure that Vim will use 'utf-8' as an encoding as soon as
" possible. Note that the real important option to avoid an error during
" startup, isn't 'termencoding', but 'encoding'.
"}}}

" Sets the character encoding used inside Vim.{{{
"
" It applies  to text in  the buffers,  registers, Strings in  expressions, text
" stored in the viminfo file, etc.
" It sets the kind of characters which Vim can work with.
" It  also   automatically  enables   saner  encoding  detection   settings  for
" 'fileencodings':
"
" https://vi.stackexchange.com/a/17326/17449
"}}}
" To avoid errors, we could also write:{{{
"
"     scriptencoding utf-8
"
" This would tell Vim to convert the following lines in our vimrc to utf-8.
" But setting `'encoding'`  seems to have a broader scope,  and hence be better,
" as I  want every file  sourced after  the vimrc to  be read using  the `utf-8`
" encoding (ex: filetype plugins).
"}}}
set encoding=utf-8

" Encoding used for the terminal.  This specifies what character
" encoding the keyboard produces and the display will understand.
if !has('nvim')
    set termencoding=utf-8
endif

" Ftplugins + Syntax {{{2

" Commented because we don't need this anymore.{{{
"
" `vim-plug` already does it for us.
" I keep this section in case it might be necessary if one day we change our plugin
" manager.
"
" From: https://github.com/junegunn/vim-plug/wiki/faq
"
" >     vim-plug does not require any extra statement other than plug#begin()
" >     and plug#end(). You can remove filetype off, filetype plugin indent on
" >     and syntax on from your .vimrc as they are automatically handled by
" >     plug#begin() and plug#end().
"
" See also: https://github.com/junegunn/vim-plug/issues/83
"}}}
" filetype plugin indent on

" Why do you comment this?{{{
"
" `vim-plug` already does it.
"}}}
" Why the guard?{{{
"
" To avoid syntax plugins to be reloaded every time we source our vimrc.
"}}}
" Why not `if !exists('g:syntax_on')`?{{{
"
" A global variable seems more brittle.
" It could be wrongly deleted.
"}}}
"     if has('vim_starting')
"         syntax enable
"     endif

" Styled Comments {{{2

" The position of this section is important.{{{
"
" It should be processed *after* the syntax mechanism has been enabled.
" That is, after `:syntax enable` or after `vim-plug` has done its job.
" Otherwise, the syntax elements it installs would be cleared.
"}}}
" Sometimes, the styles are not applied anymore!{{{
"
" In your config files and plugins, look for `syntax on` or `syntax enable`.
" Whenever  you  run   one  of  these  commands,  you  need   to  reinstall  our
" `styled_comments` autocmd, so that it  runs *after* the default syntax plugins
" have been sourced; add this line right after `syntax on`:
"
"     call s:styled_comments()
"}}}
fu s:styled_comments() abort
    " Why do you include `help`?{{{
    "
    " We sometimes  lose the  conceal in a  help window, when  the help  file is
    " already displayed in another window.
    " Including `help` in this list fixes the issue, because `'cole'` is applied
    " from an autocmd listening to `BufWinEnter`.
    "}}}
    let s:styled_comments_filetypes =<< trim END
        awk
        c
        cheat
        conf
        css
        desktop
        dircolors
        gitconfig
        help
        html
        lua
        nroff
        python
        readline
        sed
        sh
        snippets
        systemd
        tex
        tmux
        vim
        xdefaults
        xkb
        zsh
    END
    augroup styled_comments
        au!
        au FileType * if index(s:styled_comments_filetypes, expand('<amatch>')) >= 0
            \ |     sil! call lg#styled_comment#fold()
            \ |     sil! call lg#styled_comment#undo_ftplugin()
            \ | endif
        au Syntax * if index(s:styled_comments_filetypes, expand('<amatch>')) >= 0
            \ |     sil! call lg#styled_comment#syntax()
            \ | endif
    augroup END
endfu
call s:styled_comments()

" Gui {{{2

if has('gui_running')
    set guifont=DejaVu\ Sans\ Mono\ 20
endif

" Environment "{{{2

" See `~/wiki/shell/environment.md` for an explanation as to why we do that.
call setenv('MANSECT', $MYMANSECT)

" TODO: We should probably remove this assignment.{{{
"
" To create *reliable* links inside a wiki, we should use tags:
" https://stackoverflow.com/q/25742396
"
" Indeed, with  regular links (filepaths),  if we rename  a file, or  change its
" location, we need to refactor all links towards the latter.
" With tags,  we would just  need to re-generate the  tags file with  an autocmd
" listening to `BufWritePost` or sth like that.
"
" The goal  would be to  have tags, like  in help files,  on which we  can press
" `C-]` to automatically jump to an arbitrary location inside the wiki.
" This would also allow us to leverage all built-in commands/functions dedicated
" to tags.
"
" See also:
"
" https://maximewack.com/post/tagbar/
" https://github.com/vimwiki/utils/blob/master/vwtags.py
" https://gist.github.com/MaximeWack/cdbdcd373d68d1fe5b3aca22e3dcfe46
" https://gist.github.com/MaximeWack/388c393b7db290dd732f0a2d403118c5
"
" https://github.com/majutsushi/tagbar
" https://github.com/majutsushi/tagbar/wiki#markdown
" https://github.com/jszakmeister/markdown2ctags
" https://github.com/lvht/tagbar-markdown
"
" http://docs.ctags.io/en/latest/extending.html
" https://gist.github.com/romainl/085b4db4a26a06ec7e16
" https://www.reddit.com/r/vim/comments/4d2fos/if_you_use_tags_whats_your_workflow_like/
" https://jdhao.github.io/2019/10/15/tagbar_markdown_setup/
"
" Update:
"
" Tryt this:
"
"     $ cat <<'EOF' >~/.ctags
"     --langdef=markdown
"     --langmap=markdown:.md
"     --regex-markdown=/|(.*)|/\1/
"     EOF
"
"     $ cd ~/wiki/vim/ ctags -R .
"
" Source: https://stackoverflow.com/a/25742823/9780968
"
" Write `| foobar |` in one of your notes, and one line below write `foobar`.
" Press `C-]` on `foobar`: the cursor jumps onto `| foobar |`.
" But it doesn't work when `foobar` is above `| foobar |`, nor across files...
"}}}
" Used in our notes when we create links between files, in a wiki on a topic.
call setenv('MY_WIKI', $HOME..'/wiki')

if !isdirectory($XDG_RUNTIME_DIR..'/vim')
    call mkdir($XDG_RUNTIME_DIR..'/vim', 'p', 0700)
endif
call setenv('XDG_RUNTIME_VIM', $XDG_RUNTIME_DIR..'/vim')
" For more info about `$XDG_RUNTIME_DIR` and `/run`:
"
" https://standards.freedesktop.org/basedir-spec/latest/ar01s03.html
" https://unix.stackexchange.com/a/316166/289772

" backspace {{{2

" Allow BS, Del, C-w, C-u to delete:
"
"             ┌ whitespace (autoindent)
"             │      ┌ end of line (join line)
"             │      │   ┌ text which was before the cursor when we went
"             │      │   │ into insert mode
"             │      │   │
set backspace=indent,eol,start

" clipboard {{{2
" Do NOT tweak this option!
"         Why could you be tempted to change the value of this option?{{{
"
" When you use a pasting command,  and you don't specify from which register you
" want the text to be pulled, Vim uses the `"` register.
" So, if you want to copy some text from a Vim buffer to Firefox, you'll need to
" explicitly mention the name of the `+` register:
"
"     "+yy
"
" Same thing if you want to paste  in a Vim buffer, some text you've just copied
" in Firefox:
"
"     "+p
"
" It would be convenient to just press `yy` and `p`, and Vim would automatically
" use the system register, instead of the unnamed one.
" That's what 'cb' is for.
"}}}
"         How should you change it?{{{
"
"         set clipboard^=unnamedplus
"
" 'cb' contains a comma-separated list of values. Each stands for a register.
" The previous command PREpends `unnamedplus` to this list.
" `unnamedplus` stands for the system register.
"
" Do NOT execute this:
"
"         set clipboard+=unnamedplus
"
" It would APpend the value to the list.
"}}}
"         Technically, what happens if you do it?{{{
"
" The system  register register will  now have  a similar (although  not exactly
" identical) behavior than the one of the unnamed:
"
"    - it will contain the text of the last changed register (like `"`)
"
"    -  ... except  if  the  last changed  register  was  changed by  a  command
"      containing its explicit name:
"
"         "ayy
"
"      This  is different from `"`,  which always copy  the text of the  last changed
"      register.
"
" If you copy some text in Firefox,  it goes into `+` (regardless of 'cb').  But
" because  of the  new value  of 'cb',  `p` will  automatically paste  `+` (last
" copied text in Firefox).
"
" If you copy  some text in a  Vim buffer, it goes into  `0`. The latter becomes
" the last modified register, and thus  `+` will duplicate its contents (because
" of 'cb').
"
" `"` will still  copy the text of the last changed register:
"
"     set cb^=unnamedplus | let [@+, @"] = ['foo', 'bar'] | norm! p
"     foo~
"
"     set cb&             | let [@+, @"] = ['foo', 'bar'] | norm! p
"     bar~
"}}}
"         Are there pitfalls?{{{
"
" Yes a shitload.
"
" 1. It pollutes the system clipboard after every yank, delete, change.
" 2. It may break a plugin which forgets to temporarily reset 'cb' to its default value.
" 3. It may break a plugin, even if it temporarily resets 'cb'.
"
" Example:
" Consider a buffer, with just the text `pat`.
" Execute this command on the line where `pat` is:
"
"         norm ysiw'
"
" vim-surround should surround `pat` with single quotes.
" Undo, and execute:
"
"         g/pat/norm ysiw'
"
" Nothing happens. The issue:
"
"    - does NOT come the fact that vim-surround forgets to temporarily resets 'cb';
"      vim-surround does NOT forget it
"
"    - is fixed if you don't tweak 'cb' (set cb&vim)
"}}}

" TODO: It would be nice to set the option like this:{{{
"
"     set cb=autoselect,exclude:.*
"                       ^^^^^^^^^^
"
" Because it would slightly reduce startup time.
" For more info, see: https://stackoverflow.com/a/17719528/9780968
" As well as `:h -X` and `:h 'cb`.
"
" ---
"
" The issue is that it prevents  us from using `--servername` (`v:servername` is
" empty even if you start Vim with `--servername FOO`).
" As  a result,  `vim-session`  won't  load the  last  session automatically  on
" startup, because of this guard:
"
"     if v:servername isnot# 'VIM' | return | endif
"
" And we can't send files remotely with `--remote` and friends.
"}}}

" color scheme {{{2

" Be sure to enable `'termguicolors'` *before* sourcing the color scheme.
" We need to inspect the value of  the option to decide how to properly set some
" custom HGs.

" Atm, the only terminals which support true  color on my machine are st, xterm,
" konsole, gnome-terminal and a recent version of urxvt (compiled from source).
" Note that for gnome-terminal to have its TERM set to `gnome-256color`, you need to configure it like so:{{{
"
"     Edit
"     > Profile Preferences
"     > Command
"     > tick "Run a custom command instead of my shell"
"     > inside the "Custom command" field, write "/usr/bin/env TERM=gnome-256color /usr/bin/zsh"
"}}}
" Warning: We include `tmux` as a terminal type in which `'tgc'` can be set, but that's wrong.{{{
"
" We could be running tmux in a terminal which doesn't support true colors.
" To identify the type of the outer terminal, you could inspect:
"
"     :echo system('tmux display -p "#{client_termname}"')
"
" Unfortunately, `system()` would add too much time during startup.
"
" Anyway, in practice, I doubt this will be an issue.
" Most terminals support true colors; and even  if I test one which doesn't from
" time to time, I won't be running tmux inside.
"}}}
if index(map(['gnome', 'konsole', 'rxvt-unicode', 'st', 'tmux', 'xterm'], {_,v -> v..'-256color'}), $TERM) >= 0
    "\ xfce4-terminal lies about its identity
    "\ and doesn't support true color on Ubuntu 16.04
    \ && $COLORTERM isnot# 'xfce4-terminal'
    set termguicolors
    if has('vim_starting') && !has('gui_running') && !has('nvim')
        " In Vim,  if `$TERM`  is not  'xterm', `'t_8f'`  and `'t_8b'`  won't be
        " automatically set; we need to do it manually.
        " See: `:h xterm-true-color`.
        let &t_8f = "\e[38;2;%lu;%lu;%lum"
        let &t_8b = "\e[48;2;%lu;%lu;%lum"
    endif
endif

augroup my_color_scheme
    au!
    au ColorScheme * call colorscheme#customize()

    " What's the issue fixed by this autocommand?{{{
    "
    "     $ cat <<'EOF' >/tmp/markdown.snippets
    "     snippet foo ""
    "         text preceded by 4 leading spaces (!= 1 tab)
    "     endsnippet
    "     EOF
    "
    "     $ vim /tmp/markdown.snippets
    "     ]ol (change lightness)
    "
    " The leading spaces are not highlighted anymore (✘).
    "}}}
    " Where does the issue come from?{{{
    "
    " The `snipLeadingSpaces` HG is cleared when we change the color scheme, because of `:hi clear`:
    "
    "     ~/.vim/plugged/seoul256.vim/colors/seoul256.vim:201
    "
    " More generally, any HG whose attributes  are defined in a syntax plugin is
    " cleared; but the issue doesn't affect linked HGs:
    "
    "     " ✔
    "     :hi [def] link SomeGroup OtherGroup
    "     :hi clear
    "
    "     " ✘
    "     :hi SomeGroup term=... ctermfg=...
    "     :hi clear
    "}}}
    au ColorScheme * call s:reinstall_cleared_hg()
augroup END

fu s:reinstall_cleared_hg() abort
    " Why don't you simply run `:do Syntax`?{{{
    "
    " Suppose you have two windows, one with a python buffer, and the other with
    " an html buffer.
    " You change the color scheme while in the python buffer.
    " The HGs whose attributes are defined in `$VIMRUNTIME/syntax/html.vim` will
    " be cleared.
    " But since you're  in a python buffer, `:do Syntax`  will reload the python
    " syntax plugin, while you need to reload the html syntax plugin.
    "}}}
    " Why don't you manually re-install every cleared HG?{{{
    "
    " It would create duplication.
    " Some HGs would be installed from a syntax plugin, and from this file.
    " If one day their definition is updated  in the syntax plugin, we would have an
    " inconsistency.
    "
    " Besides, we would be constantly chasing new cleared HGs, and even then, we
    " could miss some of them; it's not reliable.
    "}}}
    " Which alternative could I use?{{{
    "
    "     :doautoall syntax
    "
    " But it's too slow when we have a lot of buffers.
    "}}}

    " What does this code do?{{{
    "
    " It iterates over all the windows in all the tabpages.
    " For each  of them,  if it  has never  seen the  filetype of  the displayed
    " buffer, it reloads its syntax plugin.
    "}}}
    " If I have several buffers with the same filetype, don't I need to fire `Syntax` for each of them?{{{
    "
    " No.
    " To re-install the cleared HGs, you just need to reload the syntax plugin once.
    "}}}
    let orig_winid = win_getid()
    let seen = {}
    for info in getwininfo()
        let ft = getbufvar(info.bufnr, '&ft')
        if !has_key(seen, ft)
            let seen[ft] = 1
            if ft isnot# ''
                call win_gotoid(info.winid)
                do Syntax
            endif
        endif
    endfor
    call win_gotoid(orig_winid)
endfu

" Why the guard?{{{
"
"    - there's no point reloading the color scheme every time we source our vimrc
"
"    - without a guard, every time we write the vimrc, the color scheme would
"      be reloaded, which would make us lose syntax highlighting in
"      a `freekeys` buffer, because of `:hi clear`:
"
"         ~/.vim/plugged/seoul256.vim/colors/seoul256.vim:201
"}}}
if has('vim_starting')
    " In a console, we want a readable color scheme.
    if $DISPLAY is# ''
        colo morning
    else
        " What's the purpose of this call?{{{
        "
        " We want to memorize somewhere the  last version of the color scheme we
        " used (atm it's expressed by an ANSI code: 233 ... 239, 252 ... 256).
        "}}}
        " Is there an alternative?{{{
        "
        " Yes.
        " We could use viminfo.
        "
        " Note that  when the vimrc  is read, the viminfo  hasn't been read  yet (:h
        " startup),  so if  you decide  to  use viminfo,  you'll have  to delay  the
        " loading of the color scheme until VimEnter:
        "
        "      au VimEnter * ++nested call s:set_colorscheme()
        "                  │
        "                  └ the autocmds need to nest, so that when we set the color scheme,
        "                    `ColorScheme` is fired, and our customizations are sourced
        "
        " Also, you'll need to use a variable name in uppercase.
        "}}}
        " Why don't you use the alternative?{{{
        "
        " The  alternative requires  that we  delay  the sourcing  of the  color
        " scheme until VimEnter. Besides, the  color scheme executes `:hi clear`
        " which removes any custom HG we may have defined.
        "
        " So, if we delay the color scheme, we must redefine all our custom HGs.
        "
        " But, I can't know in advance all the custom HGs currently defined.
        " It depends on the files which have been read during Vim startup.
        "
        " For example, if  we start Vim to  read a markdown file,  the htmlItalic HG
        " will have been installed to apply the italic style on the text between two
        " asterisks. We need to avoid clearing it right after Vim has been started.
        "}}}
        au my_color_scheme VimLeavePre * call colorscheme#save_last_version()

        " try to restore the exact version of the last color scheme used
        let s:file = $HOME..'/.vim/colors/my/last_version.vim'
        if filereadable(s:file)
            exe 'so '..s:file
            unlet! s:file
        endif
        call colorscheme#set()
    endif
endif

" cmd  mode  ruler{{{2

" When we  move the cursor  (hjkl wbe ...)  and Vim consumes a  lot of cpu  / is
" slow, it can be for 2 reasons:
"
"    - we're inside a deep nested fold:  solution → open folds (zR)
"    - `'showcmd'` is enabled:             solution → disable it

" Even  though it  can have  an impact  on performance,  we enable  `'showcmd'`,
" because sometimes  it's useful to see  what we type. Also, it's  useful to see
" the number of lines inside the visual selection.
set showcmd

" displaying the mode creates noise; and it can erase a message output by `:echo`
set noshowmode

" When  `'stl'` is  empty, Vim  displays the  current line  address, and  column
" number, in the statusline.  This region is called the “ruler bar“ (`:h ruler`).
"
" Even though we should never see it, disable it explicitly.
set noruler

" cms {{{2

" Without the  guard, when  you reload  the vimrc, the  fold titles  display the
" comment leader.
if has('vim_starting')
    set commentstring=
endif

" cpoptions {{{2

" When I type `:r some_file` or `:'<,'>w some_file`, I don't want `some_file`
" to become the alternate file of the current window.
" Update: It's commented. Did we change our mind?
" set cpo-=aA

" Don't ignore escaped parentheses when using the text-object `ib`.{{{
"
" If we hit `dib` while the cursor is on 'O' in the following text:
"
"     (hello \(fOo) world)
"
" We get:
"
"     () world)
"
" For the moment, we prefer that Vim doesn't ignore escaped parentheses:
"
" So instead we get:
"
"     (hello \() world)
"}}}
set cpoptions+=M

" the nr column (`'nu'`,  `'rnu'`) will be taken into account  to decide when to
" wrap long lines
set cpoptions+=n

" allow us to redo a yank command with the dot command
set cpoptions+=y

" When appending to a register, put a line break before the appended text.
set cpoptions+=>

" diffopt {{{2

" Do *not* ignore whitespace, with `iwhiteall`.{{{
"
" It would ignore significant differences.
" For example, in a shell script, this is wrong:
"
"     if [ $? -gt 0]; then
"                  ^
"                  there should be a space
"
" If we have 2 files, one with the error, the other without, we want to see this
" difference.
"
" ---
"
" Do not  ignore trailing whitespace with  `iwhite` either; if they  can somehow
" alter the behavior  of a program, and  we're comparing 2 versions  of the same
" program, one with trailing whitespace on some line, the other without trailing
" whitespace, we need to see this difference to understand what's happening.
"
" ---
"
" If you need to temporarily ignore whitespace differences, use our `co SPC` mapping.
"}}}

" only 3 lines of context above/below a changed line (instead of 6)
set diffopt+=context:3

" use only 1 column for the foldcolumn, instead of 2 (vertical space is precious)
set diffopt+=foldcolumn:1

" turn off diff mode automatically for a buffer which becomes hidden
set diffopt+=hiddenoff

" start diff mode with vertical splits (unless explicitly specified otherwise)
set diffopt+=vertical

" the “patience” algorithm gives more readable diffs
" Why isn't patience the default?{{{
"
" The default algorithm is “myers”.
"
" 1. patience is slower:
"
"     https://marc.info/?l=git&m=133103975225142&w=2
"
" 2. besides:
"
" > Myers has  been the universal  default diff  algorithm for so  long that
" > enabling an alternative algorithm by default in a low-level component of
" > our world (Git, Vim, etc.) could cause issues down the line.
"
" Source: https://www.reddit.com/r/vim/comments/a26phr/the_power_of_diff_vimways_124/eavzmke/
"}}}
set diffopt+=algorithm:patience

" Use the indent heuristic for the internal diff library.
" Again, this gives more readable diffs.
set diffopt+=indent-heuristic
" For more info, see:
" https://vimways.org/2018/the-power-of-diff/

" display {{{2

" When the last line of the window doesn't fit on the screen, Vim replaces it
" with character @. We want Vim to show us as much text as possible from the
" last line and, only when there isn't anymore room, replace the remaining text
" with @.

set display+=lastline

" emoji {{{2

" May fix various issues when editing a line containing some emojis.{{{
"
" See: https://www.youtube.com/watch?v=F91VWOelFNE&t=174s
"
" If you still  have issues in tmux,  you may need to recompile  the latter with
" `--enable-utf8proc`.  Unfortunately, we  have an old `utf8proc`  atm (old OS),
" so we don't do it for now.  See our todo in `~/bin/upp`.
"}}}
set noemoji

" fillchars {{{2

set fillchars&vim

" Replace ugly  separators (`|`)  used for vertical  splits, with  prettier utf8
" characters, to get a continuous line.
set fillchars=vert:┃

" Pad end of title lines with spaces instead of hyphens.
let &fillchars ..= ',fold: '

" flp "{{{2

"                      ┌ recognize numbered lists
"                      ├──────┐
let &g:flp = '\m^\s*\%(\d\+[.)]\|[-*+]\)\s\+'
"                                ├───┘
"                                └ recognize unordered lists

augroup my_default_formatlistpat
    au!
    " We've configured the global value of 'flp'.
    " Do the same for its local value in ANY filetype.
    au FileType * let &l:flp = &g:flp
augroup END

" Is 'flp' used automatically? {{{
"
" No, you also need to include the `n` flag inside 'fo' (we did in `vim-par`).
" This tells Vim to use 'flp' to recognize lists when we use `gw`.
"}}}
" What's the effect?{{{
"
" Some text:
"
"     1. some very long line some very long line some very long line some very long line
"     2. another very long line another very long line another very long line another line
"
" Press `gwip` WITHOUT `n` inside 'fo':
"
"         1. some very long line some very long line some very long line some very
"     long line 2. another very long line another very long line another very long
"     line another line
"
" Press `gwip` WITH `n` inside 'fo', and the right pattern in 'flp':
"
"     1. some very long line some very long line some very long line some very
"        long line
"     2. another very long line another very long line another very long line
"        another line
" }}}
" Why use `let &g:` instead of `setg`? {{{
"
" With `:setg`, you have to double  the backslashes because the value is wrapped
" inside a non-literal string.
"
" Also, you have to add an extra backslash for every pipe character
" (alternation), because one is removed by Vim to toggle its special meaning
" (command separator).
"
" So:    2 backslashes for metacharacters (atoms, quantifiers, ...)
"        3 backslashes for pipes
" }}}
" After pressing `gwip` in a list, how are the lines indented?{{{
"
" The indent of the text after the list header is used for the next line.
"}}}
" Compared to tpope ftplugin, our pattern is simpler. {{{
"
" He has added a third branch to describe a footnote. Sth looking like this:
"
"         ^[abc]:
"
" https://github.com/tpope/vim-markdown/commit/14977fb9df2984067780cd452e51909cf567ee9d
" I don't know how it's useful, so I didn't copy it.
" The title of the commit is:
"
"         Indent the footnotes also.
" }}}
" Don't conflate the `n` flag in 'fo' with the one in 'com'. {{{
"
" There's zero link between the two. This could confuse you:
"
"     setl com=f:-
"     let &l:flp = ''
"
"             - some very long line some very long line some very long line some very long line
"             - another very long line another very long line another very long line another line
"
"     gwip
"             - some very long line some very long line some very long line some
"               very long line
"             - another very long line another very long line another very long
"               line another line
"
" It worked. Vim formatted the list as we wanted. But it's a side effect of `-`
" being recognized as a comment leader, and using the `f` flag.
" For a numbered list, you have to add the `n` flag in 'fo', and include the right
" pattern in 'flp'. Why?
" Because you can't use a pattern inside 'com', only literal strings.
" }}}

" folding {{{2

" When starting  to edit another buffer  in a window, always  start editing with
" all folds closed. Technically, this global option sets the initial local value
" of 'foldlevel' in any window.
set foldlevelstart=0

" do *not* open folds when jumping with "(", "{", "[[", "[{", etc.
set foldopen-=block

" Close a fold even if it doesn't contain any line.
" Useful in our faq notes.
set foldminlines=0

" ft_ignore_pat {{{2

" Purpose:{{{
"
" We don't want `$VIMRUNTIME/filetype.vim` to set  the filetype of a `.log` file
" to `conf` simply because one of its first lines begin with a `#`.
"
" Indeed we often fold some log files using lines beginning with `#`.
"
" ---
"
" Similarly, we don't want a pseudo file in `/proc` – containing the output of a
" shell command – to be highlighted as a conf file just because one of its first
" lines start with a `#`:
"
"     $ vim <(echo "line 1\n# line 2\nline3")
"}}}
" Where did you find the beginning of the value?{{{
"
"     $VIMRUNTIME/filetype.vim:40
"}}}
let g:ft_ignore_pat = '\.\%(Z\|gz\|bz2\|zip\|tgz\|log\)$\|^/proc/'
"                                                 ^^^     ^^^^^^^

" :grep {{{2

" Define rg as the program to call when using the Ex commands: `:[l]grep[add]`.

" What's `-L`?{{{
"
" `--follow`
"
" Follow symbolic links.
" }}}
"     `-S`?{{{
"
" `--smart-case`
"}}}
"     `--vimgrep`?{{{
"
" It disables the color codes in the output (⇔ `--color never`).
" It prevents the matches from being grouped by file (⇔ `--no-heading`).
" It  shows every  match on  its  own line,  including line  numbers and  column
" numbers.
"}}}
set grepprg=rg\ -LS\ --vimgrep\ 2>/dev/null

" Define how the output of rg must be parsed:
"
"               ┌ filename
"               │  ┌ line nr
"               │  │  ┌ column nr
"               │  │  │  ┌ error message
"               │  │  │  │
set grepformat=%f:%l:%c:%m,%f:%l:%m
"   │
"   └ default value:  %f:%l:%m,%f:%l%m,%f  %l%m

" hidden {{{2

" Hide a buffer when it's abandoned (instead of unloading it)

set hidden

" history {{{2

" Remember up to 1000 past commands / search patterns.
set history=1000

" invisible characters {{{2

" We define which symbol Vim must use to display certain symbols:
"
"    ┌────────────────────────┬───────────────────────────────┐
"    │ tab                    │ > or <> or <-> or <--> or ... │
"    ├────────────────────────┼───────────────────────────────┤
"    │ end of line            │ ¬                             │
"    ├────────────────────────┼───────────────────────────────┤
"    │ scroll unwrapped lines │ » «                           │
"    ├────────────────────────┼───────────────────────────────┤
"    │ no-break space         │ ∅                             │
"    └────────────────────────┴───────────────────────────────┘

set listchars=tab:<->,eol:¬,precedes:«,extends:»,nbsp:∅

" includeexpr (gf) {{{2

fu s:snr()
    return matchstr(expand('<sfile>'), '.*\zs<SNR>\d\+_')
endfu
let s:snr = get(s:, 'snr', s:snr())

let &includeexpr = s:snr..'inex()'

fu s:inex() abort
    let line = getline('.')

    " the path could contain an environment variable surrounded by curly brackets
    " What's the purpose of the second branch?{{{
    "
    " Handle the case where the cursor is on the environment variable name:
    "
    "     ${HOME}/bin/README.md
    "      ^^^^^^
    "}}}
    "   The third branch?{{{
    "
    " Handle the case where the cursor is on `$`:
    "
    "     ${HOME}/bin/README.md
    "     ^
    "}}}
    let pat = '\m\C${\f\+}'..'\V'..v:fname..'\m\|${\V'..v:fname..'}\f\+\|\%'..col('.')..'c${\f\+}\f\+'
    "                          │
    "                          └ `v:fname` could contain a tilde
    let cursor_after = '\m\%(.*\%'..col('.')..'c\)\@='
    let cursor_before = '\m\%(\%'..col('.')..'c.*\)\@<='
    let pat1 = cursor_after..pat..cursor_before
    let pat2 = cursor_after..'=\f\+'..cursor_before
    if line =~# pat
        let pat1 = matchstr(line, pat1)
        let env = matchstr(pat1, '\w\+')
        return substitute(pat1, '${'..env..'}', eval('$'..env), '')

    " for lines such as `set option=path`, Vim tries to open `option=path` instead of `path`
    elseif line =~# pat2
        return matchstr(line, pat2)[1:]
    " for lines such as `./relative/path/to/file`{{{
    "
    " especially useful when the buffer has been populated by sth like:
    "
    "     $ find -name '*.rs' | vipe
    "}}}
    elseif line =~# '^\./'
        return substitute(v:fname, '^\./', '', '')
    endif

    return v:fname
endfu

" indentation {{{2

set autoindent
set expandtab
" Why don't you set 'ts'?{{{
"
" It would mess the alignment in help files, where tabs are used with a width of
" 8 cells. Besides, 'ts' is *not* used when 'expandtab' is set.
"}}}

" What's the effect of 'sr'?{{{
"
" When we press:
"
"    - `{count}>>`
"    - `{count}<<`
"    - `>{motion}`
"    - `<{motion}`
"
" ... on indented lines,  if 'sr' is enabled, the new  level of indentation will
" be a multiple of `&sw`.
"
" Ex:
" The current level of indentation is 2, and `&sw` is 4.
" We press `>>`:
"
"    - without `shiftround`, the new indent becomes 6
"    - with    `shiftround`, the new indent becomes 4
"}}}
" Why don't you enable 'sr' anymore?{{{
"
" It seems  to cause an  unexpected result when  we indent a  paragraph (`>ip`),
" some lines  of which  have an  indentation level  which is  not a  multiple of
" `&sw`.
" For more info, see our comments about our custom `>>` mapping.
"}}}
"   Which issue does this cause?{{{
"
" The indentation is not fixed anymore when we do something like `>ip`.
"}}}
"     Is there a solution?{{{
"
" I think you  want 'sr' to be  disabled only for buffers where  you take notes,
" not for code.
"
" Maybe you could install an autocmd (listening to BufEnter?), which would reset
" 'sr' when you enter a markdown buffer.
" Note that 'sr' is global, and not buffer-local unfortunately.
" So, you would have to re-enable 'sr' when you leave a markdown buffer (BufLeave?).
"
" For the moment,  I don't use this  solution because I'm fed up  with the “bug”
" where the relative indentation of a block of lines is lost when we do `>ip`.
" So, I prefer to  let 'sr' disabled by default, and  only enable it temporarily
" when I use `>>` or `<<`.
"
" But you may try later to use autocmds instead if you're curious.
" If this other solution works, you could remove the `>>` and `<<` mappings.
"
" Also, note that you can still fix  the indentation of a block of code with the
" `=` operator.
"}}}
"     set shiftround

" What's the effect of 'sw'?{{{
"
" It controls the number of spaces added/removed when you press:
"
"    - `{count}>>`
"    - `{count}<<`
"    - `>{motion}`
"    - `<{motion}`
"}}}
set shiftwidth=4

" When we press  `Tab` or `BS` in front  of a line, we want  to add/remove `&sw`
" spaces (and not `&ts` or `&sts`).
set smarttab

" By  default, (when  `smarttab` is  off), 'sts'  controls how  many spaces  are
" added/removed when we press `Tab` or `BS`.
"
"               ┌ disable 'sts'; use 'sw' instead
"               │
set softtabstop=-1

" The way we've configured 'smarttab' and 'sts', we can now modify how tabs
" are handled by Vim, in all contexts, with a single option: 'sw'.

" is_bash {{{2

" By default, Vim uses the Bourne shell syntax.
" We prefer to use `bash`.
"
" Indeed, most  of the time,  we'll use `bash`,  and some bash  constructs don't
" exist in Bourne shell, like commands substitutions (`$(...)`).
" These bashisms are considered as errors if `b:current_syntax is# 'sh'`.
"
" For more info, read `:h sh.vim`.
let g:is_bash = 1

" It's not needed when a shell script has a shebang containing `bash`.
" But it's  useful when we've just  created a shell file,  because initially Vim
" may not  be able  to deduce the  right shelltype (no  typical filename  and no
" shebang yet).


" For more info, see this:
" https://github.com/neovim/neovim/issues/5559
" https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=848663

" join {{{2

" Don't insert two spaces after a '.', '?' and '!' with a join command.

" Update: Actually, I like how  in the user manual 2 spaces  are added between a
" final dot and the next non-whitespace.  It  makes it easier to find when a new
" sentence starts.
" In fact, I think it's a widely adopted convention.  See `man man` and `man par`.

"     set nojoinspaces

" lazyredraw {{{2
" What does it do?{{{
"
" Prevent the screen  from being redrawn while executing  commands which haven't
" been typed (e.g.: macros, registers).
" Also, postpone the update of the window title.
"}}}
" Why do you set it?{{{
"
" - Because of the previous description.
"
" - Setting this option prevents the screen to flicker when we use a custom
"   mapping which makes the cursor move far from its initial position, then
"   come back (e.g. `*`).
"
" - junegunn, tpope, justinmk, blueyed,  mhinz ... they all  set this option.
"}}}
" Is there any pitfall?{{{
"
" Yes.
" Because  of this  option, sometimes,  we may  need to  execute `:redraw`  in a
" (function called by a) mapping.
"
" Example: `C-g j` (scroll-window; vim-submode)
"}}}
if has('vim_starting')
    " Why do you delay the 'lazyredraw' setting?{{{
    "
    " Start neovim like this:
    "
    "     $ nvim -Nu NONE +'set lz'
    "
    " Then press `:` immediately before Neovim has the time to draw the statusline.
    " The statusline prints this:
    "
    "     [No Name]^^^...^^^0,0-1^^^^^^^^^^All
    "              ├───────┘
    "              └ 92 times
    "
    " You must press `:` really fast:
    " position your left little finger on the left control key,
    " your right middle finger  on `m`,
    " and your right index finger on `:`.
    "
    " The issue is easier to reproduce with a custom config, because the startup
    " time increases  a little, which  gives you more time  to press `:`  at the
    " right moment.
    "
    " In Vim, when  you press `:` before the statusline  has been drawn, nothing
    " is printed.
    " This is less distracting than in Neovim, but it's still distracting to see
    " the statusline not drawn.
    "
    " That's why we don't set `'lz'` too early:
    " so that the statusline  is correctly drawn even if we  press `:` very fast
    " after (Neo)Vim has been started.
    "}}}
    augroup startup_set_lazyredraw
        au!
        au CursorHold,InsertEnter,CmdlineEnter *
            \   exe 'au! startup_set_lazyredraw'
            \ | aug! startup_set_lazyredraw
            \ | set lazyredraw
    augroup END
endif

" showmatch {{{2

" don't show matching brackets;
" it makes the cursor jumps unexpectedly which is too distracting
set noshowmatch
" Note that if you set the option in the future, you may face an issue (github #4867).{{{
"
" You may fix it if you:
"
"    - reset `'showcmd'`
"    - reset `'showmatch'`
"    - set `'matchtime'` to 0
"    - empty `'indentexpr'`
"    - replace `normal! ^` with `call search('^\s*\zs\S', 'b')` in $VIMRUNTIME/indent/html.vim
"      (function `HtmlIndent()`)
"
" Or you could install this autocmd which resets `'showmatch'` in html buffers:
"
"     augroup disable_showmatch_in_html_files
"         au!
"         au BufEnter,WinEnter * let &showmatch = &ft is# 'html' ? 0 : 1
"     augroup END
"}}}

" modelines {{{2

" If 'modeline' is set, and the value of 'modelines' is greater than 0, then Vim
" will search inside  the first/last `&mls` lines of the  buffer and execute any
" `:set` commands it finds.

" This allows easy file-specific configuration.
" But I don't like that, for security reason.

set nomodeline
set modelines=0

" mouse {{{2

" Enable mouse usage (all modes)

set mouse=a

" nrformats {{{2

" when using the `C-a` and `C-x` commands, don't treat the numbers as octal
" E.g.:
"     `C-a` on 007
"     010  ✘~
"     `C-a` on 007
"     008  ✔~
set nrformats-=octal

" path {{{2

" Where should `:find` and `gf` look for a file?
" Why the numeric suffix after `**`?{{{
"
" It adds a limit on the recursion of `**`.
"
" At the moment, we have this file in our filesystem:
"
"     ~/.vim/plugged/vimtex/autoload/unite/sources/vimtex.vim
"
" Suppose our  current working directory  in Vim is  `~/.vim`, and this  path is
" written in a file:
"
"     sources/vimtex.vim
"
" As you can see, between the path of the cwd and this path, 4 directories are missing:
"
"     ~/.vim/plugged/vimtex/autoload/unite/sources/vimtex.vim
"            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
"
" So, if you write `3` after `**`, you won't be able to open `sources/vimtex.vim`
" in a new split, by pressing `C-w f`.
" But you will if you write `4` instead of `3`.
"
" The bigger the number,  the more directories Vim will have to  look into for a
" path, when you press `gf`, `C-w f`, ... or when you run `:find`, `:sfind`, ...
" and the more time it may take to find a file.
" This is especially annoying  when the file path can't be  found; Vim will have
" to look into  *all* subdirectories of the  cwd, up to the  given depth, before
" realizing it's not there.
"
" Inspiration: https://begriffs.com/posts/2019-07-19-history-use-vim.html#include-and-path
"
" >     The `**`  with a  number like `**3`  bounds the depth  of the  search in
" >     subdirectories. It’s wise  to add  depth bounds where  you can  to avoid
" >     identifier searches that lock up.
"}}}
set path=.,**5
"        │ │
"        │ └ and in the working directory recursively
"        └ look in the directory of the current buffer, non-recursively

" Its default value was:
"
"     .,/usr/include,,
"     │ │            │
"     │ │            └ empty value = working directory
"     │ └ /usr/include directory
"     └ directory of the current buffer

" Idea: You could also include the item `.git/..;`.{{{
"
" It  describes the  parent  directory  of `.git/`,  the  latter being  searched
" recursively upward in the file system; IOW,  it describes the root of your git
" project.
"
" We don't need it atm, because we have  something better: we set the cwd to the
" root directory of a git project, so `**5` looks not only in the project's root
" directory, but  recursively down into  it.  Still, it  could be useful  in the
" future...
"}}}

" scroll {{{2

" display at least 3 lines above/below the cursor
set scrolloff=3

" display at least 3 columns before/after the cursor
" when scrolling horizontally an unwrapped long line
set sidescrolloff=3

" minimum nr of columns to scroll horizontally
set sidescroll=5

" shortmess {{{2

" What does it do?{{{
"
" Prevent Vim  from printing the "ATTENTION" message when  an existing swap file
" is found.
"}}}
" If I edit a file in a second Vim instance, will the change be reflected in the first?{{{
"
" Yes, it should whenever `CursorHold` is fired.
" Because, in `vim-xterm`, we have:
"
"    - a custom autocmd executing `:checktime`
"
"        it will check whether the file has been changed
"        outside the current Vim instance
"
"    - set 'autoread'
"
"        it will automatically reload the file if the file has been changed
"        outside the current Vim instance
"}}}
" What happens if I edit a file in a 2nd Vim instance, get back to the 1st, and change it before `CursorHold`?{{{
"
" In theory, Vim should warn you:
"
"     WARNING: The file has been changed since reading it!!!
"     Do you really want to write to it (y/n)?
"
" If you  don't want to lose the  changes from the 2nd Vim  instance, you should
" answer no.
" Then, wait for CursorHold, or execute `:checktime`.
"
" In practice, there  should be no such message, because,  in vim-xterm, we have
" an autocmd listening  to `FocusGained` and `FocusLost` which  reloads the file
" if it has been changed outside the current Vim instance.
"}}}
" Why don't you enable the flag anymore?{{{
"
" I deal with the "ATTENTION" message with an autocmd listening to `SwapExists`.
"}}}
" set shm+=A

" enable all sort of abbreviations
set shortmess+=a

" Don't print |ins-completion-menu| messages.  For example:
"
"    - "-- XXX completion (YYY)"
"    - "match 1 of 2"
"    - "The only match"
"    - "Pattern not found"
"    - "Back at original"
set shortmess+=c

" don't print the file info when editing a file, as if `:silent` was used
set shortmess+=F

" When starting Vim without any argument, we enter into an unnamed buffer
" displaying a long message; hide this message.
set shortmess+=I

" don't print "search hit BOTTOM, continuing at TOP"
set shortmess+=s

" don't print "written" or "[w]" when writing a file
set shortmess+=W

" signcolumn {{{2

" We want a margin between the left of the screen and the text.
if has('nvim')
    " https://www.reddit.com/r/neovim/comments/f04fao/my_biggest_vimneovim_wish_single_width_sign_column/fgrz3vm/
    set signcolumn=yes:1
else
    set signcolumn=yes
endif


" We don't want `'signcolumn'` to be enabled in a Vim terminal buffer.{{{
"
" Otherwise, it's disabled when we're  in terminal-job mode, and enabled when we
" enter terminal-normal mode.
" This makes all the text move one character forward/backward, which is distracting.
" The issue doesn't affect Nvim.
"}}}
if !has('nvim')
    augroup disable_signcolumn_in_terminal_buffer
        au!
        au TerminalWinOpen * setl scl=no
    augroup END
endif

" startofline {{{2

" Some commands move the cursor to the first non-blank of the line:
"
"         c-d, c-u, c-b, c-f, G, H, M, L, gg, :123, :+    (motions)
"         dd, <<, >>                                      (operators)
"         c-^, :bnext, :bprevious
"
" I prefer the cursor to stay on the same column as before.
set nostartofline

" switchbuf {{{2
"         How to configure 'swb'?{{{

" You give it a list of values. Example:
"
"     set switchbuf=useopen,usetab
"}}}
"         What does it do?{{{

" If you  try to open a  split to display  a loaded buffer with  `:sbuffer`, Vim
" will first check  whether the buffer is  already displayed in a  window of the
" current tab page (`useopen`), or in another tab page (`usetab`).
" And if  it finds one,  instead of  creating a split,  it will simply  give the
" focus to this window.
"}}}
"         Which commands honor 'swb'?{{{

" quickfix commands, when jumping to errors (`:cc`, `:cn`, `cp`, etc.).
" All buffer related split commands: `:sbuffer`, `:sbnext`, `:sbrewind`...
"}}}
"         Which pitfalls can it create?{{{

" When we move in the qfl quickly, the focus can change from a window to another
" and it's distracting.
" Besides, once the focus has changed, if  we advance further in the qf list, it
" can make us lose the buffer which was opened in the window.
"
" ---
"
" When we press `C-w CR` on an entry of  the qfl, and the latter is present in a
" buffer which is already displayed somewhere else, Vim opens a split displaying
" an unnamed buffer.
"
" Why?
" Because FIRST it splits the window,  THEN checks whether the buffer to display
" is already displayed  somewhere else. When it finds one, it  changes the focus
" as expected, but it doesn't close the  split with the unnamed buffer (which is
" unexpected).
"
" MWE:
"
"     $ nvim -Nu NONE -c 'set swb+=useopen' ~/.bashrc
"     :vim /./ % | copen
"     " press C-w CR
"
" The issue has been fixed in Vim, but not in Nvim.
"}}}
"         Are there workarounds?{{{

" You could temporarily reset `'swb'` while:
"
"    - the qf window is opened; in a qf filetype plugin:
"
"         if !exists('s:swb_save')
"             let s:swb_save = &swb
"             set swb=
"         endif
"
"         au BufWinLeave <buffer> let &swb = get(s:, 'swb_save', &swb) | unlet! s:swb_save
"
"    - when you execute some commands / mappings
"
"      you would need to create wrapper around default normal commands
"      with a try conditional, and a finally clause, to empty 'swb'
"      and/or,
"      you would need to install an autocmd listening to CmdlineLeave,
"      to set 'swb' only when you use some Ex commands
"
" You could install unimpaired-like mappings to toggle the value of `'swb'`.
"}}}
"         Why don't you set it?{{{
"
"    - Too many issues.
"    - I don't need it atm.
"    - To give the focus to an already displayed buffer, there are alternatives:
"
"         :FzWindows  (<space>fw)
"         :drop       (:drop ~/**/*some_file)
"}}}
"}}}2
" synmaxcol {{{2

" don't syntax-highlight long lines
set synmaxcol=250
"             │
"             └ weight in bytes
"               any character prefixed by a string heavier than that
"               will NOT be syntax highlighted
" }}}2

" t_ {{{2
" Why `!has('nvim')` in the guard?{{{
"
" Nvim doesn't have terminal options.
" It correctly and automatically sets its internal terminfo db.
"
"     $ nvim -V3/tmp/log +'call timer_start(0, {-> execute("q")})'
"     $ nvim -es +'exe "1,/{{\\%x7b$/g/^/d_" | /}}\\%x7d$/,$g/^/d_' +'%p | qa!' /tmp/log | nvim -
"     /paste
"     ext.enable_bpaste         = <Esc>[?2004h~
"     ext.disable_bpaste        = <Esc>[?2004l~
"}}}
if has('vim_starting') && !has('gui_running') && !has('nvim')
" BD BE PS PE {{{3

" What's the bracketed paste mode?{{{
"
" A  special  mode in  which  the  terminal surrounds  a  pasted  text with  the
" sequences `Esc [ 200 ~` and `Esc [ 201 ~`.
"}}}
"   How is it useful?{{{
"
" Thanks to these sequences, the application  which receives the text knows that
" it was  not typed  by the  user, but pasted,  and that  it should  disable the
" interpretation of what it considers to be special characters.
"
" MWE:
"
"     $ vim -Nu NONE +'let @+ = "hello\e:echom \"malicious code injected\"\ri"' +startinsert
"     C-S-v
"     Esc
"     :mess
"     malicious code injected~
"
" In this  example, the escape,  colon and  carriage return were  interpreted as
" "enter normal mode", "enter command-line mode", and "run command".
"
" As you can see,  this can be dangerous, because if you  don't pay attention to
" what you've copied, Vim may run an unexpected command.
"
" Other MWE:
"
"     $ vim -Nu NONE +'let @+ = "Level 1\n    Level 2\n    Level 2\nLevel 1"' +'setl ai' +startinsert
"     C-S-v
"     Level 1~
"         Level 2~
"             Level 2~
"             Level 1~
"
" Notice how the indentation of some lines is increasingly wrong.
" This is because when you enter a new line, if `'ai'` is set, Vim automatically
" autoindents the new line.
"}}}
"   Is it 100% reliable?{{{
"
" No, unfortunately.
"
" The protection  offered by  the bracketed  paste mode can  be bypassed  if the
" pasted text contains `\e[201~`; it will end the bracketed mode prematurely.
" This works  because, before sending the  text to the application,  some (all?)
" terminals do not properly filter escape sequences before adding their own.
"
" See the second example on this page:
" https://thejh.net/misc/website-terminal-copy-paste
"
" ---
"
" Also, the bracketed  paste mode is ignored  when you insert the  contents of a
" register with `C-r`.
"
" MWE:
"
"     $ vim -Nu NONE +'set ai' +':let @a = "Level 1\n    Level 2\n    Level 2\nLevel 1"'
"     i C-r a
"
" If `'paste'` is reset, you'll get:
"
"     Level 1~
"         Level 2~
"             Level 2~
"             Level 1~
"
" If `'paste'` is set, you'll get:
"
"     Level 1~
"         Level 2~
"         Level 2~
"     Level 1~
"
" You can avoid the issue by pasting from normal mode (`"ap`), or inserting with
" `C-r C-o` or `C-r C-p`.
"}}}
"   How many things need to be configured for it to work?{{{
"
" The terminal and the application which is running in the foreground.
"
" But you don't need to configure the terminal; it just needs to be recent enough.
" Except for tmux, which is a special case.
" When you use the `paste-buffer` command, you must pass it the `-p` option.
"
" And  note that  whether the  foreground  application needs  to be  configured,
" depends on its default configuration.
" For example, zsh automatically sets the parameter `zle_bracketed_paste`:
"
" >     This two-element array  contains the terminal escape  sequences for enabling
" >     and  disabling  the  feature. These  escape sequences  are  used  to  enable
" >     bracketed paste when ZLE is active and disable it at other times.  Unsetting
" >     the  parameter has  the  effect  of ensuring  that  bracketed paste  remains
" >     disabled.
"
" Which enables the bracketed paste mode.
" But if you unset the parameter, you disable the mode.
" So, it's just a choice from the devs to enable the mode by default.
" Note that you can see the current value of the parameter by running:
"
"     $ typeset zle_bracketed_paste
"
" See: `man zshparam /zle_bracketed_paste`
"
" OTOH, for bash, you need to set the readline variable `enable-bracketed-paste`.
" It is not set by default.
"}}}

"   How to make the terminal enter/leave this mode while Vim is running?{{{
"
" Set the options `'t_BE'` and `'t_BD'`, with the values `CSI ? 2004 h`
" and `CSI ? 2004 l`.
" These sequences are documented at `CSI ? Pm h/;/Ps = 2 0 0 4`
" and `CSI ? Pm l/;/Ps = 2 0 0 4`.
"
" When the terminal enters raw mode,  Vim sends to it `&t_BE` (Bracketed paste Enable).
" And when the terminal leaves raw mode, Vim sends `&t_BD`.
" So,  if  these options  are  properly  set,  the terminal  will  automatically
" enable/disable the bracketed paste mode whenever it enters/leaves raw mode.
" IOW, the raw and bracketed paste modes will be synchronized.
"
" You also need to set the options  `'t_PS'` and `'t_PE'` with the values
" `CSI 200 ~` and `CSI 201 ~`.
" Probably  to  let   Vim  know  which  sequences  it  must   interpret  as  the
" beginning/end of a pasted text.
"
" For more info, see `:h xterm-bracketed-paste`.
"
" >     When the 't_BE' option is set then  't_BE' will be sent to the terminal when
" >     entering "raw"  mode and 't_BD'  when leaving  "raw" mode.  The  terminal is
" >     then  expected to  put 't_PS'  before pasted  text and  't_PE' after  pasted
" >     text.  This  way Vim can separate  text that is pasted  from characters that
" >     are typed.  The pasted text is handled  like when the middle mouse button is
" >     used, it is inserted literally and not interpreted as commands.
"}}}
"     Now you're talking about yet another mode!  What's this raw mode?{{{
"
" A mode in which the terminal driver doesn't interpret the characters it receives.
"
" >     The  terminal can  be placed  into  "raw" mode  where the  characters are  not
" >     processed by the terminal driver, but are sent straight through (it can be set
" >     that INTR and QUIT characters  are still processed). This allows programs like
" >     emacs and vi to use the entire screen more easily.
"
" Source: https://unix.stackexchange.com/a/21760/289772
"
" See also `:h raw-terminal-mode`.
"}}}
"       When Vim is running, is the terminal in raw mode?{{{
"
" I think it depends.
"
" Most of the time, it must be, so  that Vim can receive all the keys pressed by
" the user, and interpret them however it wants.
" Among other things, this allows the user to remap `C-c`, `C-u`, `C-d`, ...
" which otherwise would be interpreted by the line discipline of the terminal:
"
"     $ stty -a | grep 'intr\|kill'
"     intr = ^C; quit = <undef>; erase = ^?; kill = ^U; eof = ^D; eol = <undef>;~
"            ^^                                     ^^        ^^
"
" However, sometimes, Vim temporarily switches to cooked mode.
" This allows  the user to end  an external process started  with `system()`, by
" pressing `C-c`.
"}}}
"       What's the relationship between raw mode and bracketed paste mode?{{{
"
" I don't think there's one.
" I  think  they  are  orthogonal,  i.e. the  terminal  can  enable/disable  one
" independently of the other's state.
"}}}

" Why can't we enable the bracketed paste mode for the whole Vim session?{{{
"
" Why this dance: enter raw mode → enable bracketed paste
"                 leave raw mode → disable bracketed paste
"
" Instead of:     enter Vim → enable bracketed paste
"                 leave Vim → restore bracketed paste as it was before Vim was started
"
" Would sth bad  happen if the bracketed  paste mode was still  enabled when the
" terminal leaves raw mode and enters cooked mode?
"
" Answer: I don't know, but it seems weird  to let the terminal add some special
" sequences in  cooked mode; it already  has to interpret some  possible special
" characters. Maybe there could be some unexpected interaction between the two.
"
" ---
"
" If sth bad can happen, then why  doesn't this issue also affect the shell?
" The latter is in cooked mode, right?
"
" Answer: No, I don't think that the terminal is *always* in cooked mode.
" I think  that when you  paste, it temporarily  enters raw mode,  to faithfully
" transmit whatever text is contained in the clipboard selection to the shell.
"}}}

" Why `&t_BE is# ''`?{{{
"
" Because Vim  already sets these options  for some terminals (e.g.  xterm), but
" not all.
" In particular, it fails to set them for st, and for any terminal in tmux.
" Presumably because  it only recognizes a few terminals  (via `$TERM`) which it
" knows how to configure.
"}}}
if &t_BE is# ''
    let &t_BE = "\e[?2004h"
    let &t_BD = "\e[?2004l"
    let &t_PS = "\e[200~"
    let &t_PE = "\e[201~"
endif

" RV {{{3

" If we don't clear `'t_RV'`, our `vim-search` plugin is broken in xterm. (github issue 4836){{{
"
" More specifically, it raises this error when we press `*` on a word:
"
"     E486: Pattern not found: <Plug>(ms_up)~
"
" MWE:
"
"     $ cat <<'EOF' >/tmp/vimrc
"         cno <plug>(up) <up>
"         nmap <expr> * Func()
"         fu Func()
"             return "*/\<plug>(up)\r"
"         endfu
"     EOF
"
"     # open xterm
"     $ vim -Nu /tmp/vimrc /tmp/vimrc
"     # move cursor above 'Func' and press `*`
"     E486: Pattern not found: <Plug>(up)~
"
" The issue occurs only  in xterm and other terminals whose  `TERM` uses a value
" derived from 'xterm'.
"
" It doesn't  occur in st,  probably because  the latter doesn't  understand the
" sequence stored in `'t_RV'`  which is sent by Vim; so,  st doesn't answer, and
" Vim doesn't adjust various t_ codes.
"
" It doesn't occur in xterm+tmux,  because inside tmux `TERM` is 'tmux-256color'
" instead of 'xterm-256color'.
"
" ---
"
" When `'t_RV'` is set, Vim sends a request sequence to the terminal.
" If the latter  is xterm, it answers with another sequence  which Vim stores in
" `v:termresponse`. Atm, in xterm, the answer is:
"
"     ^[[>41;322;0c
"
" `41` is the terminal type, and 322 the current patch level (we're using xterm(322)).
" Then, Vim adjusts various t_ codes.
"
" ---
"
" This issue is weird, because `'t_RV'` doesn't do anything in itself.
" It causes other `t_` codes to be adjusted.
" But the only differences between the termcap  db of Vim when it's started from
" xterm with `'t_RV'` set and unset are those 2 keycodes:
"
"     set <SgrMouse>=^[[<*M
"     set <SgrMouseRelelase>=^[[<*m
"
" They don't seem related to our issue (i.e. to the Up key).
" I even recompiled Vim after removing all the lines found by:
"
"     $ vim -q =(rg '<\*m') +cw
"     $ vim -q =(rg 'SgrMouse') +cw
"
" so that the termcap db of our  Vim binary is identical whether `'t_RV'` is set
" or not.
" And yet, it still doesn't fix the  issue; this seems to show that `'t_RV'` has
" an effect which is not documented.
"}}}
"   Is there an alternative solution?{{{
"
" Yes, you could replace `\<plug>(ms_up)` with `\<up>` in
" `~/.vim/plugged/vim-search/autoload/search.vim:608`:
"
"     \                   ? "\<plug>(ms_slash)\<plug>(ms_up)\<plug>(ms_cr)\<plug>(ms_prev)" : '')
"                                             ^^^^^^^^^^^^^^
"
" But I'm not sure this would be a good idea.
" If you do remove `<plug>(ms_up)`, you don't need this line in
" `~/.vim/plugged/vim-search/plugin/search.vim`:
"
"     cno  <plug>(ms_up)      <up>
"}}}
set t_RV=

" Ts, Te {{{3

" necessary when `$TERM` is not 'xterm' to be able to apply the strikethrough attribute to text:{{{
"
"     $ vim -Nu NONE +'hi MyStrikeThrough cterm=strikethrough'
"     :hi MyStrikeThrough
"}}}
let [&t_Ts, &t_Te] = ["\e[9m", "\e[29m"]

" ut {{{3

" We don't really need this atm.
" It's only useful if you start Vim inside `xterm-kitty` (and outside tmux).
if $TERM =~# '-256color$\|^xterm-kitty$'
    " Disable Background Color  Erase (BCE) so that color  schemes render properly
    " when inside 256-color tmux and GNU screen.
    " See: http://snk.tuxfamily.org/log/vim-256color-bce.html
    set t_ut=
endif
"}}}3
endif
" }}}2
" tags {{{2

" When searching the tags file, ignore the case unless an upper case letter is used.
set tagcase=smart

" What's the default value? {{{
"
"     ./tags,./TAGS,tags,TAGS
"
" Explanation:
"
"    ┌────────┬──────────────────────────────────────────────────────────────────┐
"    │ ./tags │ file in the directory of the CURRENT FILE and whose name is tags │
"    ├────────┼──────────────────────────────────────────────────────────────────┤
"    │ tags   │ file in the WORKING DIRECTORY             and whose name is tags │
"    └────────┴──────────────────────────────────────────────────────────────────┘
"}}}
" What's the effect of our new value `./tags;`?{{{
"
" `;` tells Vim to look *up* recursively.
" It's the opposite of `**` which looks *down* recursively.
" You could also include the value `tags;`:
"
"     set tags=./tags;,tags;
"
" Explanation:
"
"    ┌─────────┬──────────────────────────────────────────────────────────────┐
"    │ ./tags; │ file in the directory of the CURRENT FILE, then              │
"    │         │ in its parent directory, then in the parent of the parent    │
"    │         │ and so on, recursively                                       │
"    ├─────────┼──────────────────────────────────────────────────────────────┤
"    │ tags;   │ file in the WORKING DIRECTORY, then in its parent directory, │
"    │         │ then in the parent of the parent and so on, recursively      │
"    └─────────┴──────────────────────────────────────────────────────────────┘
"
" The value of `'tags'` influences commands such as `:tj` and `:ltag`.
" It also influences tag completion (`:h i^x^]`), which looks for matches in the
" tags files whose paths are stored in the value of `'tags'`.
"}}}
" Why the guard?{{{
"
" We use a specific value for the vimrc file (`$HOME/.vim/autoload/tags`).
" When we write  our vimrc, we don't the autocmd  which sources it automatically
" to reset this value.
"}}}
if has('vim_starting')
    set tags=./tags;
endif
" Why could a command such as `:tj` or `:ltag` include some irrelevant tags? {{{
"
" It's probably due to the combination of two factors:
"
"    - vim-gutentags is enabled
"
"    - you have a tags file in a big directory containing many different
"      projects
"
"      For example,  you may have  executed `$ ctags  -R` by accident  in a
"      wrong directory, such as `~/.vim` or `~/.vim/plugged`.
"
"      Or maybe it  was executed by `vim-gutentags`  because you accidentally
"      created  a git  repo (via  something like  `git {add|commit|push}`),
"      where you shouldn't have.
"
" `vim-gutentags`  appends the  global  value of  `'tags'`  to the  buffer-local
" value, for buffers inside a git repo.
"
" So, if  `./tags;` and/or `tags;`  is inside the  global value of  `'tags'`, it
" will also end up in the local value.
" And thus, when  you'll be working on a project,  like the `vim-session` plugin
" for example, here's the kind of local value that `'tags'` will contain:
"
"     tags=~/.vim/plugged/vim-session/tags,./tags;,tags;
"                                                ^     ^
" Because  of  the  semicolons, Vim  may  include  a  wrong  tags file  such  as
" `~/.vim/tags`. If that happens, you'll end up with way too many tags.
"}}}
" What to do if that happens? {{{
"
" -  Try  to configure  `vim-gutentags` and  prevent it  from including  the
"    global value of `'tags'` inside the local one.
"
" -  Remove wrong tags files (`rm(1)`), and make sure there's no `.git/`
"    directory outside a valid  repository.
"    Otherwise, `vim-gutentags` may recreate a tags file.
"}}}
" TODO: Find a  way to configure gutentags  so that it never  appends the global
" value of `'tags'` to the local value.

" In our vimrc file, we want the ability to jump from the call of a function
" defined in `myfuncs.vim`, to its definition, with `C-]`.
augroup tags_vimrc
    au!
    au BufReadPost $MYVIMRC setl tags=$HOME/.vim/autoload/tags
    " update the tags file whenever we write `myfuncs.vim`
    au BufWritePost $HOME/.vim/autoload/myfuncs.vim
        \ call system('ctags -f $HOME/.vim/autoload/tags $HOME/.vim/autoload/myfuncs.vim')

    " Don't source the zshrc automatically.{{{
    "
    " This would work:
    "
    "     au! BufWritePost .zshrc sil call system('source '..expand('%:p:S'))
    "
    " But I'm concerned that after editing the zshrc and doing some experiments,
    " we end up in a shell  whose state is really weird, producing hard-to-debug
    " issues.
    " If that happens, we may have an issue in Vim.
    " We'll restart Vim, and the issue will probably persist.
    " But we won't necessarily think about starting Vim from a new shell.
    " We often work in Vim from the same shell for hours.
    "
    " I don't like that.
    " Leave the shell alone.
    " We already have the habit to open a new shell whenever we edit the zshrc anyway.
    "
    " Fucking the vimrc is ok, because we have a mapping to restart Vim.
    " Fucking the zshrc is *not* ok, because we don't have any such mapping.
    " At best, we can open a new shell, but not reset the current one.
    "}}}
augroup END

" temporary files:  undo, swap, backup {{{2

" FIXME:
" Review all this section.
" Finish  implementing proper  backup (you  probably don't  want to  backup huge
" files though, nor temporary files; it would quickly take too much space).
" Read files in `backup` session.
"
" And read these:
" https://www.zachpfeffer.com/single-post/Practice-Recovering-a-File-in-Vim
" https://begriffs.com/posts/2019-07-19-history-use-vim.html#backups-and-undo

" TODO: The undo/backup files are never removed by Vim, and they can take a lot of space over time.{{{
"
" You probably want to remove:
"
"    - the ones which were written for files in `/tmp/` or `/run/` (`/etc`? `/usr`? `/var`?):
"
"         $ find ~/.vim/tmp/undo -path '*/%run%*' -print0 | xargs -0 rm
"         $ find ~/.vim/tmp/undo -path '*/%tmp%*' -print0 | xargs -0 rm
"
"    - the ones written for a pdf:
"
"         $ find ~/.vim/tmp/undo -name '*.pdf' -print0 | xargs -0 rm
"
"    - the ones written for a file which has not been modified since a long time (3 months?)
"
"    - the ones written for a file which doesn't exist anymore
"
"      For example if this undo file exists:
"
"         ~/.vim/tmp/undo/%path%to%file
"
"      But `/path/to/file` does not exist anymore, then we should remove the undo file.
"
"    - the ones written for a file which takes more than 20 megs
"      Atm, my biggest "valid" undo file takes 5 megs.
"      The ones above are not valid (pdfs, non-existing files, ...).
"
" Find a way to run the right shell commands (sth like `$ find ... -exec rm ... +`)
" automatically via a cron job once a week/month.
"
" ---
"
" Maybe we should disable `'undofile'` in certain directories (not sure I want that).
" Or, enable `'undofile'` only in our home (not sure I want that either).
" Note that you can prevent the creation of backup files for a given directory with:
"
"     set backupskip+=/some/dir/*
"
" ---
"
" Read this: https://vi.stackexchange.com/a/53/13370
"}}}

" Note that by default, Nvim uses these directories:{{{
"
"     ~/.local/share/nvim/swap//
"     ~/.local/share/nvim/undo
"     .,~/.local/share/nvim/backup
"     │
"     └ directory of the edited file
"
" In the future, if you mainly use Nvim, consider using them instead...
" But make sure to remove the `.` at the front of `'directory'`.
"}}}
if !isdirectory($HOME..'/.vim')
    call mkdir($HOME..'/.vim', '', 0700)
endif

" Put all swap files in `~/.vim/tmp/swap/`.{{{
"
" The default value is:
"
"     .,~/tmp,/var/tmp,/tmp
"     ^
"
" With this  value, if you  edit a file,  the swap file  will be created  in the
" parent directory of the file.
" IOW, your  swap files will be  scattered across your whole  filesystem; that's
" untidy, especially when Vim crashes, and the swap files persist.
"}}}
" Why the trailing double slash?{{{
"
" It's  useful if  you edit  two  files with  the  same name,  but in  different
" directories.
" Suppose you edit `/tmp/dir1/file` and `/tmp/dir2/file`.
"
" Without the trailing double slash, both swap files would have the same name.
" The last one to be created would probably overwrite the previous one.
"
" With the trailing double slash, the name  of each swap file is unique, because
" it includes  the full  path to the  file it's associated  to; the  slashes are
" replaced with percent signs.
" From `:h 'dir`:
"
" >     For Unix and Win32, if a directory ends in two path separators "//", the
" >     swap file name will be built from the complete path to the file with all
" >     path separators substituted to percent  '%' signs. This will ensure file
" >     name uniqueness in the preserve directory.
"}}}
set directory=$HOME/.vim/tmp/swap//

" make sure the swap directory exists
if !isdirectory(&directory)
    call mkdir(&directory, 'p', 0700)
endif

" enable persistent undo
set undofile

" choose location of undo files
set undodir=$HOME/.vim/tmp/undo

" make sure the undo directory exists
if !isdirectory(&undodir)
    call mkdir(&undodir, 'p', 0700)
endif

set backup

" See `:h backup-table` to understand when Vim creates a backup file.
set backupdir=~/.vim/tmp/backup//
if has('vim_starting')
    set backupskip+=/run/*
endif

" make sure the backup directory exists
if !isdirectory(&backupdir)
    call mkdir(&backupdir, 'p', 0700)
endif

" timeout {{{2

" enable a timeout for mappings
set timeout

" same thing for keycodes
set ttimeout

" set the timeout for mappings to 3s
set timeoutlen=3000

" ... and 6 ms for keycodes.
" Previously we used 50ms, but 6 is the max value to prevent this error:{{{
"
"    1. insert sth wrong
"    2. hit escape
"    3. hit u (undo)    →    M-u: uppercase next word
"
" Vim recognizes `M-u` as `Esc + u`, because of this line in vim-readline:
"
"     exe "set <m-u>=\eu"
"
" So, if  we press  `Esc` then `u`  in less than  &ttimeoutlen, Vim  thinks that
" we've pressed `M-u`.
" To avoid this kind of misunderstanding,  we need to set `'ttimeoutlen'` as low
" as possible.
"}}}
"   What other issue does this fix?{{{
"
" The default value of `'ttimeoutlen'` is -1.
" It means that it copies the value of `'timeoutlen'`, which we've set to 3s.
" Now suppose that you're in insert mode, and want to get back to normal mode by
" pressing `Esc`: you'll have to wait 3s.
"
" Why?
" Because  some special  keys (e.g. F1,  F2, ...,  left, right,  ...) produce  a
" keycode beginning with `Esc`.
" So, Vim has to  wait `'ttimeoutlen'` ms to know whether  the `Esc` was pressed
" manually or it was part of some keycode.
"}}}
"   What issue(s) can this cause?{{{
"
" If Vim is running on a remote machine, a low value could be insufficient for a
" keycode to reach the latter.
"
" For example,  if we press `M-u`  and our local  machine sends `Esc +  u`, more
" than `&ttimeoutlen` could elapse between `Esc` reaching the remote machine and `u`.
" In that case, Vim will think we pressed `Esc` then `u` instead of `M-u`.
"
" ---
"
" With a low value, the contents of a recording is weird:
"
"     $ vim -Nu NONE +'set ttimeoutlen=6'
"     qqq
"     qq A Esc q
"     :echo @q
"     A^[<80><fd>a~
"
" It makes reading  the contents of a register, and  `/tmp/.vimkeys` harder than
" it should be.
"
" Note that the issue is specific to Vim, not Nvim.
" And it disappears below a certain threshold which can vary (≈ 300ms?).
"
" See: https://github.com/vim/vim/issues/4725
"}}}
set ttimeoutlen=6

" ttymouse {{{2

" This option may help when you need to interact with Vim with your mouse.{{{
"
" In  particular, it  may help  resizing a  tmux pane  where Vim  is running  by
" dragging its status line: http://superuser.com/a/550482
"
" It may also help clicking after the 223rd column.
"
" ---
"
" The best value seems to be `sgr`.
" From `:h 'ttym`:
"
" >    The "sgr"  value will be set  if Vim detects Mac  Terminal.app, iTerm2 or
" >    mintty, and when the xterm version is 277 **or higher**.
"
" It's the value used by Vim when it detects a recent xterm.
"}}}
" 'ttym' has been removed from Nvim
if !has('nvim')
    set ttymouse=sgr
endif

" updatetime {{{2

"              ┌ our current chosen value
"              │  if you change it, do the same in:
"              │
"              │          ~/.vim/plugged/vim-readline/autoload/readline.vim
"              │
"              │  function:
"              │
"              │          `readline#do_not_break_macro_replay()`
"              │
set updatetime=2000

" viminfo {{{2

" Useful to save variables such as `g:MY_VAR`.
if has('nvim')
    set shada+=!
else
    set viminfo+=!
endif

" virtualedit {{{2

" In visual-block mode, let us move the cursor on a cell where there's no character:
"
"    - in the middle of a tab
"    - beyond the last char on a line
"
" Useful to select a rectangle out of irregular (different lengths) lines.
if has('vim_starting')
    set ve=block
    const g:orig_virtualedit = &ve
    augroup hoist_ve
        au!
        " TODO: The `[ve=onemore]` flag is visible when selecting some text and pressing `sa`.{{{
        "
        " It should not be visible.
        "
        " The  only solution  I  can see  right  now, is  to send  a  PR to  the
        " vim-sandwich dev, which prefixes `:set` with `:noa`.
        "}}}
        au User MyFlags call statusline#hoist('global',
            \ '%{&ve isnot# "'..&ve..'" && mode(1) is# "n" ? "[ve="..&ve.."]" : ""}', 8,
            \ expand('<sfile>')..':'..expand('<sflnum>'))
        au OptionSet virtualedit call timer_start(0, {-> execute('redrawt')})
    augroup END
endif

" wildignore(case) {{{2

" Why tweaking `'wildignore'`?{{{
"
" Some files can't be edited by Vim.
" Or they should not be edited.
"
" We never want to see them:
"
"    - in a dirvish listing
"    - on the command-line after a tab completion
"    - in the output of `expand()`, `glob()`, `globpath()`
"}}}
set wildignore&vim
" lock files (example: ~/.gksu.lock)
set wildignore+=*.lock

" vim temporary files
set wildignore+=*.bak,*.swo,*.swp,*~

" latex temporary files
set wildignore+=*.aux,*.fdb_latexmk,*.fls,*/auxiliary/*,*/build/*

" password databases
set wildignore+=*.kdb,*.kdbx

" media files (music, pictures, ...)
set wildignore+=*.gif,*.jpeg,*.jpg,*.mp3,*.mp4,*.png

" python objects/cache
set wildignore+=*.pyc,*/__pycache__/*

" undo files
"
"                                    ┌ `*` can match any string/path
"                                    │ (including as many `/` as you want, but not a dot)
"                                    │
let &wildignore ..= ','..&undodir..'/*'
let &wildignore ..= ','..&undodir..'/*.*'
let &wildignore ..= ','..&undodir..'/*.*.*,'
"                                    │
"                                    └ `*` can't match a dot, and the path of an
"                                      undofile often contains 1 or 2 dots

" Why don't you ignore archives?{{{
"
"     set wildignore+=*[^0-9].gz,*.rar,*.tar.*,*.zip
"                      ├────┘
"                      └ don't ignore man pages in `/usr/share/man/man1/`
"
" Some system files are stored in archives, logs for example.
" When we inspect the contents of a directory in dirvish, I want to see them
" (whether I can open them or not).
" Besides, usually, they can be read in Vim.
" Example:
"
"     /usr/share/keymaps/i386/azerty/azerty.kmap.gz
"}}}

set wildignore+=tags

" A file in a `.git/` directory.
set wildignore+=*/.git/*
" If you see a `.git/` directory in dirvish, before tweaking this option, have a look at `fex#format_entries()`:{{{
"
"     ~/.vim/plugged/vim-fex/autoload/fex.vim:22
"}}}
" If this setting causes an issue, read this:{{{
" https://www.reddit.com/r/vim/comments/626no2/vim_without_nerd_tree_or_ctrlp/dfkbm97/
" https://github.com/tpope/vim-fugitive/issues/121#issuecomment-38720847
    "}}}

" Tab completion should be case-insensitive.
" If we type `:e bar Tab`, and a file `Bar` exists, we should get:
"
"     :e Bar
set wildignorecase

" wildmenu  wildchar(m) {{{2

" enable wildmenu
set wildmenu

" The value of 'wildmode' is a comma-separated list of (up to 4) parts.
" Each  part   defines  what   happens  when  we   press  Tab   (&wildchar)  the
" 1st/2nd/3rd/4th time.
set wildmode=full

" What's 'wildchar'?{{{
"
" The  key to  press for  Vim to  start a  wildcard expansion  (which opens  the
" wildmenu).
"}}}
"   'wildcharm'?{{{
"
" The key to press for Vim to start a wildcard expansion, from:
"
"    - the recording of a macro
"    - the rhs of a mapping
"}}}

" What does the value `26` stand for?{{{
"
"     C-z
"}}}
" What does `set wildcharm=26` imply?{{{
"
" When you want  Vim to start a wildcard  expansion, in the rhs of  a mapping or
" while recording a macro, you'll have to write/press `C-z`, instead of Tab.
"
" If you write/press Tab, the mapping/macro  won't work as expected, because the
" Tab  characters  they  contain  will be  interpreted  literally  (no  wildcard
" expansion).
"}}}
"   Is there an alternative value?{{{
"
" Yes, you could write:
"
"     set wildcharm=9
"}}}
"     Why would it be better?{{{
"
" Because you could write/press Tab in your mappings/macros, to make Vim start a
" wildcard expansion, exactly like you would the rest of the time.
"}}}
"     Why don't you use it?{{{
"
" Suppose your macro contains Tab characters.
" While on the command-line, *any* one  of them will start a wildcard expansion.
" It may have unexpected results.
" For a real example, run:
"
"     :so $VIMRUNTIME/syntax/hitest.vim
"
" (Taken from `:h hitest.vim`)
" It will raise `E475`, and the dumped highlight groups won't be highlighted.
" This is because of these commands:
"
"     % yank a
"     @a
"
" They run the contents of the buffer as Ex commands (`@a` ⇔ `:@a`).
" The buffer contains Tab characters.
" They all make Vim start a wildcard expansion, but in the buffer they were just
" used to separate some texts.
" They were not supposed to expand anything.
"}}}
set wildchar=9
set wildcharm=26

" winaltkeys {{{2

" disable `alt + {char}` key bindings used in gVim to access some menu entries
" They could shadow some of our custom mappings using the meta modifier key.

set winaltkeys=no

" word / line wrapping {{{2

" don't wrap long lines by default
set nowrap

" a soft-wrapped line should be displayed with the same level of indentation as the first one
set breakindent
set breakindentopt=min:40,sbr
"                  │      │
"                  │      └ display the 'showbreak' character *before* the indentation
"                  │        this helps keeping all the start of lines aligned
"                  │
"                  └ make sure a soft-wrapped line contains at least 40 characters
"                    shift it to the right if necessary

" soft-wrap long lines at a character in 'breakat' (punctuation, math
" operators, tab, @) rather than at the last character that fits on the screen
set linebreak

" allow to soft-wrap after ) ] }
set breakat+=)]}

" allow `h` and `l` motion to move across lines
set whichwrap=h,l
" }}}1
" Mappings {{{1
" New {{{2

fu s:remember_new_mappings(some_lhs) abort
    for lhs in a:some_lhs
        exe 'nno <silent> '..lhs[0]..' :<c-u>call <sid>reminder_new_mapping('..string(lhs[1])..')<cr>'
    endfor
endfu

fu s:reminder_new_mapping(new_lhs) abort
    echohl WarningMsg
    echo 'Press '..a:new_lhs..'    [3 times to make it stick faster]'
    echohl NONE
endfu

call s:remember_new_mappings([
    \ ['-e', '!e'],
    \ ['zs', '!s'],
    \ ])

" Free {{{2

" A key can be used as a prefix iff one of these conditions is true:
"
"    - it's useless for you (ex: U)
"    - it's used as a prefix by default (ex: Z)
"
" This means that you can NOT use `!` as a good prefix.
" Not useless, and not a prefix by default, so it would lead to too many issues.
"
" Still, you may  occasionally use a key sequence `!{char}`.   But do NOT infer,
" that `!` can be  used as a prefix associated with a meaning,  to build a whole
" family of mappings.
" There would be  times when it wouldn't  work, and then you would  have to build
" mappings which do not  follow the same scheme (shell command  → !). It would
" bring inconsistencies.


" When you find a new prefix, if it has a default meaning, disable it:
"
"         nno <pfx> <nop>
"
" Do NOT do it here from the vimrc.
" Do it from `~/.vim/after/plugin/disable.vim`: it's more reliable.
" See the first comment there for an explanation.


"    - C-q is not used in insert mode (except for exiting a completion menu)
"      we could supercharge  it to do something  else when we aren't  in a completion
"      menu
"
"    - C-z has been disabled in visual mode
"
"      in insert mode, we use it as an “easier-to-type“ C-x C-p
"
"    - gh, gH, g C-h, gl, v_C-g
"
"    - @# has been mapped to g8, so g8 is free
"
"    - gy, gz
"
"    - PageUp PageDown
"
"    - S-Tab (not Tab, because it would also affect C-i used for moving
"      inside the jumplist)
"
"    - C-_
"
"    - search for 'not used' in the window opened by `:viu`

" Leader {{{2

" If we install a  plugin which defines mappings using the  leader key, we don't
" want any clash with one of  our existing mapping. So, we assign to `mapleader`
" a garbage key. Why `S-F13`? See the configuration of UltiSnips.

" As an  example, this strategy is  useful to avoid the  `unicode.vim` plugin to
" introduce lag  when we hit  `<space>u`. Indeed this plugin installs  a mapping
" whose lhs is `<leader>un` (`:h <plug>(UnicodeSwapCompleteName)`).

" Other benefit:
"
"       :no <leader>
"       →
"       displays all mappings installed by third-party plugins
"       in normal / visual / operator-pending mode

let mapleader = "\<s-f13>"

" same thing for localleader
let maplocalleader = "\<s-f14>"

" Command-Line {{{2
" C-r C-h       fuzzy search history {{{3

" Why not C-r C-r?{{{
"
" Already taken (:h c^r^r).
"}}}
" Why not C-r C-r C-r ?{{{
"
" Would cause a timeout when we press C-r C-r to insert a register literally.
"}}}
cno <expr> <c-r><c-h> getcmdtype() =~ '[/?]' ? '<Esc>:FzHistory/<cr>' : 'FzHistory:<cr>'

" C-r C-l       insert current line {{{3

cno <c-r><c-l> <c-r><c-r>=<sid>insert_current_line()<cr>
fu s:insert_current_line() abort
    let cml = matchstr(&l:cms, '\S*\ze\s*%s')
    let cml = '\%(\V'..escape(cml, '\')..'\m\)\='
    return substitute(getline('.'), '^\s*'..cml..'\s*:\=', '', '')
endfu

" C-r `         insert codespan {{{3

cno <c-r>` <c-r><c-r>=<sid>insert_codespan()<cr>
fu s:insert_codespan() abort
    let line = getline('.')
    let col = col('.')
    let pat = '.*`\zs.*\%'..col..'c.\{-}\ze`\|\%'..col..'c`\zs.\{-}\ze`'
    let codespan = matchstr(line, pat)
    return substitute(codespan, '^:', '', '')
endfu
" }}}2
" Insert {{{2

" Most of these mappings take care of not breaking the undo sequence (`:h i^gU`).
" It means we can repeat an edition with the dot command, even if we use them.
" If you add another mapping, try to not break the undo sequence. Thanks.

" C-g             (prefix) {{{3
" C-h {{{4

" Sometimes, we want to do this:{{{
"
" ┌ exceeding amount of whitespace
" ├──────┐
"         some text
"     ↓
" some text
"│
"└ compacted whitespace
"}}}
" Also, sometimes we want to do this:{{{
"
" ┌ exceeding amount of whitespace
" ├─────┐
"        " some text
"     ↓
" " some text
" │
" └ compacted whitespace
"}}}

" This  mapping  tries  to  perform  both edits,  depending  on  the  amount  of
" whitespace between the comment leader and the rest of the text.
ino <silent> <c-g><c-h> <c-r>=<sid>compact_whitespace()<cr>

fu s:compact_whitespace() abort
    if empty(&l:cms) | return '' | endif
    let cml = '\V'..escape(matchstr(&l:cms, '\S*\ze\s*%s'), '\')..'\m'

    if getline('.') =~# cml..'\s\s' && &filetype isnot# 'markdown'
        let pat = '\s*'..cml..'\zs\s\+'
        let rep = ' '
    else
        let pat = '^\s*\ze\S'
        let rep = ''
    endif

    call setline('.', substitute(getline('.'), pat, rep, ''))
    return ''
endfu

" }}}3
" C-m             more granular undo {{{3

" Make `C-m` break the undo sequence.{{{
"
" When  we write  a paragraph  then press  `u` to  undo, Vim  removes the  whole
" paragraph. I want it to remove only the last line. Then the one before, etc.
" To get a more granular undo, we need to press `c-g u` every time we press `C-m`.
" This will break the undo sequence into smaller undo sequences.
" Every time  we press `c-g  u`, the current state  of the buffer  is accessible
" with `u`/`c-r`.
"
" See: `:h i_ctrl-g_u`
"}}}

fu s:c_m() abort
    if pumvisible()
        " If you change the code, make sure not to introduce a regression.{{{
        "
        " The code should be able to do this:
        "
        " Write `bug_` in a markdown buffer.
        " Press `Tab` to complete.
        " Select `bug_vim` in the pum.
        " Press `Enter`: the snippet should be expanded immediately.
        "
        " Expand the `vimrc` snippet.
        " Press `C-h` when you are at a tabstop containing a file path.
        " Insert a space.
        " Insert `/h`.
        " Press `C-g Tab` to complete the path.
        " Press `Enter`:  `/h` should be  completed with `/home`,  *and* another
        " completion should have been performed.
        "}}}
        let seq = "\<c-y>"
        let menu = get(get(get(complete_info(['items']), 'items', []), 0, {}), 'menu', '')
        if menu is# '[f]'
            let seq ..= "\<c-r>=completion#file#complete()\<cr>"
        elseif menu[:5] is# '[snip]'
            let seq ..= "\<c-r>=UltiSnips#ExpandSnippet()\<cr>"
        endif
        return seq
    endif

    " If we press Enter on a commented line with nothing in it, we want to delete everything.
    let cml = matchstr(&l:cms, '\S*\ze\s*%s')

    if empty(cml) | return "\<c-g>u\<cr>" | endif

    if getline('.') =~ '^\s*\V'..escape(cml, '\')..'\m\s*$'
        " We can't invoke `setline()` immediately, because of `<expr>`.
        call timer_start(0, {-> setline('.', '')})
        " Why don't you simply press `BS`?{{{
        "
        "     return "0\<c-d>"..repeat("\<BS>", strchars(cml) + 1)
        "
        " Not reliable, because sometimes BS deletes more than one char.
        " Happens after a sequence of whitespace.
        "}}}
        return ''
    endif

    return "\<c-g>u\<cr>"
endfu

ino <silent> <expr> <c-m> <sid>c_m()

" C-r             ignore `'autoindent'` when inserting register {{{3

ino <silent> <c-r> <c-r><c-p>
"                       ├───┘
"                       └ and fix the indentation while we're at it;
"                         use `<c-o>` if you prefer to preserve the indentation

" The previous `<c-r>` mapping breaks the default `:h i^r^o`; allow us to still use it.{{{
"
" You may wonder why `:h i^r^o` gets broken.
" Suppose you  press `C-r`  in insert mode;  Vim sees that  you have  2 mappings
" starting with `C-r`:
"
"     i  <C-R>       * <C-R><C-P>
"     i  <C-R><C-R><C-R> * <C-\><C-O>:call plugin#fzf#registers('i')<CR>
"
" It must wait another key to know which one you want to press.
"
" Then, suppose you  press `C-o`; Vim now  knows that you don't want  to use the
" 2nd mapping, but the  first mapping is still ok (it would  have been no matter
" what  you would  have pressed  – except  a 2nd  `C-r` –  because its  lhs only
" contains 1 key), and so Vim expands `C-r` into `C-r C-p`.
"
" In the end, the typeahead buffer contains:
"
"     C-r C-p C-o
"
" Which is not what you wanted, i.e. `C-r C-o`.
"}}}
ino <silent> <c-r><c-o> <c-r><c-o>
" the same issue could affect `:h i^r^p` if one day we use `<c-r><c-o>` in the `<c-r>` mapping
ino <silent> <c-r><c-p> <c-r><c-p>

" C-s             save {{{3

" I often type C-s in insert mode to save, and miss/forget the escape
" to get back in normal mode first.
" Alternative:
"     imap <c-s> <esc><c-s>
ino <silent> <c-s> <esc>:sil update<cr>

" M-a  M-e {{{3

ino <silent> <m-a> <c-r>=<sid>move_by_sentence(1)<cr>
ino <silent> <m-e> <c-r>=<sid>move_by_sentence(0)<cr>

fu s:move_by_sentence(fwd) abort
    if a:fwd
        norm! (
    else
        norm! )
    endif
    return ''
endfu

" \ {{{3

ino <silent> <bslash> <c-r>=<sid>indent_before_backslash()<cr>

fu s:indent_before_backslash() abort
    if &filetype isnot# 'vim'
        return '\'
    endif

    let has_text_before_cursor = matchstr(getline('.'), '.*\%'..col('.')..'c') =~# '\S'
    let prev_indent            = matchstr(getline(line('.')-1), '^\s*\\')
    let next_indent            = matchstr(getline(line('.')+1), '^\s*\\')

    if   has_text_before_cursor
    \ || empty(prev_indent) && empty(next_indent)
        return '\'
    endif

    let current_indent = empty(next_indent)
        \ ?     prev_indent
        \ :     next_indent

    "       ┌ if the cursor is in the middle of the indentation,
    "       │ `0 C-d` removes all whitespace before the cursor AND after
    "       ├─────┐
    return "0\<c-d>"..current_indent..' '
    "                 │                │
    "                 │                └ to avoid that `\?` or `\:`
    "                 │                  which can cause a bug when Vim parses
    "                 │                  the ternary operator `?:` in a lambda
    "                 │
    "                 └ includes a backslash at the end
endfu

" }}}2
" Normal {{{2
" SPC {{{3
" . {{{4

" `.` repeats the last edit.
" But if we want to repeat it on the same text which we've just changed (`@"`),
" we have to look for it manually.
"
" Solution:
" install a mapping which:
"
"    1. puts the last changed text in the search register
"    2. cuts its next occurrence
"    3. inserts the previously inserted text and stop insert

" After `<space>.`  has been pressed,  you can repeat  with `.`, <space>  is not
" needed anymore.
nno <expr><silent> <space>. <sid>repeat_last_edit_on_last_text()

fu s:repeat_last_edit_on_last_text() abort
    " put the last changed text inside the search register, so that we can refer
    " to it with the text-object `gn`

    "                                       ┌ last changed text
    "                                       │
    let last_text = '\V'..substitute(escape(@", '\'), '\n', '\\n', 'g')
    " The last changed text may contain newlines, but if it ENDs with one, we
    " usually don't want it.
    let last_text = substitute(last_text, '\\n$', '', '')
    let @/ = last_text

    set hlsearch
    "          ┌ insert the previously inserted text and stop insert
    "          ├────┐
    return "cgn\<c-@>"
endfu

" aa    ac    ad    al    an    arglist {{{4

nno <silent> <space>aa :<c-u>argedit %<cr>

" load Current argument
nno <silent> <space>ac :<c-u>argument<cr>

" Delete current argument
nno <silent> <space>ad :<c-u>.argdelete<cr>

" create Local arglist (by copying the global one)
nno <silent> <space>al :<c-u>arglocal<cr>

" start New arglist
"
" Define a new argument list, which is local to the
" current window, and containing only the current buffer.
" This causes the buffer to be reloaded.
" Add a bang to `:arglocal` to discard unsaved changes in the current buffer.
nno <silent> <space>an :<c-u>arglocal %<cr>

" i x                           ixquick, tmux prompt {{{4

" Why don't you use your shell script anymore?{{{
"
" It depends on tmux.
" It opens a whole new window which is distracting.
" It consumes a precious tmux key binding (easy-to-type tmux key bindings are not that numerous).
" It's brittle; it needs to properly set `LC_ALL`, some weird redirections, and a sleep...
" It can't escape special shell characters such as `*`, so sometimes a search may fail.
" ...
"
" If you need to read it, it's there: `~/bin/bash/search-engine`.
"}}}
nno <silent> <space>i :<c-u>call <sid>run_current_line('websearch')<cr>

" Tmux command-prompt has too limited editing capabilities.
" Let's use a Vim buffer to leverage Vim's editing capabilities.
nno <silent> <space>x :<c-u>call <sid>run_current_line('tmuxprompt')<cr>

fu s:run_current_line(type) abort
    if &ft is# a:type
        return
    endif
    let dir = $HOME..'/.vim/tmp'
    let file = dir..'/'..a:type
    let max_history = 100
    if !isdirectory(dir)
        call mkdir(dir, 'p', 0700)
    endif
    " make sure the history doesn't exceed `max_history` entries
    if filereadable(file)
        let lines = readfile(file)
        if len(lines) > max_history
            call writefile(lines[: max_history - 1], file)
        endif
    endif
    exe 'bo sp '..file
endfu

" s S                           saiw  saiW{{{4

nmap <space>s saiw
nmap <space>S saiW

" t                             new tab page {{{4

nno <silent> <space>t :<c-u>exe (v:count ? v:count..'tabnew' : 'tabnew')<cr>
"}}}3
" [    ] {{{3
" ]k ]j                           various alignments {{{4

" `[k`, `[j` align the beginning of the current line with the one of the previous/next line
" `]k`, `]j` align the end of the current line with the one of the previous/next line

nno <silent> [k :<c-u>call myfuncs#align_with_beginning_save_dir(-1)<bar>set opfunc=myfuncs#align_with_beginning<bar>norm! g@l<cr>
nno <silent> [j :<c-u>call myfuncs#align_with_beginning_save_dir(1)<bar>set opfunc=myfuncs#align_with_beginning<bar>norm! g@l<cr>
nno <silent> ]k :<c-u>call myfuncs#align_with_end_save_dir(-1)<bar>set opfunc=myfuncs#align_with_end<bar>norm! g@l<cr>
nno <silent> ]j :<c-u>call myfuncs#align_with_end_save_dir(1)<bar>set opfunc=myfuncs#align_with_end<bar>norm! g@l<cr>
" }}}3
" g {{{3
" g^ g$       first/last tabpage {{{4

nno <silent> g^ :<c-u>1tabnext<cr>
nno <silent> g$ :<c-u>$tabnext<cr>

" gV  g C-v   select last changed text {{{4

nno g<c-v> `[v`]
nno gV     '[V']

" g SPC       break line {{{4

nno <silent> g<space> :<c-u>set opfunc=<sid>break_line<bar>norm! g@l<cr>

fu s:break_line(_) abort
    " I sometimes press `g SPC` by  accident after getting back to the beginning
    " of a markdown file.
    " It creates a superfluous empty line.
    if col('.') == 1
        return
    endif

    try
        " break the line
        exe "norm! i\r"

        " trim ending whitespace on both lines
        keepj keepp .-,.s/\s\+$//e

        if !empty(bufname('%')) && fnamemodify(bufname('%'), ':p') isnot# $MYVIMRC
            sil update
        endif
    catch
        return lg#catch()
    endtry
endfu

" ga          easy align {{{4

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <plug>(EasyAlign)

" gf          & friends, in vimrc {{{4

" Purpose:
" When we're on a line enabling a plugin, it's convenient to be able to edit its
" configuration files by pressing `ZF`.
" So, we try to make `gf` & friends smarter.

augroup vimrc_mappings
    au!
    au BufReadPost $MYVIMRC call s:install_vimrc_mappings()
augroup END

fu s:install_vimrc_mappings() abort
    nno <buffer><nowait><silent> gf      :<c-u>call <sid>try_to_edit_plugin_config('gf')<cr>
    nno <buffer><nowait><silent> gF      :<c-u>call <sid>try_to_edit_plugin_config('gF')<cr>
    nno <buffer><nowait><silent> <c-w>f  :<c-u>call <sid>try_to_edit_plugin_config("\<lt>c-w>f")<cr>
    nno <buffer><nowait><silent> <c-w>F  :<c-u>call <sid>try_to_edit_plugin_config("\<lt>c-w>F")<cr>
    nno <buffer><nowait><silent> <c-w>gf :<c-u>call <sid>try_to_edit_plugin_config("\<lt>c-w>gf")<cr>
    nno <buffer><nowait><silent> <c-w>gF :<c-u>call <sid>try_to_edit_plugin_config("\<lt>c-w>gF")<cr>

    nmap <buffer><nowait> Z <c-w>
    " easier to press `ZGF` than `ZgF`
    nmap <buffer><nowait> <c-w>GF <c-w>gF
endfu

fu s:try_to_edit_plugin_config(cmd) abort
    let pat = '\C^\s*\<Plug\s\+''.\{-}/\%(vim-\)\=\zs.\{-}\ze\%([.-]vim\)\=/\='''
    let plugin = matchstr(getline('.'), pat)

    if empty(plugin)
        try
            exe 'norm! '..a:cmd..'zv'
        catch
            return lg#catch()
        endtry
    else
        let split = a:cmd[0] is# 'g' ? 'edit' : a:cmd[1] is# 'g' ? 'tabedit' : 'split'
        let files =  [$HOME..'/.vim/plugin/'..plugin..'.vim']
        let files += [$HOME..'/.vim/after/plugin/'..plugin..'.vim']
        let files += [$HOME..'/.vim/autoload/slow_call/'..plugin..'.vim']
        call filter(files, {_,v -> filereadable(v)})
        if empty(files)
            echo 'There''s no config file for '..string(plugin)
            return
        endif

        let a_file_is_opened = 0
        for f in files
            exe (a_file_is_opened ? 'sp ' : split)..f
            norm! zv
            let a_file_is_opened = 1
        endfor
    endif
endfu

" go {{{4

nno <silent> gof :<c-u>call myfuncs#gtfo_open_gui(expand('%:p:h', 1))<cr>
nno <silent> goF :<c-u>call myfuncs#gtfo_open_gui(getcwd())<cr>

nno <silent> got :<c-u>call myfuncs#gtfo_open_term(expand('%:p:h', 1))<cr>
nno <silent> goT :<c-u>call myfuncs#gtfo_open_term(getcwd())<cr>

" gQ {{{4

" In Ex mode,  every time we press a  key which is expanded into the  value of a
" custom function,  if the latter contains  empty lines, it will  raise an error
" (E501, E749).
"
" So, we  install a wrapper around  `gQ` to temporarily disable  all mappings in
" command-line mode.

"             ┌ make sure we have visited the command-line at least once since Vim's startup
"             │ otherwise E501:
"             │ probably because custom command-line mappings haven't been installed yet,
"             │ so `ToggleEditingCommands 0` is useless / too soon
"             ├───┐
nno <expr> gQ ":\e"..execute('ToggleEditingCommands 0', 'silent!')..'gQ'

" gt  gT      search todo/fixme (Tags) {{{4

nno <silent> gt :<c-u>call myfuncs#search_todo('buffer')<cr>
nno <silent> gT :<c-u>call myfuncs#search_todo('project')<cr>
"}}}3
" m {{{3
" m/  m?         put current location in loclist {{{4

" these mappings can be used to traverse an arbitrary set of locations in the
" current buffer, using `m/` and `m?` to populate/empty the loclist, and `[l`,
" `]l` to move from one location to the other

" If we use our breakdown plugin, it will make us lose the current loclist.
" But we could still recover it:    :lol[der]
"                                   :lhi[story]

" add current position in loclist
nno <silent> m/ :<c-u>call <sid>add_to_loclist(1)<cr>
" empty loclist
nno <silent> m? :<c-u>call <sid>add_to_loclist(0)<cr>

fu s:add_to_loclist(populate) abort
    if a:populate
        let s:my_marks =  get(s:, 'my_marks', [])
            \ + [{'bufnr': bufnr('%'), 'lnum': line('.'), 'col': col('.'), 'text': getline('.')}]
    else
        let s:my_marks = []
    endif
    "                       ┌ don't create a new loclist every time we invoke the function
    "                       │
    call setloclist(0, [], 'r', {'items': s:my_marks, 'title': 'My marks'})
endfu
" m!             matchadd / matchdelete search pattern {{{4

fu s:where_are_my_matches() abort
    if exists('w:my_matches')
        sil! call matchdelete(w:my_matches)
        unlet! w:my_matches
    else
        let w:my_matches = matchadd('WildMenu', '\c'..@/, 10)
    endif
endfu

nno <silent> m! :<c-u>noh <bar> call <sid>where_are_my_matches()<cr>
"}}}3
" U {{{3
" UM                undo changes during current session {{{4

let s:changenr_save = {}
augroup changenr_save
    au!
    au BufReadPost * call s:changenr_save()
augroup END

fu s:changenr_save() abort
    let bufnr = bufnr('%')
    if has_key(s:changenr_save, bufnr)
        return
    endif
    " Is `changenr()` reliable?{{{
    "
    " It was not in the past:
    " https://www.reddit.com/r/vim/comments/dszuz/gundo_my_little_undo_tree_visualization_plugin/c12ril4/
    "
    " `undotree().seq_cur` was not either.
    " But that has changed since 8.0.1290; now, they should both be reliable.
    "}}}
    let s:changenr_save[bufnr] = changenr()
endfu
" Ideas for other mappings navigating in the undo tree:{{{
"
"     " go to previous save
"     nno <silent> UH :<c-u>ea 1f <bar> call save#toggle_auto(0)<cr>
"     " go to next save
"     nno <silent> UL :<c-u>later 1f <bar> call save#toggle_auto(0)<cr>
"     nno <silent> UM :<c-u>exe 'undo '..undotree().seq_last <bar> call save#toggle_auto(0)<cr>
"}}}

" Don't use `UU`; I think we used it in the past, but pressed it by accident too often.
nno <silent> UM :call <sid>undo_changes_during_current_session()<cr>
fu s:undo_changes_during_current_session() abort
    let bufnr = bufnr('%')
    if !has_key(s:changenr_save, bufnr) || s:changenr_save[bufnr] == changenr()
        return
    endif
    exe 'undo '..s:changenr_save[bufnr]
endfu

" Ud  Up  Us       (fugitive) {{{4

" We need to unmap `U` in a fugitive buffer because it's used by fugitive
" (`:h fugitive_U`) to unstage everything; this prevents us from using `U`
" as a prefix key in the next mappings.
" TODO: Maybe we should remove this autocmd and map all our prefix keys to
" `<nop>` in *buffer-local* mappings.{{{
"
" This would be a more general solution to this particular problem.
" To implement this idea, you need to write this autocmd:
"
"     augroup cancel_prefix
"         exe 'au FileType * nno <buffer> '.pfx.' <nop>'
"         exe 'au FileType * xno <buffer> '.pfx.' <nop>'
"     augroup END
"
" inside the function `s:cancel_prefix()` from the file:
"
"     ~/.vim/after/plugin/nop.vim
"
" Issue: It would break the `-` fugitive mapping (`:h fugitive_-`) which we use.
" We would need to  re-install this mapping but I don't know how  to get the rhs
" programmatically; the latter contains sth like `<snr>123_`.
" I seem to  remember trying to use the  rhs of a fugitive mapping in  one of my
" own mapping, and it didn't work well; it's much trickier than what it seems.
"
" Anyway, this issue  highlights the importance of getting  `<plug>` mappings to
" override all of fugitive mappings.
"}}}
augroup unmap_fugitive
    au!
    au FileType fugitive nunmap <buffer> U
augroup END

nno <silent> Ud :<c-u>Gdiff<cr>
nno <silent> Up :<c-u>call <sid>try_fugitive_cmd('Gpush')<cr>
nno <silent> Us :<c-u>call <sid>try_fugitive_cmd('Gstatus')<cr>

fu s:try_fugitive_cmd(cmd) abort
    try
        exe a:cmd
    catch
        " Vim(echoerr):fugitive: file does not belong to a Git repository
        echohl ErrorMsg | echom v:exception | echohl NONE
        return
    endtry
    if a:cmd is# 'Gstatus'
        " Rationale:{{{
        "
        " When we press `q` in the window opened by `:Gstatus`, fugitive gives this warning message:
        "
        "     :Gstatus q is deprecated in favor of gq or the built-in <C-W>q
        "
        " It's annoying and distracting.
        "
        " ---
        "
        " Besides, by default, we end up in  the bottom window, which may not be
        " the one we were focusing before executing `:Gstatus`; IOW, we may lose
        " our focused window.
        "}}}
        nno <buffer><nowait><silent> q :<c-u>call <sid>close_fugitive_window()<cr>
        sil! keepj keepp 1;/^# \%(Changes\|Untracked files\)/
    endif
endfu

fu s:close_fugitive_window() abort
    " Do *not* try to be smart and focus the previous window immediately, then close the fugitive window.{{{
    "
    "     wincmd p
    "     exe winnr('#')..'close'
    "
    " The height of the remaining windows would be wrong.
    " When you close  a non-focused window with `:123close`, no  event is fired,
    " so `vim-window` does not reset the height of the remaining windows:
    "
    "     $ vim +'sp|sp'
    "     :1close
    "
    " You would need additional statements:
    "
    "     if &ft is# 'qf'
    "         wincmd _
    "     endif
    "     do <nomodeline> WinEnter
    "
    " The reason  why `wincmd _` is  necessary is because the  original previous
    " window may be a qf window; in that case you're now in a qf window, and
    " `do WinEnter` will make `vim-window` set  the height of *only* the latter;
    " it won't squash the other regular windows.
    "
    "     $ vim +'sp|sp|helpg foobar' +'copen'
    "     :1close
    "     :do WinEnter
    "
    " You could also replace `wincmd _ | do  WinEnter` with `wincmd p | wincmd p`,
    " but  it  would  fire  many  events  (`BufLeave`,  `WinLeave`,  `WinEnter`,
    " `BufEnter`,  `BufLeave`); the  fewer events,  the less  chance you  get an
    " unexpected result.
    "
    " As you can see, there are a few pitfalls; so don't try to be smart, be simple.
    "}}}
    let winid = lg#win_getid('#')
    close
    call win_gotoid(winid)
endfu
"}}}3
" z {{{3
" z= {{{4

" Will a repetition of this command open a new menu?{{{
"
" No, it will simply repeat the previous edit.
" Consider this text:
"
"     Hellzo peozple.
"
" Move your cursor on `Hellzo`, and press `z=` to fix it.
" Move your cursor on `peozple`, and press `.` to repeat.
" Vim will simply replace the word with `Hello`, it won't
" try to fix `people`.
"
" This is normal, do NOT try to change the code so that
" it opens a new menu.
" From `z=`:
"
"     When a word was replaced the redo command "." will
"     repeat the word replacement.  This works like "ciw",
"     the good word and <Esc>.
"}}}
" Do not replace `g@l` with `norm! g@l`.{{{
"
" The opfunc invokes `z=` which is an unfinished command (it requires the user input).
" As a  result, `:norm` would press Escape  and you would not be  able to choose
" the fixed word.
"}}}
nno <silent> z= :<c-u>call <sid>z_equal_save_count(v:count)<bar>set opfunc=<sid>z_equal<cr>g@l

fu s:z_equal_save_count(cnt) abort
    let s:z_equal_count = a:cnt
endfu

fu s:z_equal(_) abort
    let [spell_save, winid, bufnr] = [&l:spell, win_getid(), bufnr('%')]
    try
        setl spell
        if s:z_equal_count
            return feedkeys(s:z_equal_count..'z=', 'in')
        endif
        " Why not `norm! z=`?{{{
        "
        " We would not be  able to select an entry in  the menu, because `:norm`
        " would press `Escape`.
        " Indeed, it  considers `z=`  as in INcomplete  command, since  we don't
        " give it the number of the entry we want to select in advance.
        " From `:h norm`:
        "
        " > {commands} should be a complete command.  If
        " > {commands} does not finish a command, the last one
        " > will be aborted as if <Esc> or <C-C> was typed.
        "}}}
        " TODO: I don't know why, but `t` can't be used here. Find the reason why.{{{
        "
        " It would be interesting in our notes, to explain that `t` must only be
        " used when necessary.
        "}}}
        call feedkeys('z=', 'in')
    catch
        return lg#catch()
    finally
        call timer_start(0, {-> winbufnr(winid) == bufnr
            \ && call('settabwinvar', win_id2tabwin(winid) + ['&spell', spell_save])})
    endtry
endfu

" zd {{{4

" make `zd` repeatable
nno <silent> zd :<c-u>set opfunc=<sid>my_zd<bar>norm! g@l<cr>

fu s:my_zd(type) abort
    try
        norm! zd
    " `zd` only works when 'foldmethod' is "manual" or "marker".
    catch /^Vim\%((\a\+)\)\=:\%(E351\|E490\):/
        return lg#catch()
    endtry
endfu

" zg (&friends) {{{4

" The default commands to add good / bad words in:
"
"    - a temporary list  use an uppercase character
"    - a persistent list use only lowercase characters
"
"    ┌────────────┬──────────────┬──────────────┐
"    │            │ mark         │ undo         │
"    ├────────────┼──────┬───────┼──────┬───────┤
"    │            │ good │ wrong │ good │ wrong │
"    ├────────────┼──────┼───────┼──────┼───────┤
"    │ persistent │ zg   │ zw    │ zug  │ zuw   │
"    ├────────────┼──────┼───────┼──────┼───────┤
"    │ temporary  │ zG   │ zW    │ zuG  │ zuW   │
"    └────────────┴──────┴───────┴──────┴───────┘
"
" For the moment, I  prefer to always add good / bad words  to a temporary list,
" so that  my choices don't persist  across sessions. Therefore, I swap  all the
" commands (easier to type lowercase characters):

" mark word under cursor as good
nno <silent> zg :<c-u>call <sid>repeat_which_spell_command('zG')<bar>set opfunc=<sid>repeatable_spell_commands<bar>norm! g@l<cr>
nno <silent> zG :<c-u>call <sid>repeat_which_spell_command('zg')<bar>set opfunc=<sid>repeatable_spell_commands<bar>norm! g@l<cr>

" mark word under cursor as wrong
nno <silent> zw :<c-u>call <sid>repeat_which_spell_command('zW')<bar>set opfunc=<sid>repeatable_spell_commands<bar>norm! g@l<cr>
nno <silent> zW :<c-u>call <sid>repeat_which_spell_command('zw')<bar>set opfunc=<sid>repeatable_spell_commands<bar>norm! g@l<cr>

" undo the marking of word under cursor as good
nno <silent> zug :<c-u>call <sid>repeat_which_spell_command('zuG')<bar>set opfunc=<sid>repeatable_spell_commands<bar>norm! g@l<cr>
nno <silent> zuG :<c-u>call <sid>repeat_which_spell_command('zug')<bar>set opfunc=<sid>repeatable_spell_commands<bar>norm! g@l<cr>

" undo the marking of word under cursor as wrong
nno <silent> zuw :<c-u>call <sid>repeat_which_spell_command('zuW')<bar>set opfunc=<sid>repeatable_spell_commands<bar>norm! g@l<cr>
nno <silent> zuW :<c-u>call <sid>repeat_which_spell_command('zuw')<bar>set opfunc=<sid>repeatable_spell_commands<bar>norm! g@l<cr>

fu s:repeat_which_spell_command(cmd) abort
    let s:repeat_this_spell_command = a:cmd
endfu

fu s:repeatable_spell_commands(type) abort
    let cmd = s:repeat_this_spell_command
    let last_char = cmd[-1:-1]
    let last_char_is_uppercase = last_char is# toupper(cmd[-1:-1])
    let cmd_to_repeat = cmd[:-2]..(last_char_is_uppercase
        \ ? tolower(last_char)
        \ : toupper(last_char))
    exe 'norm! '..cmd
endfu
" }}}3
" | {{{3
" |c         execute the Compiler {{{4

" Why `:silent`?{{{
"
" To avoid a hit-enter prompt.
"}}}
" Why `:redraw!`?{{{
"
" To erase artifacts which appears because of `:silent`.
"}}}
" Why `:lmake` instead of `:make`?{{{
"
" Most of the time, we compile a single file, not a whole project.
" It makes more sense to use a location list, and not pollute the qf stack.
"}}}
" Why no `:lw` at the end?{{{
"
" There's no need to.
" `vim-qf` installs an autocmd which takes care of that.
"}}}
" Do *not* install a `<bar>c` mapping in a filetype plugin to set the compiler and then compile.{{{
"
" Unless you have to, because it requires some special handling.
"
" Instead, simply set the compiler in the filetype plugin with `:compiler foo`.
" This global `<bar>c` mapping will then use the right compiler.
"}}}
nno <silent> <bar>c :<c-u>call <sid>run_compiler()<cr>

fu s:run_compiler() abort
    if &l:mp =~# '\m\C^desktop-file-validate\>'
        sil update
        sil let out = system('desktop-file-validate '..shellescape(expand('%:p')))
        if out is# ''
            echo '[desktop-file-validate] OK'
        else
            echo out
        endif
        return
    endif

    let is_shellcheck = &l:mp =~# '\m\C^shellcheck\>'
    update
    sil lmake!
    redraw!

    if &ft is# 'qf' && is_shellcheck
        " install  `gx` mapping, to  let us open the  wiki page where  the error
        " under the cursor is documented
        nno <buffer><nowait><silent> gx :<c-u>call <sid>gx_shellcheck()<cr>
    endif
endfu

fu s:gx_shellcheck() abort
    let error_number = matchstr(getline('.'), '.\{-}|.\{-}\zs\d\+\ze\s*|')
    " `:ShellCheckWiki` is defined only in a shell buffer (i.e. in the previous window).
    wincmd p
    exe 'ShellCheckWiki'..error_number
    wincmd p
endfu

" |g         grep word under cursor / visual selection {{{4

" grep the word under the cursor, recursively in all the files of cwd
nno <silent> <bar>g :<c-u>set operatorfunc=myfuncs#op_grep<cr>g@

" same thing for visual selection
" Do not use `!g` for the `{lhs}`.{{{
"
" It  would introduce  some "lag"  whenever  we hit  `!` to  filter some  visual
" selection. We would need  to wait, or hit the second  character of our command
" to see the bang on the command-line.
"}}}
xno <silent> <bar>g :<c-u>call myfuncs#op_grep('vis')<cr>

" |t         translate {{{4

"                                            ┌ 1st invocation
"                                            │
nno <silent> <bar>t :<c-u>call myfuncs#trans(1)<cr>
nno <silent> <bar>T :<c-u>call myfuncs#trans_stop()<cr>
xno <silent> <bar>t :<c-u>call myfuncs#trans(1, 1)<cr>
"            │                                  │
"            │                                  └ visual mode
"            │
"            └ do NOT use `!t`, it would prevent you from writing a visual selection
"              on the standard input of a shell command whose name begins with a `t`
"
"              do NOT use `!<c-t>`, it would introduce lag when we press `!` in visual mode
"
"              do NOT use `<c-t>!`, it would be inconsistent with other similar mappings
"              Ex:
"
"                      xno <silent>  <bar>x  "my:TxSend(@m)<cr>
"                                    │
"                                    └ can't use `<c-x>!`, it would introduce lag when decreasing numbers

" cycle through several types of translations
nno <silent> coT :<c-u>call myfuncs#trans_cycle()<cr>
" }}}3
" = {{{3
" = C-p               fix indentation of pasted text {{{4

" Why not `=p`?{{{
"
" Already used in `vim-brackets` to paste and fix right afterward.
" Same for `=P`.
"}}}
nno =<c-p> m''[=']``

" =A                  toggle alignment {{{4

nno <silent> =A :<c-u>set opfunc=myfuncs#op_toggle_alignment<cr>g@
xno <silent> =A :<c-u>call myfuncs#op_toggle_alignment('vis')<cr>

" =d                  fix display {{{4

" In normal mode, we remapped `C-l` to give the focus to the right window.
" But by default, `C-l` redraws the screen by executing `:redraw!`.
"
" So, we need to bind `:redraw!` to another key, `=d` could be a good
" candidate.

nno <silent> =d :<c-u>call <sid>fix_display()<cr>

fu s:fix_display() abort
    let view = winsaveview()
    redraw! | redraws! | redrawt

    if &l:diff
        " update differences between windows in diff mode
        diffupdate!
        "         │
        "         └ check if the file was changed externally and needs to be reloaded
        call winrestview(view)
        return
    endif

    " reload filetype plugins (to reapply window-local options)
    " Why don't you run `do filetypeplugin filetype`?{{{
    "
    " It would only reload the default filetype plugins.
    "
    " It would not run our custom autocmds listening to `FileType`.
    " In particular, it would not run the autocmd in the `styled_comments` augroup.
    " For that, you would need to run:
    "
    "     do styled_comments filetype
    "
    " Nor would it run the autocmd in `my_default_local_formatoptions`.
    " For that, you would need to run:
    "
    "     do my_default_local_formatoptions filetype
    "
    " IOW, you would need to run an extra `:do` command for every custom augroup
    " you have installed; that's not manageable.
    "}}}
    exe 'do filetype '..&ft

    " Purpose:{{{
    "
    " We (or a plugin) may  temporarily disable the syntax highlighting globally
    " with `:syn off`, then restore it with `:syn on`.
    " In  that case,  the position  of the  autocmd which  installs the  default
    " syntax  groups is  moved *after*  our  custom autocmd  which installs  the
    " syntax groups related to comments.
    "
    " Because of this new order, the default autocmd undoes our custom one.
    " We need to re-install our custom autocmd *after* the default one.
    "}}}
    call s:styled_comments()

    " recompute folds
    let _ = foldlevel(1)
    " and their titles
    do <nomodeline> BufWinEnter

    " Re-install HGs which may have been cleared after changing the color scheme.{{{
    "
    " Remember that to change the brightness  of `seoul-256`, in effect, we *do*
    " change the color scheme.
    " Also, note  that `do Syntax` will  only re-install a HG  if its attributes
    " are defined in a syntax plugin which is sourced for the current buffer.
    "}}}
    " We already run `:do Syntax` from an autocmd listening to `ColorScheme`.  Is it really useful here?{{{
    "
    " Yes.
    "
    " For  performance  reason,  the  autocmd only  iterates  over  the  buffers
    " *displayed* in a window.
    "
    " MWE:
    "
    "     $ cat <<'EOF' >>~/.vim/after/syntax/conf.vim
    "     syn match confError /some error/
    "     hi confError ctermbg=red
    "     EOF
    "
    "     $ cat <<'EOF' >>/tmp/conf.conf
    "     # some comment
    "     some error
    "     EOF
    "
    "     $ vim ~/.bashrc /tmp/conf.conf
    "     :bn|bp " to source conf syntax plugin
    "     ]ol
    "     [ol
    "     :bn
    "
    " `some error` should be highlighted in red; it's not.
    " The `confError` HG has been cleared when we pressed `]ol` and `[ol`.
    " It has not been re-installed by  our autocmd, because there was no `.conf`
    " file displayed anywhere.
    "}}}
    "   Ok, but why `tabdo ... windo`?{{{
    "
    " We (or a plugin) may  temporarily disable the syntax highlighting globally
    " with `:syn off`, then restore it with `:syn on`.
    " In that  case, we need  to reinstall our  custom syntax groups  related to
    " comments in *all* buffers currently displayed in a window.
    "}}}
    let curwin = win_getid()
    tabdo let winnr = winnr() | windo do Syntax | exe winnr..'wincmd w'
    call win_gotoid(curwin)

    " Purpose:{{{
    "
    " Reset the min/max number of lines above the viewport from which Vim begins
    " parsing the buffer to apply syntax highlighting.
    "
    " Sometimes syntax highlighting is wrong, these commands should fix that.
    "
    " We could also be more radical, and execute:
    "
    "     :syn sync fromstart
    "
    " But after we execute it in our  vimrc, every time we source the latter, we
    " experience lag.
    "}}}
    syn sync minlines=200
    syn sync maxlines=400

    sil! call window#popup#close_all()
    call winrestview(view)
endfu

" =m                  fix macro {{{4

" Usage:
"     =ma  →  edit recording a
nno <silent> =m :<c-u>call <sid>fix_macro()<cr>

fu s:fix_macro() abort
    let c = getchar()
    if c < 97 || c > 123
        return
    endif
    let c = nr2char(c)
    " Why don't you use the command-line window?{{{
    "
    " When the  register contains some  special characters (like `C-u`),  and we
    " press  Enter  to  leave  the  command-line window,  the  register  is  not
    " populated with what we expect.
    "}}}
    40vnew
    setl bh=wipe bt=nofile nobl nomod noswf wfw wrap
    augroup fix_macro
        au! * <buffer>
        let s:fix_macro_c = c
        " What does this autocmd do?{{{
        "
        " It makes sure that an escape character is present at the end of the recording.
        "}}}
        "   Why does it do that?{{{
        "
        " If the recording ends with a CR, for some reason, Vim adds a `C-j`:
        "
        "     :let @a = "/pat\r"
        "     :reg a
        "     "a   /pat^M^J~
        "                ^^
        " Because of this, your macro may end  up moving the focus to the bottom
        " window, or do sth else if `C-j` is locally mapped to some action.
        "
        " By making  sure an `Escape`  is always at the  end of a  recording, we
        " prevent Vim from interfering with our macros.
        "
        " ---
        "
        " I suspect the explanation is contained at `:h file-formats`.
        " It's as if Vim thought the text in  the string came from a file in DOS
        " format (because `^M^J` is the `<EOL>` on DOS).
        " This is  weird because  setting `'fileformat'` and  `'fileformats'` to
        " `unix` does not fix the issue:
        "
        "     $ vim -es -Nu NONE +'set ffs=unix ff=unix|let @q = "xy\r"' +"pu=execute('reg q')" +'%p|qa!'
        "     Type Name Content
        "       l  "q   xy^M^J
        "                   ^^
        "}}}
        au QuitPre <buffer> call setreg(s:fix_macro_c, substitute(getline(1), "\e"..'\@1<!$', "\e", ''))
        \ | unlet! s:fix_macro_c
    augroup END
    nno <buffer><expr><nowait><silent> q reg_recording() isnot# '' ? 'q' : ':<c-u>q<cr>'
    nmap <buffer><nowait><silent> <cr> q
    nmap <buffer><nowait><silent> ZZ q
    let line = substitute(getreg(c), "\<c-m>\<c-j>$", "\<c-m>", '')
    call setline(1, line)
    norm! 1|0f'
endfu
"}}}3
" hyphen {{{3
" -a  -8           ascii / bytes info {{{4

" We remap `-a`  to a function of  the `unicode.vim` plugin which  gives us more
" info about the character under the cursor.
" In   particular,   its   unicode   name,   html   entity   (&entity_name;   OR
" &#entity_number;), and digraph inside parentheses (if there's one defined).
"
" We also capture the  output of the command in the `o` register,  to be able to
" dump it in a buffer.
nno <silent> -a  :<c-u>call <sid>unicode_ga()<cr>
fu s:unicode_ga() abort
    let @o = substitute(execute('UnicodeName', 'silent!'), '\s*$', '', '')
    UnicodeName
endfu

" We remap `-8` to `g8` for consistency.
nno <silent> -8  :<c-u>call <sid>get_charbyte()<cr>
fu s:get_charbyte() abort
    let @o = substitute(execute('norm! g8', 'silent!')[1:], '\s*$', '', '')
    echo @o
endfu

" -c               TOC {{{4

" Source:
" https://github.com/neovim/neovim/pull/4449#issuecomment-237290098

" In Neovim, they use `gO`. Should we do the same?
nno <silent> -c :<c-u>call myfuncs#tab_toc()<cr>
"             ^
"             Contents

" -f               show filetype {{{4

nno <silent>  -f  :<c-u>call <sid>print_filetype()<cr>
fu s:print_filetype() abort
    let @o = !empty(&ft) ? &ft : '∅'
    echohl Title
    echo '[filetype] '..@o
    echohl NONE <cr>
endfu

" full path current file
"
" C-g does sth similar (:h ^g), but its output is:
"
"    - noisy
"    - not colored
"    - unable to expand `~`
"    - relative to the working directory

" -P  -p           show filePath / :pwd {{{4

nno -P :<c-u>call <sid>print_cwd()<cr>
nno -p :<c-u>call <sid>print_full_path()<cr>

fu s:print_cwd() abort
    let fmt =<< trim END
        window-local: %s
        tab-local:    %s
        global:       %s
    END
    let @o = printf(join(fmt, "\n"), getcwd(), getcwd(-1, 0), getcwd(-1))
    echo @o
endfu

fu s:print_full_path() abort
    if &bt is# 'quickfix'
        let @o = get(w:, 'quickfix_title', 'no title')
        echo @o
        return
    endif

    let fname = expand('%:p')
    " later, we'll compare `fname` with its resolved form,
    " and the comparison may be wrongly different because of an extra ending slash
    let fname = substitute(fname, '/$', '', '')

    if fname is# ''
        let @o = '[No Name]'
    elseif &buftype is# 'quickfix'
        let @o = w:quickfix_title
    else
        if fname[0] is# '/' || fname =~# '^\l\+://'
            let resolved = resolve(fname)
            let @o = resolved is# fname ? fname : fname..' -> '..resolved
        else
            " Why is adding the current working directory sometimes necessary?{{{
            "
            " If you edit a new buffer whose path is relative (to the working
            " directory), `expand('%:p')` will return a relative path:
            "
            "     :cd /tmp
            "     :e foo/bar
            "     :echo expand('%:p')
            "}}}
            let @o = getcwd()..'/'..fname
        endif
    endif

    echo @o
endfu

" -q               faq {{{4

" Purpose:{{{
"
" Open a split in which you can write answers to a faq in a wiki.
" The height of the split will stay the same, even when you focus the wiki,
" because we temporarily set its window option 'pvw'.
" Also, we temporarily enable the “auto open folds” mode.
"}}}
" Usage:{{{
"
"     press `-q`: begin answering a faq in a wiki
"
"     press `-q` again: stop answering the faq
"}}}

nno <silent> -q :<c-u>exe <sid>faq()<cr>

fu s:faq() abort
    " If you move this function outside the vimrc, there's no guarantee that `$XDG_RUNTIME_VIM` is set.{{{
    "
    " In that case, rewrite the code like so:
    "
    "     " outside the function
    "     let s:DIR = getenv('XDG_RUNTIME_VIM') == v:null ? '/tmp' : $XDG_RUNTIME_VIM
    "
    "     ...
    "
    "     " inside the function
    "     if stridx(expand('%:p'), '/wiki/') == -1 && expand('%:p') isnot# s:DIR..'/faq'
    "}}}
    if stridx(expand('%:p'), '/wiki/') == -1 && expand('%:p') isnot# $XDG_RUNTIME_VIM..'/faq'
        return 'echo "you''re not in a wiki"'
    endif

    let this_tab = tabpagenr()
    let win_in_this_tab = filter(getwininfo(), {_,v -> v.tabnr == this_tab})
    let faq_file = $XDG_RUNTIME_VIM..'/faq'

    for win in win_in_this_tab
        if bufname(get(win, 'bufnr', '')) is# faq_file
            exe win.winnr..'q'
            sil! FoldAutoOpen 0
            return ''
        endif
    endfor

    call map(deepcopy(win_in_this_tab), {_,v -> getwinvar(v.winnr, '&pvw', 0)})
    if index(win_in_this_tab , 1) != -1
        return 'echoerr "E590: A preview window already exists: previewwindow"'
    endif

    if index(map(deepcopy(win_in_this_tab), {_,v -> bufname(v.bufnr)}), faq_file) != -1
        echo 'a window displaying  '..faq_file..'  already exists'
        return ''
    endif

    exe 'sp '..faq_file
    setl pvw
    sil! FoldAutoOpen 1
    wincmd p
    return ''
endfu

" -r               edit README {{{4

" Works also for a CONTENTS file.
"
" Idea: Create a `CONTENTS.md` file in each of your wiki.
" Use it as  a table of contents,  which briefly explains what each  page of the
" wiki is about.

nno <silent> -r :<c-u>call <sid>edit_readme()<cr>

fu s:edit_readme() abort
    if expand('%:p:h') is# $HOME
        sp ~/.README.md | exe '1'
        return
    endif
    let files = glob(expand('%:p:h')..'/*', 0, 1)
    let kwd = '\%(readme\|contents\)'
    let pat = '\c/'..kwd..'\%(\..\{-}\)\=$'
    let readmes = filter(files, {_,v -> v =~# pat})
    let readme = get(readmes, 0, '')
    if filereadable(readme) || isdirectory(readme)
        exe 'sp '..readme
        " Why `:exe`?{{{
        "
        " If later  you add  a bar  after the  command, `1`  will be  interpreted as
        " `:1p[rint]`; we don't want that side effect.
        "
        " MWE:
        "     " ✘ the 123th line is printed on the command-line
        "     123 | sleep 1
        "
        "     " ✔ nothing is printed
        "     exe '123' | sleep 1
        "}}}
        exe '1'
    endif
endfu

" -s               edit snippets {{{4

" Why did you remove `-S`, which showed all our snippets?{{{
"
" `SPC fs` is better.
" It  allows   us  to   fuzzy  search  our   snippets,  and   can  automatically
" inserts+expands the selected tab trigger.
"}}}
nno <silent> -s :<c-u>UltiSnipsEdit<cr>

" -U               show unicode table {{{4

" We define this mappping because  it's more convenient than the `:UnicodeTable`
" command, and  to install a buffer-local  mapping to close the  “unicode table“
" window with a single `q` (instead of `:q`).
nno <silent> -U :<c-u>call <sid>unicode_table()<cr>

fu s:unicode_table() abort
    UnicodeTable
    nno <buffer><expr><nowait><silent> q reg_recording() isnot# '' ? 'q' : ':<c-u>q<cr>'
endfu

" }}}3
" plus {{{3
" +>    +<      split/join listing or long data {{{4

" long data = dictionary, list, bulleted list

nno <silent> +> :<c-u>set opfunc=myfuncs#long_data_split<bar>norm! g@l<cr>
nno <silent> +< :<c-u>set opfunc=myfuncs#long_data_join<cr>g@
xno <silent> +< :<c-u>call myfuncs#long_data_join('vis')<cr>

" +e            emphasize {{{4

" word → *word*
" WORD → *word*
nno <silent> +e :<c-u>set opfunc=<sid>emphasize<cr>g@l
fu s:emphasize(_) abort
    let word = expand('<cword>')
    if word !~# '^\k*$' | return | endif
    let [line, col] = [getline('.'), col('.')]
    " the negative lookbehind is  necessary to prevent a match when  we are on a
    " sequence of whitespace before a word
    let pat = '\%(\%'..col..'c.\+\)\@<!'..word..'\%(.*\%'..col..'c\)\@!'
    if line !~# pat | return | endif
    let rep = '*'..tolower(word)..'*'
    let new_line = substitute(line, pat, rep, '')
    call setline('.', new_line)
endfu

" +t            trim whitespace {{{4

nno <silent> +t  :<c-u>set opfunc=myfuncs#op_trim_ws<cr>g@
xno <silent> +t  :<c-u>call myfuncs#op_trim_ws('vis')<cr>
nno <silent> +tt :<c-u>set opfunc=myfuncs#op_trim_ws<bar>exe 'norm! '..v:count1..'g@_'<cr>
" }}}3

" CR / Tab / Shift / Control / Meta {{{3
" CR                  move cursor on 80/100 column {{{4

" If the buffer is special (`!empty(&buftype)`), we let `CR` unchanged.
" Special  buffers  include   the  ones  displayed  in  the   quickfix  and  the
" command-line windows.
" It's important to not alter the behavior of `CR` in those buffers, because
" usually it's already mapped to a very useful function such as executing
" a command or going to an entry in the quickfix list.
"
" Otherwise, if the buffer is a regular one, we remap `CR` to move on the 80th
" column. It can be overridden on a filetype-basis, by an arbitrary Ex command.
" Example:
"         let b:cr_command = 'echo "hello"'
"
" If we wrote the previous line in a python ftplugin, hitting CR would display
" 'hello'.

nno <expr><silent> <cr> !empty(&buftype)
                     \ ?     '<cr>'
                     \ :     ':<c-u>'..getbufvar('%', 'cr_command', 'norm! 80<bar>')..'<cr>'
"                               │
"                               └ important, otherwise, if we hit a nr
"                               (e.g. 42) by accident before `CR`, it would do:    :42norm! 100|
"                               which would move the cursor 42 lines below the
"                               current one

" S-→    C-↑ ...      modified arrow keys {{{4

" A  terminal  emulator  gives  its  name to  the  programs  through  the  shell
" environment variable `$TERM`.

" When  Vim runs  inside a  terminal whose  name begins  with `xterm`  (`xterm`,
" `xterm-256color`), it automatically sets up  a few keys including the modified
" arrow keys (`S-Left`, `S-Right`, `C-Up`, `C-Down` ...).
"
" However, if the name  of the terminal begins with `screen`  or `tmux`, it does
" *not* set up those keys.
" For  tmux  to  function  properly,   we  have  configured  `~/.shrc`  so  that
" `$TERM=tmux-256color` (in tmux only, not in basic terminal emulator).
" Because of this, Vim does *not* set up the modified arrow keys when we run it
" inside tmux. This means we can't map any action to a modified arrow key.
" For example, by  default Vim moves the  cursor by word in normal  mode when we
" hit `S-Left` / `S-Right`.
"
" We need to set up the modified arrow keys ourselves.

" To understand the code, read:
" https://unix.stackexchange.com/a/34723/289772
"
" From `:h version7`:
"
" > Not all modifiers were recognized for xterm function keys.  Added the
" > possibility in term codes to end in ";*X" or "O*X", where X is any
" > character and the * stands for the modifier code.
" > Added the <xUp>, <xDown>, <xLeft> and <xRight> keys, to be able to
" > recognize the two forms that xterm can send their codes in and still
" > handle all possible modifiers.
"
" The `*` in the next code stands for the modifier `C-`, `S-`, `M-`.
" While the `x` is there because it seems that `xterm` can send codes in
" 2 forms.
"
" See also: `:h xterm-modifier-keys`.

if $TERM =~# '^\%(screen\|tmux\)'
    sil! exe "set <xUp>=\e[1;*A"
    sil! exe "set <xDown>=\e[1;*B"
    sil! exe "set <xRight>=\e[1;*C"
    sil! exe "set <xLeft>=\e[1;*D"
endif

" C-]                 jump to definition {{{4

" Purpose:{{{
"
" This mapping overloads `C-]`.
"
" It keeps  its default behavior, however,  if it fails because  there's no tags
" file, it tries `1gd` as a fallback.
"
" It's useful for example, in `~/bin`, where atm we don't have any tags file.
"}}}
" Why `1gd` instead of `gd`?{{{
"
" Sometimes, `gd` jumps  to a location where the identifier  under the cursor is
" present, but it's not its definition.
" It happens for example,  if you have a shell script  which includes a function
" `install`, and the command `aptitude install package` somewhere in a function.
"
" `1gd` makes `gd` ignore any occurrence of the identifier which is inside curly
" brackets, and with  the closing one written  on a column whose  index is lower
" than the one of the current cursor position.
"}}}
nno <silent> <c-]> :call <sid>jump_to_definition()<cr>

fu s:jump_to_definition() abort
    try
        exe "norm! \<c-]>zvzz"
    catch /^Vim\%((\a\+)\)\=:E\%(426\|433\)/
        if &filetype isnot# 'help'
            norm! 1gd
            norm! zvzz
        else
            return lg#catch()
        endif
    catch
        return lg#catch()
    endtry
endfu

" C-np                move across tab pages {{{4

nno <silent> <c-p> :<c-u>tabprevious<cr>
nno <silent> <c-n> :<c-u>exe (v:count > 1 ? v:count : '')..'tabnext'<cr>

" C-w s               send to tab page {{{4

nno <silent> <c-w>s :<c-u>call <sid>send_to_tab_page(v:count)<cr>

fu s:send_to_tab_page(cnt) abort
    let cnt = a:cnt
    let curtab = tabpagenr()
    " if we don't press a count before the lhs, we want the chance to provide it afterward
    if cnt == 0
        " TODO: It would be nice if we could select the tab page via fzf.{{{
        "
        "     " prototype
        "     nno cd :<c-u>call fzf#run({
        "     \   'source': range(1, tabpagenr('$')),
        "     \   'sink': function('Func'),
        "     \   'options': '+m',
        "     \   'left': 30,
        "     \ })<cr>
        "     fu Func(line) abort
        "         exe a:line..'tabnext'
        "     endfu
        "
        " We  still need  to figure out  how to  preview all the  windows opened  in the
        " selected tab page.
        "}}}
        let cnt = input('send to tab page nr: ')
        if cnt is# '$'
            let cnt = tabpagenr('$')
        elseif cnt !~# '^[+-]\=\d*[1-9]\d*$'
            redraw | if cnt isnot# '' | echo 'not a valid number' | endif | return
        " parse a `+2` or `-3` number as an index relative to the current tabpage
        elseif cnt[0] =~# '+\|-'
            let cnt = eval(curtab..cnt[0]..matchstr(cnt, '\d\+'))
        else
            let cnt = matchstr(cnt, '\d\+')
        endif
    endif
    if cnt == curtab
        redraw | echo 'current window is already in current tab page' | return
    elseif cnt > tabpagenr('$')
        redraw | echo 'no tab page with number '..cnt | return
    endif
    let bufnr = bufnr('%')
    " close the window
    q
    " focus target tab page
    exe 'tabnext '..cnt
    " open new window displaying the buffer from the closed window in the target tab page
    exe 'sb '..bufnr
endfu

" M-n    M-p          navigate between marks {{{4

nno <m-n> ]'
nno <m-p> ['
" }}}3
" !f                  show info about current file {{{3

nno !f <c-g>

" _                   0_ {{{3

" Issue:
"
"     # start xterm with default geometry (80 columns)
"     $ vim -Nu NONE +"pu='some short text'" +"pu=repeat(' ', 50)..repeat('some long text ', 10)" +'setl nowrap'
"     " press `$` to move to the end of the line
"     " press `_` to move to the first non-whitespace of the line
"
"     " the text of the first line is partially hidden:
"     " you can only read `text`, not `some short text`
"
" Solution:
nno _ 0_

" >>                  indent without 'shiftround' {{{3

" You refer to `v:count1` in the mapping, then in the function. Isn't it too much?{{{
"
" No.
" In the mapping, you can't press `g@` without `v:count1`.
" `g@` alone would reset `v:count1` to `1`.
"
" We could probably use `']` and the `>` operator in our function,
" but `v:count1` seems simpler.
"}}}
nno <silent> >> :<c-u>call <sid>indent_without_shiftround_save('increase')<bar>set opfunc=<sid>indent_without_shiftround<bar>exe 'norm! '..v:count1..'g@l'<cr>
nno <silent> << :<c-u>call <sid>indent_without_shiftround_save('decrease')<bar>set opfunc=<sid>indent_without_shiftround<bar>exe 'norm! '..v:count1..'g@l'<cr>

fu s:indent_without_shiftround_save(dir) abort
    let s:indent_without_shiftround_dir = a:dir
endfu

fu s:indent_without_shiftround(type) abort
    let op = (s:indent_without_shiftround_dir is# 'increase' ? '>>' : '<<')
    let sr_save = &shiftround
    try
        set shiftround
        exe 'norm! '..v:count1..op
    catch
        return lg#catch()
    finally
        let &shiftround = sr_save
    endtry
endfu

" Why don't you use the following code anymore.{{{
"
" It breaks  `>>` and `<<`, because as  soon as you press `>` or  `<`, Vim calls
" the corresponding operator.
" When we press `>`/`<` a second time, we don't provide a valid motion/text-object.
" Therefore, the operation is cancelled.
"}}}

" What did these mappings?{{{
"
" They indent  a text-object, like  the default  `>` and `<`,  while temporarily
" disabling 'sr'.
"}}}
" Why did you install them?{{{
"
" Watch:
"     foo
"       bar
"     baz
"
" press `>ip`
"
"            foo~
"            bar~
"            baz~
"
" The relative indentation between them has been lost.
" They now all have the same  indentation level, while before `bar` had a bigger
" indentation level.
"
" The cause seems to be 'sr'.
"}}}
" nno  <silent>  >  :<c-u>call <sid>set_indentation_direction('increase')
"                   \ <bar>set opfunc=<sid>indent_without_shiftround<cr>g@
"
" nno  <silent>  <  :<c-u>call <sid>set_indentation_direction('decrease')
"                   \ <bar>set opfunc=<sid>indent_without_shiftround<cr>g@
"
" fu s:set_indentation_direction(dir) abort
"     if a:dir is# 'increase'
"        let s:indentation_direction = 'increase'
"     else
"        let s:indentation_direction = 'decrease'
"     endif
" endfu
"
" fu s:indent_without_shiftround(type) abort
"     let sr_save = &sr
"     try
"         set nosr
"         let operator = get(s:, 'indentation_direction', '') is# 'decrease' ? '<' : '>'
"         exe 'norm! '..line("'[")..'G'..operator..line("']")..'G'
"     catch
"         return lg#catch()
"     finally
"         let &sr = sr_save
"     endtry
" endfu

" <b  >b              destroy/create box {{{3

" Draw a box around the text inside the paragraph.
" The fields must be separated with `|`.
" The function will populate the `s` and `x` registers with 2 kind of
" separation lines. We can paste them to fine tune the box.
nno <silent> >b :<c-u>set opfunc=myfuncs#box_create<cr>g@ip

" undo the box, make it come back to just bars between cells
nno <silent> <b :<c-u>set opfunc=myfuncs#box_destroy<cr>g@ip

" ""                  easier access to system register (and clean paste in mardown) {{{3

" We don't tweak `'cb'` anymore, because it causes too many issues.
" We use a mapping instead.
" We also leverage  this mapping to replace  some characters after a  paste in a
" markdown file; e.g. `’` → `'`.

nno <expr> "" <sid>easy_and_custom_paste()
xno "" "+

fu s:easy_and_custom_paste() abort
    let [contents, type] = [getreg('+'), getregtype('+')]
    " We manipulate the `+` register in case we're going to paste it.
    " But what if we're going to yank some text into it?{{{
    "
    " Our manipulation won't have any effect.
    " Whatever  we're going  to yank  will overwrite  the old  (and manipulated)
    " register.
    "}}}
    if &ft is# 'markdown'
        let contents = substitute(contents, '’', "'", 'g')
        let contents = substitute(contents, '\w\zs \ze, \w', '', 'g')
        if contents =~# '\m\C^\s*http' && getline('.') =~# '^\S\|^$'
            au TextChanged <buffer> ++once s/^\s*\zshttp.*/<&>/e
        endif
    endif
    let contents = substitute(contents, '٪', '$', 'g')
    call setreg('+', contents, type)
    return '"+'
endfu

" { }                 move by paragraphs {{{3

nno <silent> { :<c-u>call search('\(^\s*$\<bar>\%^\)\_s*\zs\S', 'bW')<cr>zv
nno <silent> } :<c-u>call search('\S\+.*\ze\n\s*$', 'W')<cr>zv

" c*                  change word under cursor {{{3

" What you need to know to understand these mappings:
"
"       cgn    change next occurrence of search register
"       cgN    change previous occurrence of search register
"
"       we've enabled 'ignorecase', because it's convenient for a broader search
"       we've enabled 'smartcase', to make Vim a bit smarter:
"
"               if the search register contains uppercase characters, we
"               probably want to take the case into account
"
"       `*` and `/` are resp. stupid and clever, because the former ignores
"       'smartcase' while the latter respects it
"
"       the `c*` mapping uses `*` to populate the search register
"       so, it will be stupid, and we need to make it clever:
"               /<up><cr>``
"               │
"               └ fixes `*` stupidity


"      ┌ populate search register with word under cursor
"      │
"      │┌ get back where we were
"      ││
"      ││          ┌ get back where we were
"      ││          │
"      ││          │ ┌ change next occurrence of pattern
"      ││          │ ├─┐
nno c* *``/<up><cr>``cgn
"         ├───────┘
"         └ take 'smartcase' into account

nno c# #``/<up><cr>``cgN


" We also install `cg*` and `cg#` if we want to look for the word under the
" cursor WITHOUT the anchors `\<`, `\>`.
nno cg* g*``/<up><cr>``cgn
nno cg# g#``/<up><cr>``cgN

" crg                 coerce to glyph {{{3

" The behavior of this operator can be customized via
" g:Unicode_ConvertDigraphSubset.
" Have a look at: ~/.vim/after/plugin/abbrev.vim

nmap crg  <plug>(MakeDigraph)
nmap crgg <plug>(MakeDigraph)_

" d[gv]...            delete all lines containing/excluding some pattern {{{3

" If you need to delete folds, use `zd`, `zD`, or `zE`.
" They also work in visual mode (except `zE`).

nno <silent> dg<space> :<c-u>call myfuncs#delete_matching_lines('empty')<cr>
xno <silent> mg<space> :<c-u>call myfuncs#delete_matching_lines('empty', 'vis')<cr>

nno <silent> dg" :<c-u>call myfuncs#delete_matching_lines('comments')<cr>
nno <silent> dv" :<c-u>call myfuncs#delete_matching_lines('comments', 'reverse')<cr>
xno <silent> mg" :<c-u>call myfuncs#delete_matching_lines('comments', 'vis')<cr>
xno <silent> mv" :<c-u>call myfuncs#delete_matching_lines('comments', 'vis+reverse')<cr>

nno <silent> dg/ :<c-u>call myfuncs#delete_matching_lines('@/')<cr>
nno <silent> dv/ :<c-u>call myfuncs#delete_matching_lines('@/', 'reverse')<cr>
xno <silent> mg/ :<c-u>call myfuncs#delete_matching_lines('@/', 'vis')<cr>
xno <silent> mv/ :<c-u>call myfuncs#delete_matching_lines('@/', 'vis+reverse')<cr>

" dr                  replace without yank {{{3

" We save the name of the register which was called just before `dr` inside
" a script-local variable (`s:replace_reg_name`) through the `myfuncs#set_reg()`
" function. Why?
" Because if we repeat the operation with `.`, we want the operator to look
" for the replacement text from the same register that we used the first time.
" The dot command doesn't save that information.
" So, we have to do it manually.

" TODO: maybe we could get rid of `myfuncs#set_reg()` and use `repeat#setreg()` instead.

nno <silent> dr :<c-u>call myfuncs#set_reg(v:register)
                \ <bar>set opfunc=myfuncs#op_replace_without_yank<cr>g@

nno <silent> drr :<c-u>call myfuncs#set_reg(v:register)
                 \ <bar>set opfunc=myfuncs#op_replace_without_yank
                 \ <bar>exe 'norm! '..v:count1..'g@_'<cr>

" j  k  ^  0  $       gj  gk  ... {{{3

" By default, we can't move across several lines of a long wrapped line with
" `j` and `k`.
"
"                    ┌ if we used a count, we probably don't care about wrapped lines
"                    │
nno <expr><silent> j v:count ? (v:count >= 5 ? "m'".v:count : '').'j' : 'gj'
nno <expr><silent> k v:count ? (v:count >= 5 ? "m'".v:count : '').'k' : 'gk'
"                              ├────────────────────────────────┘
"                              └ if the count was bigger than 5,
"                                we consider the motion as a jump useful to come back with `c-o`

nmap <down> j
nmap <up> k

" If we're inside a long wrapped line, `^` and `0` should go the beginning
" of the line of the screen (not the beginning of the long line of the file).
nno <silent> ^ g^
nno <silent> 0 g0

" To draw freely, sometimes we need to enable 'virtualedit'.
" And then, when we press `$`, the cursor moves to the very end of the screen.
" We never want that. We want the cursor on the last non whitespace.
nno <expr> $ &virtualedit is# 'block' ? '$' : 'g_'
" Do *not* use `g$` by default (i. e. don't write `g$` in the lhs when 've' is 'block')!  Keep using `$`.{{{
"
" It would break the dot command when you've pressed `$` right before.
"
" MWE:
"
"     $ vim -Nu NONE =(cat <<'EOF'
"     foo = a
"           ab
"           abc
"     EOF
"     )
"
"     / a$
"     C-v G h A '
"     g$ .
"
" Result:
"
"     foo = 'a'
"           'a'b
"           'a'bc
"
" Expected:
"
"     foo = 'a'
"           'a'b
"           'abc'
"
" Theory: Maybe `$` moves the cursor on the  newline, while `g$` moves it on the
" last character of the screen line (excluding the newline).
" And for the dot command to work as expected, we need to be on the newline...
"}}}

" Same mappings for visual mode.
xno <silent> j gj
xno <silent> k gk
xno <silent> ^ g^
xno <silent> 0 g0

" J        gJ         join without moving {{{3

" Why don't you use `@=` to make our custom `J` support a count?{{{
"
" Yeah, in the past we installed this:
"
"     nno  <silent>  J  @="m'J``"<cr>
"
" But I raises an issue when you replay a macro with `@@` which contains `J`:
"
"     $ printf 'ab\ncd\nef\ngh\nij\nkl' | vim -Nu NONE +'nno J  @="J"<cr>' -
"     qq A, Esc J q
"     j @q
"     j @@
"
" You should get `ij, kl` in the last line, but instead you'll get `ij kl`.
"
" I think that's  because when you replay  a macro with `@@`, the  last macro is
" redefined by `@=`.
"}}}
nno <expr> J "m'"..v:count1..'J``'

" gJ doesn't insert or remove any spaces
nno <expr> gJ "m'"..v:count1..'gJ``'

" Q        q {{{3

" no more entering Ex command by accident
nno Q q

" Y        y$ {{{3

nno Y y$

" We can't separate a register name from the `y` command, with a motion.
" They  must be consecutive. Otherwise the  yanking fails to target  the desired
" register. MWE:
"
"     C-v 3j "+ $ y    ✘
"     C-v 3j $ "+ y    ✔
"
" As  soon as  we type  the `$`  motion, the  register name  is lost  (watch the
" command-line).
" So, we use an  expression, to make sure that they are consecutive.
xno <expr> Y '$"'.v:register.'y'

" y[cC]  y[mM]        yank code / Comments  matching / non-matching lines {{{3

" code
"                  don't yank where a commented line is found ┐
"                                                             │
nno <silent> yc :<c-u>call myfuncs#op_yank_matches_set_action(0, 1)
                \ <bar> set opfunc=myfuncs#op_yank_matches<cr>g@
xno <silent> myc :<c-u>call myfuncs#op_yank_matches_set_action(0, 1)
                 \ <bar> call myfuncs#op_yank_matches('vis')<cr>

" Comments
nno <silent> yC :<c-u>call myfuncs#op_yank_matches_set_action(1, 1)
                \ <bar> set opfunc=myfuncs#op_yank_matches<cr>g@
xno <silent> myC :<c-u>call myfuncs#op_yank_matches_set_action(1, 1)
                 \ <bar> call myfuncs#op_yank_matches('vis')<cr>

" lines matching last search
nno <silent> ym :<c-u>call myfuncs#op_yank_matches_set_action(1, 0)
                \ <bar> set opfunc=myfuncs#op_yank_matches<cr>g@
xno <silent> mym :<c-u>call myfuncs#op_yank_matches_set_action(1, 0)
                 \ <bar> call myfuncs#op_yank_matches('vis')<cr>

" lines which do NOT match last search
nno <silent> yM :<c-u>call myfuncs#op_yank_matches_set_action(0, 0)
                \ <bar> set opfunc=myfuncs#op_yank_matches<cr>g@
xno <silent> myM :<c-u>call myfuncs#op_yank_matches_set_action(0, 0)
                 \ <bar> call myfuncs#op_yank_matches('vis')<cr>
" }}}2
" Objects {{{2
" i- {{{3

xno <silent> i- :<c-u>call <sid>horizontal_rules_textobject('inside')<cr>
xno <silent> a- :<c-u>call <sid>horizontal_rules_textobject('around')<cr>

ono <silent> i- :<c-u>norm vi-<cr>
ono <silent> a- :<c-u>norm va-<cr>

fu s:horizontal_rules_textobject(adverb) abort
    " select "inside" by default (we'll update the selection to get "around" later if necessary)
    if &ft is# 'markdown'
        let start = '^\%(---\|#.*\)\n\zs\|\%^'
        let end = '\n\ze\%(---\|#.*\)$\|\%$'
    else
        let cml = matchstr(&l:cms, '\S*\ze\s*%s')
        let comment = '\V'..escape(cml, '\')..'\m'
        let fmr = '\%('..join(split(&l:fmr, ','), '\|')..'\)\d*'
        let start = '^\s*'..comment..'\s*\%(---\|.*'..fmr..'\)\n\zs'
              \ ..'\|^\%(\s*'..comment..'\)\@!.*\n\zs\s*'..comment
              \ ..'\|\%^'
        let end = '\ze\n\s*'..comment..'\s*\%(---\|.*'..fmr..'\)$'
              \ ..'\|^\s*'..comment..'.*\n\%(\s*'..comment..'\)\@!'
    endif
    call search(start, 'bcW')
    norm! V
    call search(end, 'W')
    if a:adverb isnot# 'around' | return | endif
    if &ft is# 'markdown'
        if getline(line('.')+1) is# '---'
            norm! j
        elseif getline(line('v')-1) is# '---'
            norm! oko
        endif
    else
        if getline(line('.')+1) =~# '^\s*'..comment..'\s*---$'
            norm! j
        elseif getline(line('v')-1) =~# '^\s*'..comment..'\s*---$'
            norm! oko
        endif
    endif
endfu

" iE {{{3

" Entire buffer
" We don't use `ie` but `iE`, because `ie` is too easily typed.
" We could easily delete the whole buffer `cie`, `die` by mistake.

xno <silent> iE G$ogg0
ono <silent> iE :<c-u>norm ViE<cr>

" if {{{3

" Vim function

" FIXME: Not reliable text objects (check out kana plugin).
" Fix also `o_il` and `o_al` (i.e. add support for visual mode).
xno <silent> if :<c-u>call <sid>textobj_func(1)<cr>
ono <silent> if :<c-u>norm Vif<cr>

xno <silent> af :<c-u>call <sid>textobj_func(0)<cr>
ono <silent> af :<c-u>norm Vaf<cr>

fu s:textobj_func(inside) abort
    if search('^\s*fu\%[nction]', 'bcW')
        norm! m<
        call search('^\s*endf\%[unction]\s*$', 'eW')
        norm! m>
        exe 'norm! gv$'..(a:inside ? 'koj' : '')
        " we want a linewise selection no matter the original visual mode
        exe (mode() isnot# 'V' ? 'norm! V' : '')
    endif
endfu

" il {{{3

" `il` = in line (operate on the text between first and last non-whitespace on the line)
" Useful to copy a line and paste it characterwise (in the middle of another line)

ono <silent> il :<c-u>norm! _vg_<cr>
ono <silent> al _

" We don't need to create `al` (around line) to operate on the whole line
" including newline, because `_` can be used instead.
" Example:
"
"     +y_
"     +y3_
"
" ... add current line to plus register (`+y` = custom operator, incremental yanking).
" Besides, an operator should  be able to operate on the  current line when it's
" repeated (`cc`, `yy`, `dd`...).
" But still, it brings consistency/symmetry.

" in {{{3

" Source: https://vimways.org/2018/transactions-pending/

" Pattern matching numbers.
" The order matters ... Keep `\d` last!.
" `\+` will be appended to the end of each.
let s:pat_numbers =<< trim END
    0b[01]
    0x\x
    \d
END

fu s:around_number() abort "{{{4
    " This can handle the following three formats:{{{
    "
    "   1. binary  (eg: "0b1010", "0b0000", etc)
    "   2. hex     (eg: "0xffff", "0x0000", "0x10af", etc)
    "   3. decimal (eg: "0", "0000", "10", "01", etc)
    "
    " If there  is no number on  the rest of  the line starting at  the  current
    " cursor  position, then  visual selection  mode  is ended  (if  called  via
    " `:omap`) or nothing is selected (if called via `:xmap`).
    " This is true even if on the space following a number.
    "}}}

    let stopline = line('.')

    " create pattern matching any binary, hex, decimal number
    let pat = join(s:pat_numbers, '\+\|')..'\+'

    " move cursor to end of number
    if !search(pat, 'ceW', stopline)
        " if it fails, there was not match on the line, so return prematurely
        return
    endif

    " move cursor to end of any trailing whitespace (if there is any)
    call search('\%'..(virtcol('.')+1)..'v\s*', 'ceW', stopline)

    " start visually selecting from end of number + potential trailing whitspace
    norm! v

    " move cursor to beginning of number
    call search(pat, 'bcW', stopline)

    " move cursor to beginning of any whitespace preceding number (if any)
    call search('\s*\%'..virtcol('.')..'v', 'bW', stopline)
endfu
" }}}4

" next number on line and possible surrounding whitespace
xno <silent> an :<c-u>call <sid>around_number()<cr>
ono <silent> an :<c-u>call <sid>around_number()<cr>

fu s:in_number() abort "{{{4
    " select the next number on the line

    let stopline = line('.')

    " Create pattern matching any binary, hex, decimal number.
    let pat = join(s:pat_numbers, '\+\|')..'\+'

    " move cursor to end of number
    if !search(pat, 'ceW', stopline)
        " if it fails, there was not match on the line, so return prematurely
        return
    endif

    " start visually selecting from end of number
    norm! v

    " move cursor to beginning of number
    call search(pat, 'bcW', stopline)
endfu
" }}}4

" next number after cursor on current line
xno <silent> in :<c-u>call <sid>in_number()<cr>
ono <silent> in :<c-u>call <sid>in_number()<cr>

" iS {{{3

" `vim-sandwich` installs the following mappings:
"
"     x  is  <plug>(textobj-sandwich-query-i)
"     x  as  <plug>(textobj-sandwich-query-a)
"     o  is  <plug>(textobj-sandwich-query-i)
"     o  as  <plug>(textobj-sandwich-query-a)
"
" They  shadow  the  built-in  sentences  objects. But I  use  the  latter  less
" frequently than  the sandwich objects. So,  I won't remove  the mappings. But,
" instead, to restore the sentences objects, we install these mappings:

ono iS is
ono aS as

xno iS is
xno aS as
" }}}2
" Select {{{2

" DWIM:
" move to left/right in select mode (useful for UltiSnips)
snor <c-b> <esc>i<left>
snor <c-f> <esc>i<right>

" After expanding a snippet, I want to be able to delete the character after
" the cursor with C-d like in insert mode.
snor <c-d> <esc>i<del>

" Visual {{{2
" C-s {{{3

" Search inside visual selection
" What difference with :*ilist! foobar ?
" `:ilist`:
"
"    - searches in all included files. :g only in current buffer.
"    - can ignore comment if we don't put a bang
"    - automatically adds \<,\> around the pattern, if we don't surround it with slashes

xno <c-s> <esc>:keepj keepp *g/\%V/#<left><left>

" /           search only in visual selection {{{3

" Do not try to install an `<expr>` mapping which would return the keys.{{{
"
" Before the  function checks the  position of the  visual marks, you  must have
" quit the visual mode so that they  have been updated.
" But you can't do that if the function is called while the text is locked.
"}}}
xno <silent> / :<c-u>call <sid>visual_slash()<cr>
fu s:visual_slash() abort
    if line("'<") == line("'>")
        call feedkeys('gv/', 'in')
    else
        " Do not reselect the visual selection with `gv`.{{{
        "
        " It would make move the end of the selection.
        " That's not what we want.
        " We want to search in the last visual selection.
        "}}}
        call feedkeys('/\%V', 'in')
    endif
endfu

" .    @ {{{3

" Repeat last edit on all the visually selected lines with dot
xno <silent> . :norm! .<cr>
"                   ^
" Warning: The bang may prevent the repetition of pseudo-operators such as `ys` provided by `vim-surround`.{{{
"
" I think that's because `vim-surround` doesn't implement real operators.
" It emulates them.
" `vim-sandwich` doesn't suffer from this issue.
"}}}

" Purpose:{{{
"
" Repeat last macro on all the visually selected lines with `@{reg}`.
"}}}
" Why not `xno  @  :norm @<c-r>=nr2char(getchar())<cr><cr>`?{{{
"
" The  last carriage  return which  executes the  command (norm  @q^M) is  moved
" before the register name (`norm @^Mq`).
"
" The reason is  probably because `getchar()` consumes  the remaining characters
" from the mapping.
" At the end of the mapping, there's a CR.
" When `getchar()` is called, it consumes it, instead of just waiting for our input.
" The solution would be to use  `inputsave()` / `inputrestore()`, but that would
" make the mapping uselessly complex.
"}}}
xno <silent> @ :<c-u>exe "'<,'>norm @"..nr2char(getchar())<cr>
"                                 │
"                                   └ Do NOT add a bang:{{{
"
" We want the recursiveness, for one of our mapping to be used.
" It temporarily disables some keysyms which may break the replay of a macro.
"}}}

" A  I  gI    niceblock {{{3

" https://github.com/kana/vim-niceblock/blob/master/doc/niceblock.txt
"
" v_b_I = Visual-block Insert
" v_b_A = Visual-block Append
"
"    - Make |v_b_I| and |v_b_A| available in all kinds of Visual mode.
"    - Adjust the selected area to be intuitive before doing blockwise insertion.

" Why appending `h` for the `$` motion in characterwise and blockwise visual mode?{{{
"
" In characterwise visual mode, `$` selects the trailing newline.
" We don't want that; `h` makes sure we leave it alone.
"
" ---
"
" In blockwise visual mode,  if you set `'ve'` with the  value `block` (which we
" do by default), then something unexpected happens.
"
" MWE:
"
"     abc
"     def
"     ghi
"
" Position the cursor on `a` and press `C-vjj$`, then yank or delete the block.
" Paste it below by running `:pu` (or pressing our custom `]p`):
" a trailing space is added on every pasted line.
"
" What's weird,  is that the  contents and type of  the unnamed register  is not
" affected by our custom `'ve'`.
" You only see a difference when you paste.
"
" Anyway, I don't like that trailing space.
" That's not how  Vim behave without config;  so this makes it  harder to follow
" instructions found on forums.
" Besides, a trailing space is useless.
"}}}
let s:niceblock_keys = {
    \   '$'  : {'v': 'g$h',      'V': '$',          "\<c-v>": '$h'},
    \   'I'  : {'v': "\<c-v>I",  'V': "\<c-v>^o^I", "\<c-v>": 'I'},
    \   'A'  : {'v': "\<c-v>A",  'V': "\<c-v>0o$A", "\<c-v>": 'A'},
    \   'gI' : {'v': "\<c-v>0I", 'V': "\<c-v>0o$I", "\<c-v>": '0I'},
    \   '>'  : {'v': "\<c-v>>",  'V': "0\<c-v>>",   "\<c-v>": '>'},
    \   '<'  : {'v': "\<c-v><",  'V': "0\<c-v><",   "\<c-v>": '<'},
    \ }

fu s:niceblock(key) abort
    return s:niceblock_keys[a:key][mode()]
endfu


" The purpose of this mapping is to not include a newline when selecting
" a characterwise text until the end of the line.
xno <expr> $ <sid>niceblock('$')

xno <expr> I  <sid>niceblock('I')
xno <expr> gI <sid>niceblock('gI')
xno <expr> A  <sid>niceblock('A')

" Why these assignments:
"
"     niceblock_keys['>']['V'] = "0\<c-v>>"
"     niceblock_keys['<']['V'] = "0\<c-v><"
"
" ... and not simply:
"
"     niceblock_keys['>']['V'] = ">"
"     niceblock_keys['<']['V'] = "<"
"
" ? Because, without "\<c-v>", sometimes the alignment is lost.

xno <expr> > <sid>niceblock('>')
xno <expr> < <sid>niceblock('<')

" d y         preserve last deleted/yanked visual selected text through registers {{{3

" When we delete sth in visual mode to  move it somewhere else, if we delete sth
" else before  pasting it, we  lose it  (well technically it's  still accessible
" from a numbered register, but if we  delete several things, we have to execute
" `:reg` to see where it is now).

" With this  mapping, we can  always access the last  text we deleted  in visual
" mode, from the `v` register.
xno <expr><silent> d 'd'..timer_start(0, {-> setreg('v', getreg('"'), getregtype('"'))})[-1]

" same thing when we yank
xno <expr><silent> y 'y'..timer_start(0, {-> setreg('v', getreg('"'), getregtype('"'))})[-1]

" h l         disable at the beginning/end of line in visual block mode {{{3

xno <expr> h mode() is# '<c-v>' && virtcol('.') == 1            ? '' : 'h'
xno <expr> l mode() is# '<c-v>' && virtcol('.') == &columns - 2 ? '' : 'l'

" ip          disable on empty line {{{3

" sometimes I hit `vip` by accident on an empty line
" annoying, because it can make me lose previous visual selection
" (you can cycle through the last 2 visual selections with `gv`)

nno <expr><silent> vip getline('.') =~# '^\s*$' ? '' : 'vip'

" mJ  m C-j   join blocks {{{3

" Difference compared to :JoinBlocks?:
"
"   - easier to use;  no need to position the cursor on
"                     the first line of the 2nd block
"                     no need to provide the nr of lines in a block
"                     as an argument
"
"   - not repeatable; each time we call it, we must first visually select
"                     the lines (or provide an arbitrary range)
"                     :JoinBlocks can be repeated simply by typing @:


" How does `join_blocks()` work?
" It mainly executes 3 commands:
"
"   - insert a literal ^A in front of all the lines in the 2nd block
"   - join the 2 blocks
"   - align the blocks using ^A as a delimiter

xno <silent> mJ     :<c-u>call myfuncs#join_blocks(0)<cr>
xno <silent> m<c-j> :<c-u>call myfuncs#join_blocks(1)<cr>
"                                                  │
"                                                  └ first, reverse the order of the blocks
"                                                    then, join them

" mq          populate qfl with lines in the selection {{{3

xno <silent> mq :<c-u>exe line("'<")..','..line("'>")..'cgetbuffer' <bar> cw<cr>

" P           paste without yanking selection in unnamed register {{{3

" If you want the original behavior, press `p` instead.
" By default, `x_p` and `x_P` do the same thing.
" Why don't you remap `p` instead of `P`?{{{
"
" If you do that, when you'll try  to reselect the text you've pasted with `gv`,
" you'll get an unexpected result.
" I'm ok with an unexpected result when pressing `P`, but not when pressing `p`.
"}}}
xno <expr> P '"_d"'..v:register..'P'
" }}}1
" Commands {{{1
" Warning: Here, do NOT create commands which are only relevant for a specific type of buffer. {{{2
"
" Those should be defined in a filetype plugin with the `-buffer` attribute.
" }}}2

" Cfg {{{2

com! -bar -complete=custom,s:cfg_complete -nargs=1 Cfg call s:cfg(<q-args>)

fu s:cfg_complete(_a, _l, _p) abort
    return join(sort(keys(s:PGM2CFGFILES)), "\n")
endfu

fu s:cfg(pgm) abort
    if has_key(s:PGM2CFGFILES, a:pgm)
        let files = s:PGM2CFGFILES[a:pgm]
    else
        echohl ErrorMsg
        echo a:pgm..' is not supported'
        echohl NONE
        return
    endif
    call filter(files, {_,v -> filereadable(expand(v))})
    if empty(files) | echo 'no readable file' | endif
    for file in files
        exe 'sp '..file
    endfor
endfu

let s:PGM2CFGFILES = {
\ 'autostart':     ['~/bin/autostartrc'],
\ 'bash':          ['~/.bashrc', '~/.bashenv', '~/.bash_profile'],
\ 'conky':         ['~/.config/conky/system.lua', '~/.config/conky/system_rings.lua', '~/.config/conky/time.lua'],
\ 'fasd':          ['~/.fasdrc'],
\ 'fd':            ['~/.fdignore'],
\ 'firefox':       glob('~/.mozilla/firefox/*.default/chrome/userContent.css', 0, 1),
\ 'git':           ['~/.config/git/config', '~/.cvsignore'],
\ 'htop':          ['~/.config/htop/htoprc'],
\ 'intersubs':     ['~/.config/mpv/scripts/interSubs.lua', '~/.config/mpv/scripts/interSubs.py', '~/.config/mpv/scripts/interSubs_config.py'],
\ 'keyboard':      glob('~/.config/keyboard/*', 0, 1),
\ 'kitty':         ['~/.config/kitty/kitty.conf'],
\ 'latexmk':       ['~/.config/latexmk/latexmkrc'],
\ 'less':          ['~/.config/lesskey'],
\ 'mpv':           ['~/.config/mpv/input.conf', '~/.config/mpv/mpv.conf'],
\ 'newsboat':      ['~/.config/newsboat/config', '~/.config/newsboat/urls'],
\ 'ranger':        ['~/.config/ranger/rc.conf'],
\ 'readline':      ['~/.inputrc'],
\ 'surfraw':       ['~/.config/surfraw/bookmarks', '~/.config/surfraw/conf'],
\ 'tmux':          ['~/.config/tmux/tmux.conf'],
\ 'vim':           [$MYVIMRC],
\ 'w3m':           ['~/.w3m/config'],
\ 'weechat':       ['~/.config/weechat/script/rc.conf'],
\ 'xbindkeys':     ['~/.config/keyboard/xbindkeys.conf'],
\ 'xfce_terminal': ['~/.config/xfce4/terminal/terminalrc'],
\ 'zathura':       ['~/.config/zathura/zathurarc'],
\ 'zsh':           ['~/.zshrc', '~/.zshenv'],
\ 'zsh_snippets':  glob('~/.config/zsh-snippets/*.txt', 0, 1),
\ }

" CGrep / LGrep {{{2

" Grep for a pattern below the cwd.

" Usage: `:CGrep 'pat' file ...` (like `grep(1)`).

" I have an improvement idea!  I just need to tweak the definitions of the commands...{{{
"
" Ok, but remember:
"
"    1. The new synopsis should be identical to the one of `grep(1)`.
"
"       I.e.:
"       It should allow us to pass a quoted pattern, or an unquoted one.
"       It should allow us to pass the files/directories which we want to grep.
"
"    2. If you hesitate between several implementations, have a look at how Tpope
"       implemented `:CFind` in `vim-eunuch`.
"}}}
" How to search for a pattern containing a single quote?{{{
"
" Like with `grep(1)`.
" For example, if you want to grep `a'b"c`, run:
"
"     :CGrep 'a'\''b"c'
"}}}
com! -nargs=1 CGrep call myfuncs#op_grep('Ex', <q-args>, 0)
com! -nargs=1 LGrep call myfuncs#op_grep('Ex', <q-args>, 1)

" CheckHealth {{{2

if has('nvim')
    com! -bar CheckHealth checkhealth
endif

" CombineParamValues {{{2

" Purpose:{{{
"
" Here is a situation which we frequently encounter:
"
" We find some issue which can be influenced by several parameters.
" To  get a  better  understanding, we  want  to  make a  test  in all  possible
" environments (i.e. for all combinations of parameters values).
"
" Getting all those combinations can be time-consuming, and tedious.
" We need a command to automate the task.
"}}}
" Usage:{{{
"
" Write all the possible values of each parameter on a dedicated line, separated
" by whitespace.  Then run the command against this range of lines.
"
" As an example, executing the command on these lines:
"
"     a
"     b c
"
" will replace them with:
"
"     a b
"     a c
"
" And these lines:
"
"     a
"     b c
"     d e f
"
" would be replaced with:
"
"     a b d
"     a b e
"     a b f
"     a c d
"     a c e
"     a c f
"}}}
com! -bar -range=% CombineParamValues call s:combine_param_values(<line1>, <line2>)

fu s:combine_param_values(lnum1, lnum2) abort
    let param_values = map(filter(getline(a:lnum1, a:lnum2), {_,v -> v != ''}), {_,v -> split(v)})
    if len(param_values) < 2 | return | endif
    let reg_save = [getreg('"'), getregtype('"')]
    let @" = join(s:combine(param_values), "\n")
    exe 'norm! '..a:lnum1..'GV'..a:lnum2..'G""p'
    call setreg('"', reg_save[0], reg_save[1])
    sil exe '''<,''>EasyAlign *\ '
endfu

fu s:combine(param_values) abort
    if len(a:param_values) == 2
        let res = []
        for i in a:param_values[0]
            for j in a:param_values[1]
                let res += [i..' '..j]
            endfor
        endfor
    else
        let res = s:combine([s:combine(a:param_values[:-2]), a:param_values[-1]])
    endif
    return res
endfu

" DiffLines {{{2

com! -bar -bang -range -nargs=? DiffLines call myfuncs#diff_lines(<bang>0, <line1>, <line2>, <q-args>)

" DiffOrig {{{2

" See differences between current buffer and original file.
com! -bar DiffOrig echo s:diff_orig()

fu s:diff_orig() abort
    call save#toggle_auto(0)
    let cole_save = &l:conceallevel
    setl conceallevel=0

    let tempfile = tempname()..'/Original File'
    exe 'vnew '..tempfile
    setl buftype=nofile nobuflisted noswapfile nowrap

    sil 0r #
    $d_
    setl nomodifiable readonly

    diffthis
    nno <buffer><expr><nowait><silent> q reg_recording() isnot# '' ? 'q' : ':<c-u>q<cr>'
    let &filetype = getbufvar('#', '&ft')

    let s:tmp_partial = function('s:diff_orig_restore_settings', [cole_save])
    augroup diff_orig_restore_settings
        au! * <buffer>
        au BufWipeOut <buffer> call save#toggle_auto(1)
            \ |                call timer_start(0, s:tmp_partial)
    augroup END

    exe winnr('#')..'windo diffthis'
    return ''
endfu

fu s:diff_orig_restore_settings(conceallevel,_) abort
    exe 'setl conceallevel='..a:conceallevel
    diffoff!
    norm! zvzz
    aug! diff_orig_restore_settings
    unlet s:tmp_partial
endfu

" DumpWiki {{{2
" Usage:
"     :DumpWiki https://github.com/oniony/TMSU/

com! -bar -nargs=1 DumpWiki call myfuncs#dump_wiki(<q-args>)

" FormatManpage {{{2

com! -bar -range=%  FormatManpage  call s:format_manpage(<line1>, <line2>)

fu s:format_manpage(line1, line2) abort
    let range = a:line1..','..a:line2
    " create folds
    exe 'sil keepj keepp '..range..'s/^\u\+/# &/e'
    " titlecase headers
    exe 'sil keepj keepp '..range..'s/\%(^#.*\)\@<=\(\u\)\(\u\+\)/\1\L\2/ge'
    " make sure there's an empty line between a header and the next non-empty line
    exe range..'g/^#.*\n.*\S/call append(".", "")'
endfu

" GotoChar {{{2

com! -bar -nargs=1 GotoChar call search('\m\%^\_.\{<args>}', 'es')

" GrepCfg {{{2

" Description:{{{
"
" Search for a pattern inside all our configuration files.
"
" ---
"
" The basic idea is to get the list of all files in our config repo with:
"
"     # https://stackoverflow.com/a/8533413/9780968
"     $ config ls-tree --full-tree --name-only HEAD -r >/tmp/listing
"
" Make the paths absolute:
"
"     $ sed -i "s:^:$HOME/:" /tmp/listing
"
" Then feed them to `:vimgrep`.
"
" ---
"
" We need `sed(1)`,  because the paths output by `$ git  ls-tree` are relative to
" the root of the repo, which here is our home.
" But if we're not  in our home, the relative paths  will be interpreted wrongly
" by `$ vim -q`.
"
" ---
"
" You could also feed the file names to `grep(1)` via `xargs(1)`:
"
"     $ vim -q <(config ls-tree --full-tree -r --name-only HEAD | sed "s:^:$HOME/:" | xargs grep -HIins pattern) +cw
"
" But grep's regex engine is not as powerful as Vim.
"
" And it can't give you the column position.
" You can get the byte-offset from the  start of the file with `-ob`, but that's
" not the byte-offset from the start of the line.
"}}}
" Usage:{{{
"
"     :GrepCfg \<sed\>
"}}}
com! -nargs=1 GrepCfg call s:grep_cfg(<q-args>)

fu s:grep_cfg(pat) abort
    let files =<< trim END
        git
            --git-dir="${HOME}/.cfg/"
            --work-tree="${HOME}"
        ls-tree
            --full-tree
            --name-only HEAD
        -r
        | sed "s:^:${HOME}/:; \%.vim/tools/mthesaur.txt%d"
    END
    let files = systemlist(join(files))
    call filter(files, 'filereadable(v:val)')
    try
        exe 'vim /'..escape(a:pat, '/')..'/gj '..join(files)
    catch /^Vim\%((\a\+)\)\=:E480:/
        echohl ErrorMsg
        echom v:exception
        echohl NONE
        return
    endtry
    call setqflist([], 'a', {'title': ':GrepCfg '..a:pat})
endfu

" H {{{2

" Commented for the moment, because it's getting annoying.
" The original  purpose was  to make  `:h` create  a new  split window,  even if
" there's already a help window in the tabpage.

"     com -bar -complete=help -nargs=* H call s:help(<q-args>, <q-mods>)
"     cnorea <expr> h getcmdtype() is# ':' && getcmdpos() == 1 ? 'h' : 'H'
"     fu s:help(topic, mods) abort
"         try
"             if a:mods is# 'tab'
"                 exe 'tab h ' . a:topic
"                 return
"             endif
"             let is_valid_topic = !empty(getcompletion(a:topic, 'help'))
"             " We don't want  the layout to be changed (split,  new tabpage), if `:h`
"             " is going to fail; in this case,  we just want the error message, which
"             " will be properly handled by the catch clause.
"             if !is_valid_topic
"                 exe 'h ' . a:topic
"             endif
"             let no_help_window = index(map(tabpagebuflist(), {_,v -> getbufvar(v, '&ft')}), 'help') == -1
"             if no_help_window
"                 exe 'h ' . a:topic
"             else
"                 exe 'sp | h ' . a:topic
"             endif
"         catch
"             return lg#catch()
"         endtry
"     endfu

" HlWeirdWhitespace {{{2

" Why don't you use an autocmd instead?{{{
"
" So, you're thinking about sth like this:
"
"     augroup strange_whitespace
"         au!
"         au WinEnter * call s:strange_whitespace()
"     augroup END
"
" Ok, but I wouldn't be able to disable the highlight in a 'fex' buffer.
"
" The  same issue  would probably  apply to  other types  of buffers  (like help
" buffers), where I don't want this highlighting.
"
" The issue comes from the fact that when `WinEnter` is fired after a split, the
" current buffer is still the one displayed  in the original window, not the one
" which is going to be loaded.
" So this guard wouldn't work:
"
"     let bufnr = winbufnr(winnr())
"     if getbufvar(bufnr, '&ft', '') is# 'fex'
"         return
"     endif
"
" MWE:
"
"     :LogEvents! WinEnter
"     :sp /tmp/file
"     12:34  WinEnter  /home/user/.vim/vimrc~
"                      ^^^^^^^^^^^^^^^^^^^^^
"                      ✘ we would need `/tmp/file`, but the latter has not yet been loaded~
"}}}
com! -bar -range=% HlWeirdWhitespace call s:hl_weird_whitespace()

fu s:hl_weird_whitespace() abort
    if !exists('w:strange_whitespace')
        " https://vi.stackexchange.com/a/17697/17449
        let pat = '[\x0b\x0c\u00a0\u1680\u180e\u2000-\u200a\u2028\u202f\u205f\u3000\ufeff]'
        "                                     ├───────────┘
        "                                     └ yes, one can write an arbitrary range of unicode characters
        let w:strange_whitespace = matchadd('ErrorMsg', pat)
    else
        call matchdelete(w:strange_whitespace)
        unlet! w:strange_whitespace
    endif
endfu

" InANotInB {{{2

" This command outputs the lines which are in buffer A but not in buffer B.

" Why `<f-args>`?{{{
"
" A filename can contain whitespace.
"}}}
com! -bar -nargs=+ -complete=buffer InAButNotInB call myfuncs#in_A_not_in_B(<f-args>)

" IsPrime {{{2

com! -bar -nargs=1 IsPrime echo lg#math#is_prime(<args>)

" JoinBlocks {{{2

" The following command joins 2 blocks of lines.
" To use it, you must:
"
"    - remove possible empty lines between the blocks
"    - be on the 1st line of the 1st block
"    - provide the nr of lines of a block as an argument to the command
"
" After an initial join, you can repeat it with @:

" How it works?{{{
"
" If the blocks are 5 lines long, the command will execute:
"
"     ┌ for each line of the first block (.,.+4g/^/)
"     ├───────┐
"     .,.+4g/^/''+5m.|-j
"              ├────┘ ├┘
"              │      └ then join the two lines
"              │
"              └ move the first line of the second block (''+5) under the current one (m.)


" We can notice that the address of the 1st line of the 1st block is expressed
" in 2 different ways, depending on the context.
" Inside the range passed to `:g` it's `.` (current line when `:g` starts).
" Inside the command executed by `:g`, it can't be `.` anymore (because the
" current line changes constantly), so here we use `''` instead.
" Indeed, before jumping to the first line to process, `:g` adds an entry in the
" jumplist, whose mark is `''`. So:
"
"         we're on the 1st line of the 1st block
"     and ''    is a line specifier for the latter
"     and a block has 5 lines
"
"     ⇒
"
"     ''+5    is a line specifier for the 1st line of the second block
"
" This shows that the range passed to `:g` is entirely processed BEFORE
" the command (here `:m`) it executes.
" Remember:
" `.` doesn't stand for the same line inside a range passed to `:g`, and inside
" a range passed to a command executed by the same `:g`.
" Also, if `:Ex`  is a command executed by `:g`  (`:g/pat/Ex`), inside `:Ex` you
" can use `''` to refer to the initial line from which `:g` was started.


" `:g` will cycle through the lines of the 1st block, and always move + join
" the SAME line:
"
"         the 1st of the 2nd block
"
" But, the contents of this line will constantly change. It will be successively:
"
"    - the 1st of the 2nd block
"    - the 2nd one (after the 1st has been joined)
"    - the 3rd one ("         2nd ")
"    - the 4th one ("         3rd ")
"    - the 5th one ("         4rd ")
"
" Why `-j`, and not simply `j` ?
" Because, when `:m` moves a line, the cursor doesn't stay where it is; it jumps
" onto the moved line.
" So, before joining the lines, we have to get back on the original line above
" (`-` = `.-1`).
"}}}

" This command isn't really needed (we have `v_mj`), but I keep it for educational
" purpose.

com! -bar -bang -nargs=1 JoinBlocks
    \ | let &l:fen = 0
    \ | exe "keepp .,.+<args>-1g/^/''+<args>m.|-j<bang>"
    \ | let &l:fen = 1

" OnlySelection {{{2

" This command deletes everything except the current visual selection (or any
" arbitrary range).
"
" Usage:
"
"     :'<,'>OnlySelection
"     :12,34OnlySelection

com! -bar -range=% OnlySelection call myfuncs#only_selection(<line1>,<line2>)

" PluginsToCommit {{{2

com! -bar -nargs=0 PluginsToCommit  call s:plugins_to_commit()

fu s:plugins_to_commit() abort
    let script = 'commit-these-vim-plugins'
    if !executable(script)
        echom '[PluginsToCommit]: '..script..' is not available'
        return
    endif

    let my_plugins = readfile($MYVIMRC)
    call filter(my_plugins, {_,v -> v =~# '^\s*Plug\s\+''lacygoill/'})
    call map(my_plugins, {_,v -> matchstr(v, 'lacygoill/\zs.\{-}\ze''')})
    let my_plugins = join(my_plugins)
    sil let output = systemlist('commit-these-vim-plugins '..my_plugins)
    " we may have removed a plugin, but not executed `:Plugclean` yet
    call filter(output, {_,v -> v !~# 'No such file or directory'})
    if output ==# []
        echom '[PluginsToCommit]: nothing to commit'
        return
    endif

    call filter(output, {_,v -> v =~# '^\S'})
    call map(output, {_,v -> glob($HOME..'/.vim/plugged/'..v..'/*', 0, 1)[0]})
    call map(output, {_,v -> {'filename': v, 'valid': 1}})
    call setqflist([], ' ', {'items': output, 'title': 'Plugins to commit'})
    cw
endfu

" PluginGlobalVariables {{{2

com! -bar -nargs=? PluginGlobalVariables call myfuncs#plugin_global_variables(<q-args>)

" PC    Plugin Clean {{{2

com! -bar PC call s:plug_clean()

fu s:plug_clean() abort
    sil! PlugClean
    " Why do you run this?{{{
    "
    " From `:h UpdateRemotePlugins`:
    "
    " > You must  execute |:UpdateRemotePlugins| every  time a remote  plugin is
    " > installed, updated, or deleted.
    "}}}
    " What kind of issue could I encounter if I don't run `:UpdateRemotePlugins`?{{{
    "
    " Install this plugin: https://github.com/numirias/semshi
    " Remove it with `:PlugClean`.
    " Now, run this:
    "
    "     $ nvim -Nu NORC /tmp/py.py
    "     Error detected while processing function remote#define#request:~
    "     line    2:~
    "     no request handler registered for "~/.vim/plugged/semshi/rplugin/python3/semshi:autocmd:BufEnter:*.py"~
    "
    " The error comes from:
    "
    "     /usr/local/share/nvim/runtime/autoload/remote/define.vim:196
    "
    " To understand, run this:
    "
    "     $ nvim -V15/tmp/log -Nu NORC /tmp/py.py
    "     /semshi
    "}}}
    "   In the previous log, I can see that Nvim sources a file outside the rtp.  Why?{{{
    "
    " After reading the log, you may have found that Nvim sources
    " `~/.local/share/nvim/rplugin.vim` –  the remote plugin manifest  – and you
    " may wonder why, since its parent directory is not in Nvim's rtp.
    "
    " I  think that's  just how  Nvim works  by default;  it sources  the remote
    " plugin manifest, *in addition to* plugins in directories of the rtp.
    " For more info, see: `:h $NVIM_RPLUGIN_MANIFEST`.
    "}}}
    if has('nvim')
        UpdateRemotePlugins
    endif
endfu

" PI    Plugin Install {{{2

com! -bar -nargs=1 PI call myfuncs#plugin_install(<q-args>)

" PUP    update (N)Vim plugins {{{2

" Don't name the command `:PU`; it could shadow the default `:pu[t]`.
com! -bar PUP call s:plugins_update()

fu s:plugins_update() abort
    " :h spellfile-cleanup
    runtime spell/cleanadd.vim

    " Install `wfrench` package. Useful for dictionary completion.
    if system('aptitude show wfrench | grep "^State"')[:-2] =~? 'state:\s*not\s\+installed'
        echom 'Need to install the wfrench package for the french dictionary.'
        let password = inputsecret('Enter sudo password:').."\n"
        sil let out = system('sudo -S aptitude install wfrench', password)
        echo out
    endif

    if !isdirectory($HOME..'/.vim/tmp/snapshot')
        call mkdir($HOME..'/.vim/tmp/snapshot', 'p', 0700)
    endif
    "                                                                          ┌ put the month before the day
    "                                                                          │ so that, in the output of `ls(1)`,
    "                                                                          │ the files are listed chronologically
    "                                                                          │
    exe 'PlugSnapshot! '..fnameescape($HOME..'/.vim/tmp/snapshot/'..strftime('%m-%d__%H-%M')..'.vim')
    "                                                                                  │
    "                                       don't put a colon, it could be problematic ┘
    " Why a colon is a bad idea in a filename?{{{
    "
    " 1. It's not inside  the default value of 'isf'. Which means  that Vim
    "   doesn't consider this character  to be a part  of a filename when
    "   using  `\f` in a pattern.
    "
    " 2. In most buffers, the local value of 'efm' probably uses the `%f` item
    "   to match a filename. Here's what `:h error-file-format` says about
    "   the latter:
    "
    "     > The "%f" conversion may depend on the current 'isfname' setting.
    "
    "     So, if you try  to parse the output of a shell command,  or to read an
    "   error file/buffer  to populate  the qfl,  Vim will  fail to  recognize a
    "   filename containing a colon. You'll get non-valid entries.
    "
    " 3. It's interpreted as a separator  in $PATH, so it can be dangerous if
    "   used in a directory.  And if we avoid the colon in a directory name,
    "   to stay consistent we should do the same in a filename.
    "
    " 4. It has a special meaning in  Windows, so if the file is copied on
    "   a different OS, it can cause an issue.
    "}}}
    " Which character are safe to use in a filename?{{{
    "
    "     [a-z]
    "     [A-Z]
    "     [0-9]
    "     .
    "     - (but not at the very beginning)
    "     _
    "
    " https://stackoverflow.com/a/458001/8243465
    " https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_282
    "}}}

    " wipe the Vim buffer containing the snapshot
    if getline(1) is# '" Generated by vim-plug'
        bw
    endif
    PlugUpgrade
    PlugUpdate
    if has('nvim')
        UpdateRemotePlugins
    endif
endfu

" RemoveDuplicateLines {{{2

" Explanation:{{{
"
" Each  time awk  iterates over  a  new line,  it creates  an associative  array
" element with the entire line as the index and with the default value 0.
" The `!` operator negates 0, and the  final value is 1 (i.e. true); without any
" action, awk performs `{ print $0 }`, and the entire line gets printed.
"
" Then, the `++` operator is processed and  1 is added to the array value, which
" now becomes 1; this way, the next time the same line is encountered, the value
" returned by the array will be 1, which will  then be negated to 0 by `!`; as a
" result, the  default action won't be  executed (i.e. the duplicate  line won't
" get printed).
"
" See also: https://www.gnu.org/software/gawk/manual/html_node/History-Sorting.html#History-Sorting
"}}}
com! -bar -range=% RemoveDuplicateLines sil <line1>,<line2>!awk '\!x[$0]++'
"                                                                │{{{
"                                                                └ `:h :!`:
" `!` is replaced with the previous external command
" But not when there is a backslash before the '!', then that backslash is removed.
"}}}

" RemoveSwapFiles {{{2

com! -bar RemoveSwapFiles call map(glob($HOME..'/.vim/tmp/swap/*', 1, 1), {_,v -> delete(v)})

" RemoveTabs {{{2

" The purpose of this command is to replace all tab characters in the buffer
" with a nr of spaces which will occupy the same nr of cells.
"
" Before using it, set 'ts' (2,4,8) so that the text is aligned.
com! -bar -range=% RemoveTabs call myfuncs#remove_tabs(<line1>,<line2>)

" Retab {{{2

" The system :retab command substitutes all the tabs from a file to spaces.
" We don't want that. We want a command which substitutes only leading tabs.
"
" Besides, :retab automatically chooses which substitution to do based on the
" value of &expandtab:    &et ? spaces → tabs : tabs → spaces
" We prefer to manually decide the type of substitution.
"
" So, we define the custom command :Retab which accepts a bang.
" :Retab  = tabs   → spaces
" :Retab! = spaces → tabs
" Mnemonic: we use spaces as the default way to indent, so it makes sense to
" to use a bang only for the less useful conversion: spaces → tabs

com! -bar -bang -range=% Retab call s:retab(<line1>,<line2>, <bang>0)

fu s:retab(line1, line2, bang) abort
    let view = winsaveview()
    let range = a:line1..','..a:line2
    if !a:bang
        exe 'sil keepj keepp '..range..'s:^\t\+:\=repeat(" ", &ts * len(submatch(0))):e'
    else
        exe 'sil keepj keepp '..range..'s:^\( \{'..&ts..'}\)\+:\=repeat("\t", len(submatch(0))/&ts):e'
    endif
    call winrestview(view)
endfu

" ReverseEveryNLines {{{2

com! -bar -range=% -nargs=1 ReverseEveryNLines call s:reverse_every_n_lines(<args>, <line1>, <line2>)

fu s:reverse_every_n_lines(n, line1, line2) abort
    let mods = 'keepj keepp lockm'
    let range = a:line1..','..a:line2
    let l:Address = {-> (line('.')- a:line1 + 1) % a:n ? ( line('.') - a:line1 + 1 ) % a:n : a:n}
    sil exe mods..' '..range..'g/^/exe "m .-".l:Address()'
endfu

" ShowLongLines {{{2

" This command highlights in red the character after a given column.
" Repeat the command toggles the highlighting.

com! -bar -nargs=? ShowLongLines echo s:shll(<args>)

fu s:shll(...) abort
    if !exists('w:shll')
        let w:shll = matchadd('Error', '\%'..((a:0 ? a:1 : 80)+1)..'v', 20)
    else
        call matchdelete(w:shll)
        unlet w:shll
        if a:0
        " we've executed 2 `:ShowLongLines` commands, probably with different arguments
        " we've just get rid of the old match of the previous command,
        " now we need to create a new one for the 2nd command
            call s:shll(a:1)
        endif
    endif
    return ''
endfu

" SortLines {{{2

" Commented for the moment. Keep it for educational purpose.

" " We define the :SortLines command which moves lines containing foo or bar at
" " the bottom. Lines containing foo are put before the ones containing bar.
"
"     com -bar -range=%  SortLines  call s:sort_lines(<line1>, <line2>)
"
"     fu s:compare_lines(l1, l2) abort
"         " The greater the score, the further to the right in the sorted list
"         let score1 = a:l1=~ 'bar' ? 2 : a:l1 =~ 'foo'
"         let score2 = a:l2=~ 'bar' ? 2 : a:l2 =~ 'foo'
"         return score1 - score2
"     endfu
"
"     fu s:sort_lines(line1, line2) abort
"         let sorted_lines = sort(getline(a:line1, a:line2), 's:compare_lines')
"         let c = 0
"         for line in sorted_lines
"             call setline(a:firstline + c, line)
"             let c+=1
"         endfor
"     endfu

" SumColumn {{{2

com! -bar -range SumColumn sil! keepj keepp <line1>,<line2>g/=\s*$/ t. | s/// | exe '.!bc' | -j

" Tldr {{{2

com! -bar -complete=custom,s:tldr_completion -nargs=1 Tldr call s:tldr(<q-args>)
fu s:tldr_completion(_a, _l, _p) abort
    sil return system('tldr --list 2>/dev/null | tr -s "[ \t]" "\n"')
endfu

fu s:tldr(shellcmd) abort
    sil let out = systemlist('tldr '..a:shellcmd)
    if get(out, 0, '') =~# '^tldr page.*not found$'
        echo out[0]
        return
    endif
    call map(out, {_,v -> substitute(v, '\e.\{-}m\|\%x0f', '', 'g')})
    call map(out, {_,v -> substitute(v, '^-', '#', '')})
    call map(out, {_,v -> substitute(v, '^  ', '    ', '')})
    sp /tmp/.tldr.md
    %d_
    call setline(1, out)
    keepj keepp g/^#/call append('.', '')
    update
    norm! gg
    nno <buffer><expr><nowait><silent> q reg_recording() isnot# '' ? 'q' : ':<c-u>q<cr>'
endfu

" TW {{{2

com! -bar -range=% TW call s:trim_whitespace(<line1>,<line2>)
fu s:trim_whitespace(line1,line2) abort
    let view = winsaveview()
    sil exe 'keepj keepp '..a:line1..','..a:line2..'s/\s\+$//e'
    call winrestview(view)
endfu

" WebPageRead {{{2

" this command opens a new tab page, loads a temporary buffer, and dumps
" the contents of a webpage inside the latter
com! -bar -nargs=1 WebPageRead call myfuncs#webpage_read(<q-args>)

" WordFrequency {{{2

" Display words in the current buffer sorted by frequency

com! -bar -nargs=? -range=% -complete=custom,myfuncs#wf_complete
    \ WordFrequency
    \ call myfuncs#word_frequency(<line1>,<line2>, <q-args>)
" }}}1
" Autocmds {{{1
" Warning: If you need to write an autocmd listening to `BufWritePost`, put it *before* the one sourcing our vimrc.{{{
"
" Otherwise, if the pattern is `$MYVIMRC`,  it won't work, probably because when
" the vimrc is re-sourced, the augroup it cleared.
" Yes, the autocmd is re-installed, but it's  a new one, which won't take effect
" immediately for the current `BufWritePost` event.
" It will be executed only for the next `BufWritePost`.
" At that point, the issue will repeat.
"
" MWE:
"
"     $ cat /tmp/vim.vim
"         augroup test_sth
"             au!
"             au BufWritePost /tmp/vim.vim so %
"             au BufWritePost *            let g:d_ebug = get(g:, 'd_ebug', 0) + 1
"         augroup END
"
"     $ vim -Nu /tmp/vim.vim /tmp/vim.vim
"     :w
"     :echo d_ebug
"     ✘ E121~
"
" The issue disappears if you change the order of the autocmds.
"}}}

" Command Window {{{2

" Form more ideas:
" http://vim.wikia.com/wiki/Enhanced_command_window

augroup my_cmdline_window
    au!
    " Purpose:{{{
    "
    " By default, `Tab` is mapped to `C-x C-v` in the command-line window.
    " This shadows our custom `Tab` mapping which can expand a snippet.
    "
    " This  local mapping  is not  installed in  the search  command-line window
    " (`q/`, `q?`), which is why we use the pattern `:` instead of `*`.
    "
    " Note that  for some  reason, UltiSnips  fails to expand  a snippet  in the
    " search command-line window.
    "}}}
    au CmdWinEnter : sil! iunmap <buffer> <tab>

    au CmdWinEnter * nno <buffer><expr><nowait><silent> q reg_recording() isnot# '' ? 'q' : ':<c-u>q<cr>'
    au CmdWinEnter * nno <buffer><nowait><silent> ZZ <cr>
    " Purpose:{{{
    "
    " By default,  C-c is useful to  quit the command-line  window, and populate
    " the command-line with the command which was being edited in the window.
    " But, it doesn't erases the command-line window.
    " Our `C-c` mapping takes care of that.
    "}}}
    au CmdWinEnter * nno <buffer><expr><nowait> <c-c> '<c-c>'..timer_start(0, {-> execute('redraw')})[-1]
augroup END

" Create Missing Directory {{{2

fu s:make_missing_dir(file, buf) abort
    " Before creating a directory, make sure that the current buffer:{{{
    "
    "    - is not a special one    `:h special-buffers`
    "    - is not a remote file    ftp://...
    "
    " Found here: http://stackoverflow.com/a/4294176
    "}}}
    if !empty(getbufvar(a:buf, '&buftype')) || a:file =~# '^\w\+:/'
        return
    endif
    let dir = fnamemodify(a:file, ':h')
    " if the directory already exists, nothing needs to be done
    if isdirectory(dir) | return | endif
    try
        call mkdir(dir, 'p')
    catch /^Vim\%((\a\+)\)\=:E739:/
        " If the directory is in a root directory, `mkdir()` will fail.
        " We need to run `$ sudo mkdir`.
        let pass = inputsecret('[sudo] password for '..$USER..': ')
        sil call system('sudo -S mkdir '..dir, pass.."\n")
        "                      │{{{
        "                      └ read the password from the standard input
        "                        instead of using the terminal device.
        "                        The password must be followed by a newline character.
        "}}}
        " Write the  file as root, so  that the next `:update`  (invoked when we
        " press `C-s`) does not fail.
        W
    endtry
endfu

augroup make_missing_dir
    au!
    au BufWritePre * call s:make_missing_dir(expand('<afile>:p'), +expand('<abuf>'))
augroup END

" Default Extension {{{2

" Temporarily commented, because I find it annoying now with `.vim`.
" Keep it, because it could still be useful for other extensions.

"     augroup DefaultExtension
"         au!
"         au BufNewFile * ++nested call s:default_extension(expand('<afile>:p'))
"     augroup END

"     fu s:default_extension(buffer) abort
"
"         " If the buffer name ends with a dot, it's probably a mistake.
"         " We don't want to add a default extension.
"         " We would end up with a buffer whose name contains a sequence of
"         " consecutive dots.
"
"         if a:buffer[-1:-1] is# '.'
"             return
"         endif
"
"         " If the buffer is created inside /tmp and has no extension
"         if strpart(fnamemodify(a:buffer, ':p:h'),0,4) is# '/tmp' && empty(fnamemodify(a:buffer, ':e'))
"
"             " make sure it will be wiped when it's hidden
"             " which will happen after the next command
"             setlocal bufhidden=wipe
"
"             " edit a new buffer with the same name + the .vim extension
"             exe 'keepalt edit ' . fnameescape(a:buffer) . '.vim'
"
"             " Why fnameescape()? Suppose we type :e foo\ bar to open a buffer
"             " whose name is 'foo bar'.
"             " The function will receive as an argument 'foo bar' (the backslash
"             " has been removed once Vim processed the :edit command).
"             " Then, the previous instruction will result in: :edit foo bar.vim
"             " and Vim will complain with: E172: Only one file name allowed
"             " We have to reprotect the space with fnameescape().
"             "
"             " Security_measure:
"             " if the previous command fails without  giving an error, and we stay in
"             " our current buffer  whose 'bufhidden' option's local  value is 'wipe',
"             " we want to  remove the latter (so  that the global value  is used like
"             " before). If it fails with an error,  the rest of the function won't be
"             " executed though.
"             set bufhidden<
"
"         endif
"     endfu

" Delete Noname Buffers {{{2

" We want to automatically delete buffers which are empty and don't have a name.
" So we install an autocmd listening to `BufHidden`.

augroup wipe_noname_buffers
    au!
    " Why delay `s:wipe_noname()`?{{{
    "
    " It seems the BufHidden event occurs just before a buffer becomes hidden.
    " Because of this, calling `s:wipe_noname()` immediately would wipe all noname
    " buffers, except the most recent one we're creating by closing its last window.
    "
    " We have to wait a little bit, to be sure that the last noname buffer we've
    " closed is really hidden.
    "
    " An  alternative would  be to  call  an intermediary  function which  would
    " install a one-shot autocmd listening to BufEnter (this event happens right
    " after BufHidden).
    " At that moment, we  could be sure the last hidden  noname buffer is really
    " hidden. And the autocmd would just have to call `s:wipe_noname()`.
    "}}}
    au BufHidden * call timer_start(0, {-> s:wipe_noname()})
augroup END

fu s:wipe_noname() abort
    " do NOT wipe any buffer while a session is loading
    "
    " When we save a session, Vim writes some commands towards the beginning of
    " the session file, to check if the current buffer is a noname-empty buffer.
    " And towards the end, it wipes it.
    " If we load a session from a noname-empty buffer, it will become hidden,
    " our autocmd will kick in, this function will be invoked, and it will
    " wipe the buffer before the end of the restoration of the session.
    " This will cause an error, because Vim will try to wipe the buffer a 2nd
    " time while it doesn't exist anymore.

    if exists('g:SessionLoad')
        return
    endif

    " Source: http://stackoverflow.com/a/6561076
    let to_wipe = filter(range(1, bufnr('$')), {_,v ->
    \    buflisted(v)
    \ && empty(bufname(v))
    \ && empty(win_findbuf(v))})
    "    │
    "    └ make sure the buffer is NOT displayed in any window

    if !empty(to_wipe)
        sil! exe 'bw! '..join(to_wipe, ' ')
    endif
endfu

" Filetype Linter {{{2

" TODO:
" Instead of using a match, automatically populate the qfl, and place signs.
" https://gist.github.com/BoltsJ/5942ecac7f0b0e9811749ef6e19d2176

" Purpose: get a warning when we make a typo in a filetype detection script {{{
"
" We often write something like this:
"
"     set sh
"
" Instead of:
"
"     set ft=sh
"}}}
augroup filetype_linter
    au!
    au WinEnter    filetype.vim,*/ftdetect/*.vim  call s:filetype_linter('enable')
    au BufWinLeave filetype.vim,*/ftdetect/*.vim  call s:filetype_linter('disable')
augroup END

fu s:filetype_linter(action) abort
    if exists('w:my_filetype_linter')
        sil! call matchdelete(w:my_filetype_linter)
        unlet! w:my_filetype_linter
    endif
    if a:action is# 'enable'
        let pat = '\m\C\%(^\%(\s*"\)\@!.*\)\@<=\mset\s\+\%(ft\|filetype\)\@!'
        let w:my_filetype_linter = matchadd('ErrorMsg', pat)
    endif
endfu

" Fire *Leave events on startup {{{2

" Purpose:{{{
"
" When Vim starts up, none of these events seem to be fired:
"
"    - `BufLeave`
"    - `BufWinLeave`
"    - `WinLeave`
"
" This may give unexpected results when Vim has just finished its startup.
"
" MWE:
"
"     vim -Nu NONE --cmd 'au BufWinEnter,WinEnter * setl stl=active' --cmd 'au BufWinLeave,WinLeave * setl stl=NOT\ active' -O /tmp/file{1..2}
"
" The status line in the right window displays `active`; I would expect it to display `inactive`.
"}}}
" https://github.com/vim/vim/issues/5243
augroup fire_leave_events_on_startup
    au!
    au VimEnter * call timer_start(0, {-> s:fire_leave_events()})
augroup END
fu s:fire_leave_events() abort
    " TODO: once Nvim supports `v:argv`, just write: `if match(v:argv, '\C^-[doO]$') != -1`
    if (!has('nvim') && match(v:argv, '\C^-[doO]$') != -1) || (has('nvim') && winnr('$') > 1)
        let curwin = win_getid()
        windo "
        call win_gotoid(curwin)
    endif
endfu

" Highlight ansi codes {{{2

augroup highlight_ansi
    au!
    " useful when we run sth like `$ trans word | vipe`
    au VimEnter * if $_ =~# '\C/vipe$' | call lg#textprop#ansi() | endif
    au StdinReadPost * call lg#textprop#ansi()
augroup END

" Include shell cwd in 'path' {{{2

augroup include_shell_cwd_in_path
    au!
    " Rationale:{{{
    "
    " We want to be able to press `ZF` to  open a file path in a Vim split, when
    " the buffer has been populated with a shell command such as:
    "
    "     $ find -name '*.rs' | vipe
    "     $ find -name '*.rs' | vim -
    "}}}
    "   Wait.  Doesn't Vim look in the cwd by default?{{{
    "
    " Yes it does, regardless of the value of `'path'` (even if you empty it).
    " But we have an autocmd in `vim-cwd` which may change the cwd (to `~/.vim`).
    " So, to be sure `ZF` works all the time, we need to tell Vim – explicitly –
    " to look into the cwd of the parent shell.
    "}}}
    au VimEnter * if $_ =~# '\C/vipe$' | set path+=$PWD | endif
    au StdinReadPost * set path+=$PWD
augroup END

" No syntax in diff mode {{{2

augroup no_syntax_in_diff_mode
    au!
    " Why do you clear the syntax in a diff'ed buffer?{{{
    "
    " When  you're  comparing  the  differences between  two  files,  you're
    " interested in the text which has changed.
    " You're not interested in the semantics of the code.
    "
    " IOW, the syntax  adds visual clutter, which makes it  hard to focus on
    " what is really important.
    "}}}
    au OptionSet diff exe v:option_new ? 'syn clear' : 'do Syntax'
    " We need this when we start Vim in diff mode right from the shell.{{{
    "
    "     $ vimdiff file1 file2
    "
    " This is because the previous autocmd is not fired in that case.
    " Maybe because the option is set  before the autocmd is installed, or maybe
    " because `OptionSet` is not fired at startup.
    "}}}
    au VimEnter * call s:if_diff_syn_clear()
    fu s:if_diff_syn_clear() abort
        if !&l:diff | return | endif
        let curwin = win_getid()
        windo syn clear
        call win_gotoid(curwin)
    endfu
augroup END

" Persistent clipboard {{{2

" Which issue is solved by this autocmd?{{{
"
" Start a terminal (not urxvt).
" Start Vim and copy some text in the clipboard (`""y...`).
" Quit Vim.
" Try to paste the clipboard in the terminal: it doesn't work.
"
" Do the same experiment with Nvim.
" You can paste the clipboard once; after that, you can't.
"}}}
"   What's the cause of the issue?{{{
"
" A text copied in the clipboard is called a "selection".
"
" When you yank some  text in the clipboard selection, Vim  becomes the owner of
" the latter.
"
" Later, in the terminal, when you ask for the clipboard selection to be pasted,
" the terminal  sends a  request to  the X  server, and  asks for  the clipboard
" selection from whoever currently owns it.
" The X  server will then relay  this request to  the other X client,  here Vim,
" that owns the clipboard selection.
"
" Now, if you've quit Vim, then no one owns the clipboard selection anymore, and
" so the request of the terminal fails.
" The same is true for any other application, like the web browser.
" So,  if you've  yanked some  text in  the clipboard  from Vim,  then quit  the
" latter, you won't be able to paste it in Firefox.
"
" This is explained at `:h clipboard-x11` (Nvim only):
"
" > X11 clipboard providers store text in "selections".
" > Selections are owned by an application, so when the application gets closed,
" > the selection text is lost.
" > The contents  of selections are  held by the originating  application (e.g.,
" > upon  a copy),  and  only  passed to  another  application  when that  other
" > application requests them (e.g., upon a paste).
"
" And here: https://vi.stackexchange.com/a/19726/17449
" And here: https://unix.stackexchange.com/a/254745/289772
"}}}
"     How do you fix it?{{{
"
" Before quitting Vim, we call `xsel(1x)`.
" We pass  it the contents  of Vim's clipboard, and  we make `xsel(1x)`  its new
" owner. You can check this by yanking some text in the clipboard, quitting Vim,
" then running:
"
"     $ ps aux | grep xsel
"     user 1234 ... xsel -ib~
"
" The `xsel(1x)` process will  persist for as long as you  don't yank some other
" text in the clipboard.
" For example, if  you copy sth from Firefox, then  re-run the previous `ps(1)`,
" you won't find `xsel(1x)` anymore.
"}}}

"     Why doesn't it affect urxvt?{{{
"
" It *does* affect urxvt.
"
" But if you have this code in `~/.Xresources`:
"
"     URxvt.perl-ext-common: selection-to-clipboard,pasta
"     URxvt.keysym.Control-Shift-V: perl:pasta:paste
"
" And this code in `~/.urxvt/ext/pasta`:
"
"     #! /usr/bin/env perl -w
"     # Usage: put the following lines in your .Xdefaults/.Xresources:
"     # URxvt.perl-ext-common           : selection-to-clipboard,pasta
"     # URxvt.keysym.Control-Shift-V    : perl:pasta:paste
"
"     use strict;
"
"     sub on_user_command {
"       my ($self, $cmd) = @_;
"       if ($cmd eq "pasta:paste") {
"         $self->selection_request (urxvt::CurrentTime, 3);
"       }
"       ()
"     }
"
" Then, the issue is partially mitigated.
" That is, you  can paste the clipboard  in an urxvt terminal  even after quitting
" the Vim instance from which you copied it, but you still can't paste it anywhere
" else.
"
" Btw, I can't find the perl script at  the address given in the file, but you can
" still find it here:
" https://wiki.gentoo.org/wiki/Rxvt-unicode#Copy.2FPaste_and_URL_handling
"
" ---
"
" Note that the issue also affects Nvim.
" But  for some reason,  you can still paste  the clipboard once  after quitting
" Nvim; after that, you can't.
"
" Before pasting the clipboard:
"
"     $ ps aux | grep 'xclip\|xsel'
"     user 1234 ... xclip -quiet -i -selection clipboard~
"
" After pasting the clipboard once:
"
"     $ ps aux | grep xclip
"     ''~
"
" Note that  by default, if `xclip(1)`  and `xsel(1x)` are both  installed, Nvim
" uses  `xclip(1)`,  unless  you've  configured  `g:clipboard`  to  use  another
" clipboard manager. See `:h g:clipboard`.
"}}}
"     Does it affect all applications?{{{
"
" No, for example, zathura is not affected.
" I don't know  why. Maybe it gives the ownership of  its clipboard selection to
" another program before quitting...
"
" OTOH, the issue does affect libreoffice.
"}}}

" Warning: If you change the name of the augroup, do the same in `tmux#capture_pane#main()`:{{{
"
"     ~/.vim/plugged/vim-tmux/autoload/tmux/capture_pane.vim
"}}}
augroup make_clipboard_persist_after_quitting_vim
    au!
    au VimLeave * call s:make_clipboard_persist_after_quitting_vim()
augroup END

fu s:make_clipboard_persist_after_quitting_vim() abort
    " Why the `strlen()` guard?{{{
    "
    " If the clipboard selection is too big, I don't want Vim to be slow when we quit.
    " If you find the current limit too low, you may increase it, after doing some tests:
    "
    "     :let @+ = repeat('a', 999999)
    "     :10Time call system('xsel -ib', @+)
    "}}}
    if !executable('xsel') || strlen(@+) == 0 || strlen(@+) > 9999
        return
    endif
    " Why do you pass the text via the second argument of `system()`?{{{
    "
    " There are two other alternatives.
    "
    " You could write the clipboard in a temporary file:
    "
    "     let tempfile = tempname()
    "     call writefile(split(@+, '\n'), tempfile, 'b')
    "     call system('xsel -ib '..tempfile)
    "
    " But it would be cumbersome, and maybe brittle.
    " What if for some reason the file is removed before `xsel(1x)` has a chance
    " to read it, or it does not have the right permissions (`writefile()` can't
    " write into it, `xsel(1x)` can't read it)?
    "
    " ---
    "
    " Or, you could use a pipe:
    "
    "     call system('printf -- '..shellescape(@+)..' | xsel -ib')
    "
    " But note that we already have 3 pitfalls to avoid.
    " We  don't want  a trailing  newline  to be  appended,  so we  have to  use
    " `printf` instead of `echo` (you could use `echo -n`, but in general `echo`
    " is not reliable).
    "
    " We don't the  beginning of the text  to be interpreted as an  option if it
    " begins with a hyphen, so we need `--`.
    "
    " We  don't want special  characters to be interpreted  by the shell,  so we
    " need `shellescape()`.
    " But even with all those precautions, it would still not be reliable.
    " For example, in Vim, try to copy this text in the clipboard:
    "
    "     +some str%nge|name'with"quotes!bang$dollar
    "
    " Then quit Vim, and paste it in the terminal:
    "
    "     +some strge|name'with"quotes!bang$dollar~
    "              ^
    "              ✘ where is `%n`?
    "}}}
    sil call system('xsel -ib', @+)
endfu

" Read special files {{{2

" The following autocmd  allows us to read  special files like a pdf  or an odt.
" They use a few shell utilities as filter:
"
"    - antiword
"    - odt2txt
"    - pandoc
"    - pdftotext
"    - unrtf

augroup filter_special_file
    au!
    " Why not use `BufReadPost`?{{{
    "
    " It would indeed be more appropriate than `BufWinEnter`.
    " But  for some  reason,  Vim doesn't  fire `BufReadPost`  when  it reads  a
    " `.docx` or `.epub` file.
    "
    "     au BufReadPost  *.docx  sil %!pandoc -f docx -t markdown %:p:S
    "        ^
    "        ✘
    "
    " We could use `FileType tar`:
    "
    "     au FileType  tar  sil %!pandoc -f docx -t markdown %:p:S
    "
    " ... but $VIMRUNTIME/plugin/tarPlugin.vim would leave some undesired
    " messages inside the buffer; it's noise.
    " Maybe it's because the event is fired too early, and the built-in tar plugin
    " processes the buffer after the event.
    "}}}
    au BufWinEnter  *.{doc,docx,epub,odp,odt,pdf,rtf}  call s:filter_special_file()
augroup END

fu s:filter_special_file() abort
    if get(b:, 'did_filter_special_file', 0)
        return
    endif

    let fname = expand('%:p:S')
    let ext = expand('%:e')
    let ext2cmd = {
        \ 'doc' : '%!antiword '..fname,
        \ 'docx': '%!pandoc -f docx -t markdown '..fname,
        \ 'epub': '%!pandoc -f epub -t markdown '..fname,
        \ 'odp' : '%!odt2txt '..fname,
        \ 'odt' : '%!odt2txt '..fname,
        \ 'pdf' : '%!pdftotext -nopgbrk -layout -q -eol unix '..fname..' -',
        \ 'rtf' : '%!unrtf --text',
        \ }

    if has_key(ext2cmd, ext)
        let filter = matchstr(ext2cmd[ext], '%!\zs\S*')
        if !executable(filter)
            echom 'cannot filter '..expand('%:p')..'; please install '..filter
            return
        endif

        setl modifiable noreadonly
        " About: '%!pdftotext -nopgbrk -layout -q -eol unix '.fname.' -'{{{
        "                                                             │
        "                                                             └ write output on STDOUT, which is piped to `par`
        "}}}
        " FIXME: Initially, we used the shell utility `fmt`:{{{
        "
        "     '%!pdftotext -nopgbrk -layout -q -eol unix '.fname.' - | fmt -w78'
        "
        " The formatting was awful (too much random spacing everywhere).
        " `par(1)` gives a more readable text:
        "
        "     '%!pdftotext -nopgbrk -layout -q -eol unix '.fname.' - | par -w80rjeq'
        "
        " However, there are still errors.
        " Look at the bottom of a `pdf` file filtered by `par(1)`, to find error
        " messages. It's often  due to  a too long  “word” (more  precisely what
        " `par(1)` considers a word). Because of this, a pdf is often truncated.
        " So, I don't use it atm.
        "
        " Try to fix these errors by  learning how to better configure `par(1)`,
        " through  command-line  options,  and/or through  `$PARINIT`. Then  use
        " `par(1)` to format a pdf.
        "}}}
        sil exe ext2cmd[ext]
        let b:did_filter_special_file = 1
        setl buftype=nofile nomodifiable noswapfile readonly
    endif
endfu

" Regenerate helptags {{{2

augroup regenerate_helptags
    au!
    au BufWritePost ~/.vim/plugged/*/doc/*.txt exe 'helptags '..expand('<amatch>:p:h')
augroup END

" Reload config {{{2

augroup source_files
    au!
    " Why no `-merge`?{{{
    "
    " If you pass the `-merge` option to `xrdb`, the background color you choose
    " for urxvt won't be applied in xterm, because of this existing resource:
    "
    "         *customization: -color
    "
    " See `xrdb -query` to get a list of all existing resources.
    "}}}
    au BufWritePost ~/.Xresources sil call system('xrdb ~/.Xresources')
    au BufWritePost ~/.vim/autoload/myfuncs.vim exe 'source '..expand('<afile>:p')

    " Why shouldn't I write any autocmd listening to `BufWritePost` after this one?{{{
    "
    " see `Warning` at the beginning of our autocmd section.
    "}}}
    " Could I move the autocmd sourcing `myfuncs.vim` afterwards nonetheless?{{{
    "
    " Yes, because they are not triggered by the same filename.
    " When you write `myfuncs.vim`, this augroup is not cleared.
    " Still, don't do it.
    "}}}
    au BufWritePost $MYVIMRC exe 'source '..expand('<afile>:p')
augroup END

" Standard Input {{{2

augroup my_stdin
    au!
    au StdInReadPost * if line2byte(line('$')+1) <= 2 | cquit | endif
augroup END

" Spell files {{{2

" When spell checking is enabled, and we mark  a word as good or bad, we make an
" addition into `~/.vim/spell/fr.utf-8.`.
" But,  for  Vim to  take  this  addition into  account,  it  has to  perform  a
" successful check on the corresponding binary file `fr.utf-8.add.spl`.
"
" Versioning  those binary  files with  git  could cause  pb (conflicts  between
" different versions).

" When  we switch  to  another  machine, we  should  regenerates  them with  the
" `:mkspell!` command.
" The bang asks to overwrite an old binary if there's already one.
" So  we do  it  here, for  every  spell binary  file, but  only  if the  binary
" (.add.spl) is older than the original addition file (.add).

augroup my_mkspell
    au!
    " Why `map()`?{{{
    "
    " Because there can  be several spell files (one per  language), in which we
    " made additions.
    "
    " http://vi.stackexchange.com/a/5052/6960
    "}}}
    au VimEnter * call map(glob('~/.vim/spell/*.add', 1, 1),
        \ {_,v -> filereadable(v) && !filereadable(v..'.spl') || (getftime(v) > getftime(v..'.spl'))
        \         && execute('mkspell! '..fnameescape(v))})
augroup END

" Swap file handling "{{{2

" What does this autocmd do?{{{
"
" It answers automatically to the question asked when a swap file is found.
" If the swap file is older than the file, it's removed because useless, and the
" file is editd as if nothing happened.
"
" If the swap  file is newer, the file  is opened in readonly mode,  so that you
" can see its contents, but not change it (without being warned).
"}}}
" Which pitfall does it fix?{{{
"
"     $ vim /tmp/file
"     $ vim (a 2nd instance)
"     :try | e /tmp/file | catch | endtry
"
" If the  file is already  loaded in another instance,  it will raise  the error
" `e325` (Attention: Found a swap file ...).
"
" But the error won't  be catched because Vim prompts us  with a question to
" know what we want to do (edit, quit, ...).
" Worse, the question is not visible.
"
" This can happen when  a plugin tries to edit a file  with a `try` conditional,
" and Vim finds out that a swap file exists.
"}}}
" Why don't you use `set shm+=A`?{{{
"
" `set shm+=A` would completely bypass the  question and the existence of a swap
" file would never be brought to our attention.
"
" In contrast, this  autocmd will still warn  us whenever a swap  file is found,
" and write the  warning in the messages, so  that we can review it  later if we
" need to debug some unexpected behavior from Vim.
"
" Besides, it won't let us edit a file for which a newer swap file exists.
" There could be valuable information in there.
"}}}

" A swap file has been found, and the file has been loaded in readonly mode!  What should I do?{{{
"
" If you only need to read the file, nothing. Just read it.
"
" If you need to edit the file, you have an issue.
" Indeed, if  the autocmd hasn't  removed the swap file,  it means the  latter is
" more recent than the file (or has the same timestamp).
"
" So, it could  contain valuable information, that you need  to recover *before*
" doing  any further  change (because  this valuable  information may  radically
" alter the change you intend to do).
"}}}
" How do I recover the contents of a swap file?{{{
"
"     # recover swap file
"     $ vim -r file
"
"     " save the result in another file
"     :write file.recovered
"
"     " load the original (unrecovered) file in readonly mode
"     " (this works thanks to our autocmd which should answer the question)
"     :e!
"
"     " show the differences between the original file and its recovered version
"     :diffsp file.recovered
"
" We have encapsulated this procedure in a zsh function (`vim_recover()`).
"
" If the recovered file looks good, you still have to execute:
"
"     $ mv file.recovered file
"
" See `:h 11.1` for more info.
"}}}

" (stolen from blueyed)
augroup swapfile_handling
    au!
    au SwapExists * call s:handle_swapfile(expand('<afile>:p'))
augroup END

fu s:handle_swapfile(filename) abort
    " If the swap file is older than the file itself, just get rid of it.
    if getftime(v:swapname) < getftime(a:filename)
        call s:warning_msg('Old swap file detected, and deleted:   '..a:filename)
        call delete(v:swapname)
        let v:swapchoice = 'e'
    else
        call s:warning_msg('Swap file detected, opening read-only:   '..a:filename)
        let v:swapchoice = 'o'
    endif
endfu

fu s:warning_msg(msg) abort
    echohl WarningMsg
    " It seems that when `SwapExists` is fired, Vim executes `:echom` silently.
    unsilent echom a:msg
    echohl NONE
endfu

" Trailing Whitespace {{{2

" Trailing whitespace in red but not if the filetype is blacklisted:
let s:NO_TRAILING_WHITESPACE_FT =<< trim END

    fzf
    git
    help
    qf
    text
END

augroup trailing_whitespace
    au!
    au VimEnter,WinEnter,InsertLeave * call s:trailing_whitespace(1)
    " Why do you delay the call to `s:trailing_whitespace()`?{{{
    "
    " When `UltiSnipsExitLastSnippet` is  fired, `g:expanding_snippet` may still
    " exist (it probably depends on the order of our custom autocmds).
    " In that case, the match won't be re-installed; we want it to be re-installed.
    "}}}
    " Why the `mode()` guard?{{{
    "
    "    1. Expand the `vimrc` snippet.
    "    2. Press Tab repeatedly to traverse all the tabstops.
    "    3. Insert `fu`.
    "
    " The `fu` snippet is automatically expanded (✔); the trailing whitespace is highlighted (✘).
    "}}}
    au User UltiSnipsExitLastSnippet if !has('nvim')
        \ |     exe 'au SafeState * ++once if mode() is# "n" | call s:trailing_whitespace(1) | endif'
        \ | else
        \ |     call timer_start(0, {-> mode() is# 'n' ? s:trailing_whitespace(1) : ''})
        \ | endif

    au InsertEnter * call s:trailing_whitespace(0)
    " We don't want a match in a preview window.{{{
    "
    " The match is useful to let us  know that we should probably remove useless
    " trailing whitespace.
    " However, a preview window is not opened to *edit* text, but to *read* text.
    " In this context, the match is just noise.
    "}}}
    au WinLeave * if &l:pvw | call s:trailing_whitespace(0) | endif
    " We don't want a match in a terminal buffer when we quit terminal-job mode.{{{
    "
    " In  Vim,  the match  is  installed  when  we  open a  terminal  window
    " (`WinEnter`).
    " After that, it's not removed, because  `InsertLeave` is not fired in a
    " terminal, so our autocmd which deletes the match is not triggered.
    "
    " ---
    "
    " This is useless in Nvim.
    " First, the match is not installed, because we don't install the match in a
    " buffer whose filetype is empty (and it is in a terminal buffer).
    " Second, even if it was, it doesn't seem to be applied.
    "
    " ---
    "
    " You may wonder why the match is  installed in a Vim terminal buffer, since
    " its filetype  is empty, and  we check the  filetype is *not*  empty before
    " installing any match.
    " I think that's because when `WinEnter`  is fired, the filetype has not yet
    " been correctly set.
    "}}}
    if !has('nvim')
        au TerminalWinOpen * call s:trailing_whitespace(0)
    endif

    " An undesirable match will be installed in a help buffer, even with `help` in `s:NO_TRAILING_WHITESPACE_FT`.{{{
    "
    " Execute `:h :as` twice, and you'll see it.
    " This is because when `WinEnter` is fired, `&filetype` has not been correctly set yet.
    "
    " So, we must make sure to remove this match with an additional autocmd.
    "
    " ---
    "
    " You may wonder why we don't listen to `Filetype help`:
    "
    "     au FileType help call s:trailing_whitespace(0)
    "
    " It's not always fired.
    "
    " MWE:
    "
    "     $ vim +'LogEvents filetype'
    "     :h :as
    "     :q
    "     :h :as
    "
    " Note that if you reset `'hidden'`, `FileType` is always fired.
    " This is because when  you close the help window, the  help buffer can't be
    " hidden (`BufHidden`), and Vim has to unload it (`BufUnload`).
    " As a result, the next time you ask to see the same help file, Vim has to read
    " the file again, which triggers `BufReadPre`, `FileType` and `BufReadPost`.
    "}}}
    au BufWinEnter {$VIMRUNTIME,$HOME/.vim,$HOME/.vim/*}/doc/*.txt call s:trailing_whitespace(0)
    " Same issue when we split a window to read a text file:{{{
    "
    "     :e /tmp/vim.vim
    "     :sp /tmp/txt.txt
    "     " when `WinEnter` is fired, the filetype is still 'vim', not 'text'
    "
    " In particular, we don't want a match after running `:VimPatches 8.1`; it's
    " noise. More generally,  trailing whitespace  in a  text file  is harmless,
    " because it's not code; so we don't care about its presence.
    "}}}
    exe 'au FileType '
        \ ..join(filter(copy(s:NO_TRAILING_WHITESPACE_FT), {_,v -> v isnot# ''}), ',')
        \ ..' call s:trailing_whitespace(0)'
    " we still have an undesired match when we run `:VimPatches 8.1` *twice*
    au BufWinEnter * if &ft is# 'text' | call s:trailing_whitespace(0) | endif
augroup END

fu s:trailing_whitespace(create_match) abort
    if exists('g:expanding_snippet') | return |endif
    if !a:create_match && exists('w:my_trailing_whitespace')
        " Why `sil!`?{{{
        "
        " Because the match may not exist anymore.
        " For example, in `~/.vim/plugged/vim-qf/after/ftplugin/qf.vim:182`,
        " we invoke `clearmatches()`.
        "}}}
        sil! call matchdelete(w:my_trailing_whitespace)
        unlet w:my_trailing_whitespace
    elseif a:create_match
       \ && !exists('w:my_trailing_whitespace')
       \ && index(s:NO_TRAILING_WHITESPACE_FT, &filetype) == -1
        let w:my_trailing_whitespace = matchadd('Error', '\s\+$', -1)
    endif
endfu
" }}}1
" To_Do {{{1

"     *s/^\%V"\s\=\zs\d\+\ze\s*-/\=submatch(0)-1/c
"
" 1 - Move the cursor some lines down (cd) or up (cu).
" The motion bypasses all the lines which have an indentation level greater or
" equal than our current cursor position.
" Useful to move by logical blocks of code of the same level.
"
" http://vi.stackexchange.com/a/213/6960
"        nno cd /\%<c-r>=virtcol('.')<cr>v\S<cr>
"        nno cu ?\%<c-r>=virtcol('.')<cr>v\S<cr>
"
" 2 - Vimcast, Episode 50, An introduction to vspec
"
" https://github.com/junegunn/vader.vim (927 sloc)
"
" http://whileimautomaton.net/2013/02/13211500
" https://github.com/kana/vim-vspec
" https://github.com/kana/vim-flavor
" http://www.relishapp.com/kana/vim-flavor/docs
"
" 3 - Implement the concept of "narrowing region".
"
" A mapping, or command which would copy a range of lines in a temporary buffer.
" We could edit this temp buffer, and after writing it, the original selection
" would be replaced by it.
" There's a plugin for that:
"
" https://github.com/chrisbra/NrrwRgn
"
" ... but the source code is too long (1500 sloc).
" Take inspiration from it.
"
" 4 - Implement ]n, ]s, ]u, ]x, ]y from unimpaired.vim
"
" 5 - Tmux navigation
" La navigation entre les panes de Tmux et les viewports de Vim n'est pas
" cohérente.
" Pour aller dans un pane Tmux depuis Vim, on peut taper C-{hjkl}.
" Mais en sens inverse (Tmux → Vim), il faut passer par le préfixe Tmux, `pfx + hjkl`.
" On a fait ça pour ne pas perdre les raccourcis readline dans le shell.
" On devrait peut  être associer un keycode modificateur (Hyper?)  sur la touche
" Super  (ou la  touche  ctrl gauche?),  et  se servir  de  cette dernière  pour
" naviguer entre Tmux et Vim: Super + {hjkl}.
"
" Plus généralement, revoir tout le code tmuxnavigator et repenser la
" navigation.
" Trop d'incohérences.
" Navigation entre onglets  Vim, viewports Vim, panes Tmux,  fenêtres Tmux, Tmux
" <-> Vim ...
" C'est un gros bordel:
"
"     AltGr-hl, C-hjkl, pfx-hjkl, M-hl
"
" Autre Idée:
"
"     C-hjkl             pour naviguer entre viewports et onglets  Vim.  (facile?)
"     Left Right Down Up "                   panes     et fenêtres Tmux. (difficile?)
"
" For the Tmux part, we would need to define conditional mappings.
" Maybe draw inspiration from here:
" http://stackoverflow.com/a/12380693
"
" Autres liens intéressants:
" https://silly-bytes.blogspot.fr/2016/06/seamlessly-vim-tmux-windowmanager_24.html
" https://sunaku.github.io/tmux-select-pane.html
" https://github.com/urbainvaes/vim-tmux-pilot
"
" 6 -
"
" https://github.com/hunspell/mythes
" https://hunspell.github.io/
" http://icon.shef.ac.uk/moby/mthes.html
"
" Lire le code de:
"
" https://github.com/beloglazov/vim-online-thesaurus/
"
" Ajoute ça dans le vimrc:
"
"     plug 'beloglazov/vim-online-thesaurus'
"     let g:online_thesaurus_map_keys = 0
"
" Très court (144 sloc).
" Comme le plugin est court, on pourrait peut-être l'adapter pour le support
" du français.
" Chercher un site équivalent à thesaurus.com pour le français.
" Ou chercher une bdd de synonymes, et écrire un algo qui l'analyse:
"
" http://www.dicollecte.org/download.php?prj=fr
"
" On pourrait aussi s'inspirer de la méthode du plugin pour ouvrir un split de
" taille dynamique, adapté à la taille des données à afficher.
"
" Jeter un oeil aux liens suivants :
"
" https://hyperdic.net/en/doc/antonyms
" (trouvé en cherchant "where can i download antonym file" page 3)
" https://github.com/emugel/vim-thesaurus-files
"
" character-wise visual mode word lookup
" https://github.com/beloglazov/vim-online-thesaurus/pull/31
"
" Créer une méthode mucomplete qui s'en sert.
"
" 7 -
"
" Why `:FzRg!` + `foobar` (in interactive mode) gives much more results than
" `:FzRg! foobar`?
" More generally, I don't know how `:Rg` and `rg(1)` interpret metacharacters.
" Make some tests, read doc.
" Example: compare `:FzRg! foo.*bar` and `:FzRg!` + `foo.*bar`
"
" I think `:FzRg! pattern` does not fuzzy search pattern, it performs
" a standard search (not fuzzy).
" OTOH, `:FzRg!` + `pattern` performs a live fuzzy search.
"
" 8 -
"
" Extract big chunks of code from `myfuncs.vim` into separate plugins.
"
" 9 -
"
" Read and integrate `:h slow-start` in our notes.
"
" Update: Could we remove `!` from `'vi'`?
" If so,  maybe it  would make Vim  start faster;  it would not  have to  load a
" possibly big dictionary saved in a global variable.
"
" 10 -
"
" Integrate `~/wiki/diff.md` into `~/wiki/vim/vim.md`.
" Or into `~/wiki/admin.md`.
" Yeah... maybe everything which is related to diff or vimdiff, put it inside
" admin.
"
" 11 -
"
" In a temporary directory, execute these shell commands:
"
"     touch file{1..3}; mkdir -p foo/{bar,baz}/{qux,norf}
"     tree -a | vipe
"
" Look at the diagram. Implement a mapping / command which would expand an
" abbreviation into this kind of diagram.
" For the abbreviation, we could take inspiration from the shell commands
" themselves. Or sth else?
"
" A simple way of doing this would be to call just the `tree` command:
"
"     r !touch file{1..3}; mkdir -p foo/{bar,baz/qux}/{norf,abc}; tree -a
"
"     during the shell expansion `bar` and `baz/qux` are appended to `foo`
"     and `norf` and `abc` are appended to `foo/bar` and `foo/baz/qux`
"     so we end up with 4 (2*2) leaf directories + 4 intermediate directories
"     (foo, bar, baz, qux)
"
" But we would have to create a temporary directory, and temporarily `cd` to it
" to avoid polluting the current working directory.
" Besides, we would have to protect all kind of special characters which could
" be present in the text we want to insert in the diagram.
"
" However, mkdir seems limited to produce a complex hierarchy.
" A better way would be to look at the syntax used by emmet to expand html
" tags. Our mapping/command would parse a similar command to produce
" a hierarchy of items of an arbitrary complexity.
"
" Also, have a look at the diagram in `:h syntax-loading`. Very interesting.
" Without this diagram, the explanations would be much more verbose, and less
" readable. Implement a visual mapping, which would automatically draw the
" right diagram in front of the lines inside the selection (drawing `+`, `-`, `|`).
"
"     ~/Desktop/diagram
"
" Also, install mappings to draw vertical diagrams instead of horizontal ones.
" Have a look at our notes about the try conditional for an example where it
" would be useful.
"
" Try this:
"
"     % api cpanminus
"     % sudo cpanm graph::easy
"
"     to uninstall later
"     % sudo cpanm --uninstall graph::easy
"
" Write this in a file:
"
"     digraph {
"         start -> adsuck;
"         adsuck -> block;
"         block -> noop[label="yes"];
"         block -> unbound[label="no"];
"         noop -> serve_noop[label="yes"];
"         noop -> serve_empty[label="no"];
"     }
"
" Visually select it, and type:
"
"     :'<,'>!graph-easy --as ascii
"                                  ^
"                                  don't add `%`
"                                  it would work, but if you have several digraph codes
"                                  in the current file, they will all be expanded, even
"                                  if you only select one in particular
"
" Interesting links:
" https://vi.stackexchange.com/a/541/13370
" http://melp.nl/2013/08/flow-charts-in-code-enter-graphviz-and-the-dot-language/
" https://github.com/wannesm/wmgraphviz.vim
" `man graph-easy`
"
" Update:
" This is really useful with vim-schlepp, and vim-draw.
" You create  the skeleton of  the diagram with  graph-easy, then tweak  it with
" vim-schlepp + vim-draw.
"
" Also, remember we've  created the `:BoxPrettify` command. Useful  to convert a
" raw ascii diagram, in a more polished one.
"
" 12 -
"
" Look  for mappings  which would  benefit from  being made  dot/semicolon/comma
" repeatable.
"
" 13 -
"
" `:!` and `system()` are not interactive / show ansi codes (besides try
" `!cat`, `!restore-trash`)
"
"     if has('nvim')
"       cno <expr> ! getcmdtype() is# ':' && getcmdline() is# ''
"                  \ ?     '!tmux split-window -c '.getcwd().' '
"                  \ :     '!'
"     endif
"
" https://github.com/neovim/neovim/issues/1496
"
" 14 -
"
" Document the fact that the tmux buffers are especially useful when you work in
" a vim which wasn't compiled with the clipboard support (no `+` register).
"
" Think docker ultisnips:
"
" https://github.com/sirver/ultisnips/blob/master/contributing.md#running-using-docker
" https://github.com/sirver/ultisnips/blob/master/contributing.md#reproducing-bugs
"
" 15 -
"
" Protect all temporary change of option with `try|catch|endtry`.
" Look for the pattern:
"
"     _save\|save_\|old_\|_old
"
" Do it in vimrc, myfuncs, plugins.
"
" For the replacement, use this construct:
"
"     preparations (like saving options)
"     try
"         do sth which can fail
"
"     catch
"         return lg#catch()
"
"     finally
"         mandatory conclusion (like restoring options)
"     endtry
"
" 16 -
"
" Re-read our snippet `op`, and refactor this section in our notes:
"
"         # mappings / abréviations
"       → ## opérateurs
"
" Also:
" refactor all operators so that they remove  'unnamed' and 'unnamedplus'
" from 'cb', and set 'inclusive'
"
"     vim /g@/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"     :cfilter! -other_plugins
"
" Also:
"     catch
"         return lg#catch()
"
" Also:
" what happens if you do:
"
"       op + v + motion
"
" I've just checked with `|gvj` (grep text from current position until next
" line, characterwise). And inside `op_grep()`, `a:type` is `char`, which is
" good. If it had been visual, we could have a problem, because our function
" would think we are operating from visual mode, instead of normal mode.
"
" To document.
"
" ---
"
" Should we yank with noautocmd to prevent our visual ring from saving
" a possible selection?
"
" 17 -
"
" Create a mapping to populate command-line with `:ltag /`, then open the
" location window. Ex:
"
      nno <expr> <c-g>t <sid>ltag(1)
      fu s:ltag(step) abort
          if a:step == 1
              augroup my_ltag
                  au!
                  " Why the timer?{{{
                  "
                  " If  we cancel,  or the  search fails  to find  anything, the
                  " one-shot autocmd will still be, wrongly, active.
                  " We should make sure to remove  it with a timer, after a very
                  " short period of time.
                  "}}}
                  " Still, syntax highlighting would work better.
                  " Less hack, no timer.
                  au CmdlineLeave : call timer_start(5, {-> execute(['au! my_ltag', 'aug! my_ltag'], 'silent!')})
                  au FileType qf ++once call s:ltag(2)
              augroup END
              return ':ltag / | lw'..repeat("\<left>", 5)
          elseif a:step == 2
              let pat = '|.\{-}|'
              " FIXME: It works if we press `gt`, which invokes this function.
              " But  if we  execute `:ltag`  manually, the  function won't  be
              " invoked, and the conceal won't be applied.
              " This brings an inconsistent user experience.
              " Try to use a syntax highlighting file (inspiration: man plugin
              " in neovim).
              call qf#set_matches('vimrc:ltag', 'conceal', pat)
              call qf#create_matches()
          endif
      endfu
"
" Update:
" It should probably be implemented as a cycle in `vim-cmdline`.
"
" Also:
" Play with `:tj / c-d`.
"
" It seems that `<space>ft` (fzf.vim) is identical to `:tj /`.
"
" 18 -
"
" Shell function to grep a pattern and populate the qfl.
" This one doesn't send the results to a vim server, and allows to pass
" arbitrary flags to grep.
" https://www.reddit.com/r/vim/comments/6oj6gg/what_are_some_lesser_know_tips_and_tricks_in_vim/dki09wt/
" https://www.reddit.com/r/vim/comments/6oj6gg/what_are_some_lesser_know_tips_and_tricks_in_vim/dkiw87v/
"
" Difference compared to our `nv()` shell function?
"
" 19 -
"
" Read `:h cscope` (useful to list tags in qfl?)
" https://www.reddit.com/r/vim/comments/6p6uch/how_to_refactor_by_tags/dkn30bd/
"
" 20 -
"
" If we search a too complex pattern, `n` takes a long time to compute the nr
" of matches (total & current).
" The pb comes from this line:
"
"     let output = execute(a:range.'s///gen')
"
" It shows us a fondamental pb. How to prevent a command from taking too much
" time? Here, we have a few solutions:
"
"    - try to guess by computing the nr of matches on a small range if it
"      goes beyond a certain threshold, we could report to the user that
"      there are too many matches
"
"      pb: most of the matches could be outside this small range
"
"    - refactor the code to use a while loop, and monitor the total time
"      taken after each iteration
"
"      pb: the while loop seems 6 times slower overall, compared to `s///gen`
"
" Solution proposed by ingo:
"
"     :help catch-interrupt
"
" Tweak the function so that we can interrupt it with `C-c`.
" Don't use `echoerr` in the catch clause. it would raise an error (again).
" use `echo` (+ echohl if needed).
" PS: I've tried this solution but the message gets erased.
" To continue...
"
" 21 -
"
" Use `:[c|l]bottom` in your jobs plugins (if they populate a qfl asynchronously)
"
" 22 -
"
" Re-implement these mappings to open the file you're editing on github.
" It could be handy when you want to see a commit you've just pushed.
"
"     nno <silent>  <space>og  V:<c-u>call <sid>open_current_file_in_github()<cr>
"     xno <silent>  <space>og  :<c-u>call <sid>open_current_file_in_github()<cr>
"
"     fu s:open_current_file_in_github() abort
"       let file_dir = expand('%:h')
"       sil let git_root = system('cd '..file_dir..'; git rev-parse --show-toplevel | tr -d "\n"')
"       let file_path = substitute(expand('%:p'), git_root..'/', '', '')
"       sil let branch = system('git symbolic-ref --short -q HEAD | tr -d "\n"')
"       sil let git_remote = system('cd '..file_dir..'; git remote get-url origin')
"       let repo_path = matchstr(matchlist(git_remote, ':\(.*\)\.')[1], 'github\.com/\zs.*')
"       let url = 'https://github.com/'..repo_path..'/blob/'..branch..'/'..file_path
"       let first_line = getpos("'<")[1]
"       let url ..= '#L'..first_line
"       let last_line = getpos("'>")[1]
"       if last_line != first_line | let url ..= '-L'..last_line | endif
"       sil call system('xdg-open '..url)
"     endfu
"
" Source:
" https://www.reddit.com/r/vim/comments/9r3rcd/open_current_file_in_github/
"
" Update:
" `:Gbrowse` does sth similar.
"
" 23 -
"
" Refactor all our functions which populate the qfl to offload work to a single
" function in `vim-qf`?
"
"     vim /set\%(qf\|loc\)list/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"
" 24 -
"
" Look for  functions containing  the keyword  `maybe` or  `later` (or  look for
" `aug\%[roup]!`).
" These functions probably execute code which must be delayed.
" Make sure they are not called by yet another function:
"
"     Func()
"       ...
"       call Func_later()
"       ...
"     endfu
"
" There is no need to:
"
"     Func(later)
"       ...
"       if a:later
"           call Func(0)
"       endif
"       ...
"     endfu
"
" 25 -
"
" https://github.com/chrisbra/vim_faq
" We've  stopped  reading  at  `faq-4.2`,  because we  need  time  to  integrate
" `:tselect` in our workflow.
" Indeed there are many similar commands:
"
"    - `g]`
"    - `:stselect`
"    - `:tselect`
"    - `:ptselect`
"
"    - `g C-]`
"    - `:tjump`
"    - `:stjump`
"    - `:ptjump`
"
" 26 -
"
" No need to check `if &bt  is# 'quickfix'` before applying conceal abort and/or
" try conditional are enough.
" Sure?
"
"     vim /if\s\+&bt\s\+is#\s\+'quickfix'/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"
" 27 -
"
" https://github.com/justinmk/vim-dirvish/issues/62
" https://github.com/bounceme/remote-viewer/
"
" Alternative:
" fuse/sshfs provides an abstraction at the filesystem layer (as opposed to some
" other "middleware"),  so that  any dumb local  navigator (like  dirvish) works
" without adding special-case support for scp, ftp, webdav, ..., netrw does.
"
" 28 -
"
" Do we really need a timer to display a message?
"
"     vim /execute(.*echo/gj ~/.vim/**
"
" We haven't seriously taken into account `:redraw`.
"
" https://github.com/google/vim-searchindex/blob/28c509b9a6704620320ef74b902c064df61b731f/plugin/searchindex.vim#l187-l189
"
" Make  more   tests,  take  into   account  all  relevant   parameters  (8*2=16
" environments), in Vim and Nvim:
"
"    - 'lz'
"    - :redraw
"    - <expr>
"    - timer
"
" Once you're done:
"
"     :noa vim /timer_start(/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/** | cw
"
" Look for all  the instances where we've  used a timer and where  we could have
" used a simple `:redraw`. Replace the timer if it makes sense.
"
" Note that in `vim-fex`, in `fex#print_metadata()`, we must use a `:redraw`,
" not a timer.
" Otherwise,  the  first  part  of  the  message  is  correctly  displayed  (via
" `:echon`), but not the second one.
" This seems to indicate that a timer is not always the best solution to display
" a message.
" Maybe we should use `:redraw` more often before an `:echo`.
"
" See `:h :echo-redraw`.
"
" 29 -
"
" Create mapping to send current line to terminal, and execute it
" Use `g>` for the lhs?
"
"     g> + text object
"     g> on visual selection
"     g>> for line
"
" 30 -
"
" Finish reviewing vim-math
" What insight can we gain from it?
"
" Also, look at this:
"
" https://github.com/sk1418/howmuch
"
" Is there any functionality we could steal?
"
" 31 -
"
" Finish reviewing `~/Dropbox/vim_plugins/pair_complete.vim`.
"
" 32 -
"
" We use `cml`, `cms`, in vimrc, myfuncs and in some of our plugins:
"
"    - iabbrev
"    - pair-complete
"    - titlecase
"
" It's  reliable  for programming  languages  where  the  cml must  be  repeated
" identically on every line of a  multi-line comment. What about the others (ex:
" c)?
"
" Update:
" We should distinguish 2 problems.
" (un)commenting a line vs detecting whether a line is commented.
" We solved the 1st problem in `vim-comment`.
" For the 2nd one, try this expression:
"
"     synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')  isnot#  'comment'
"
" 33 -
"
" Check whether some Ex commands would be better suited as mappings.
"
" And check whether some mappings would be better suited as Ex commands.
" Hint: if you keep forgetting the lhs of a mapping, turn it into an Ex command.
"
" 34 -
"
" Install autocmd listening to `BufReadPost */after/ftplugin/*.vim`
" which would install a buffer-local autocmd listening to `bufwritepost`
" which would give us a warning when we forget to undo a
" mapping/abbreviation/command/autocmd/variable
"
" or when we undo a non-existing ...
"
" 35 -
"
" Normalize underscore/hyphen in plug mappings, and function names in shell init
" files.
"
" 36 -
"
" Update the position of the mark in `vim-readline`
"
" MWE:
"
"     $ echo 'h|ello'
"              ^
"              cursor
"
"     press c-spc  (sets the mark right after the `h`)
"
"     $ |echo 'jjjjjjjjjjjjjjjjjjjhello'
"       ^      ├─────────────────┘
"       │      └ insert all of these
"       │
"       new cursor position
"
"     press c-x c-x  (exchange cursor and mark position)
"
" Result:
" in bash:
"
"     $ echo 'j|jjjjjjjjjjjjjjjjjjhello'
"              ^
"              ✘
"
" in zsh:
"
"     $ echo 'j|jjjjjjjjjjjjjjjjjj|hello'
"                                 ^
"                                 ✔
"
" Emulate `zsh` behavior.
"
" Look for other mappings to implement, add them to a todo.
"
" 37 -
"
" Should we add `:noa` every time we use `:wincmd`?
"
"     :vim /wincmd p\|call win_gotoid/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"     :cfilter! -not_my_plugins
"     :cfilter! -not_relevant
"     :cfilter! \<noa\>
"
" Same question for `:[cl]open`, `:[cl]window`?
" Why this 2nd question?
" `noa` was  useful in  `vim-interactive-lists` to  prevent the  original window
" from being  minimized when  it's a  middle horizontal viewport  (2nd of  3 for
" example).
" The issue, if there's one, may be with `:l[open|window]` only.
"
" Update:
" Whenever you  need to *temporarily*  change the  focus to another  window, you
" should try to use `win_execute()` (Vim only for the moment).
"
" Changing the focused window can  lead to hard-to-debug issues, especially from
" an autocmd; `win_execute()` does not trigger autocmds when changing the focus.
" Also, it  preserves the previous window (`winnr('#')` and  `wincmd p` have the
" same result).
"
" 38 -
"
" Check that whenever we use `wincmd p` we get to the right window.
" Maybe we should use this instead:
"
"     let id = win_getid()
"     ...
"     call win_gotoid(id)
"
" 39 -
"
" Read:
" https://github.com/neovim/neovim/wiki/FAQ
" https://github.com/neovim/neovim/wiki/following-head (bookmark)
" https://neovim.io/doc/user/vim_diff.html#vim-differences
" `:h vim-differences` (in neovim) ... in particular to improve our options
" https://neovim.io/news/archive/
"
" 40 -
"
" Read:
" https://dev.to/idanarye/omnipytent-5g5l
" https://www.reddit.com/r/vim/comments/7kwlxc/omnipytent_plugin_explained/
" https://github.com/idanarye/vim-omnipytent
"
" 41 -
"
" Read:
" https://github.com/luchermitte/lh-vim-lib/blob/master/doc/oo.md
" (oop in viml)
"
" 42 -
"
" Use syntax hl in `vim-qf` instead of complex mechanism using matches.
" Also, in `vim-qf`, fix the fixme in the autocmd `my_qf`.
"
" Once done, try to use this mechanism for the issue we have in `s:ltag()`.
"
" 43 -
"
" Add syntax hl in toc menu, and make content more relevant in help toc.
"
" 44 -
"
" The toc  window may currently  be a little  too wide (see:  vim-qf, autoload/,
" `qf#open()`). We could  compute the longest line:
"
"     echo max(map(range(1, line('$')), {_,v -> virtcol([v, '$'])}))
"
" and set the width of the toc window dynamically.
"
" 45 -
"
" Move every function called from several scripts inside `vim-lg-lib`:
"
"     comment#object(
"     fold#md#sort#by_size(
"     fold#md#fde#stacked(
"     fold#md#fde#toggle(
"     fold#fdt#get(
"     qf#create_matches(
"     qf#set_matches(
"
" Also, make  sure they  are self-contained.
" They must not call  functions from one of our other  plugins.
" If they do, move the latter inside `vim-lg-lib` too.
"
" 46 -
"
" Implement a search ring, and install mappings to cycle through it
" useful to search for an old pattern without having to do `/ up ...`
" (; and ,  would be more comfy)
"
" 47 -
"
" When you create a loclist, replace the  old one if its title is `breakdown` or
" `fix_me & to_do`.
" Also, maybe create a mapping to show  the stack of location lists, and another
" to remove the current one.
"
" Also,  if you  execute  `:WTF` several  times consecutively,  `vim-stacktrace`
" keeps recreating and adding the  same qfl. It shouldn't. It should replace the
" old one, or better leave it alone.
" To do so, it should remember the last qfl it produced, or the last `:messages`
" it parsed, or any information sufficient to know that there's no need to
" recreate a qfl.
"
" 48 -
"
" Create a submode to insert numbers more easily.
"
" Ex:
"
"     ┌ enter “easy-number” submode
"     ├───┐
"     c-g n u  →  1
"           i  →  2
"           o  →  3
"           j  →  4
"           k  →  5
"           l  →  6
"           ,  →  7
"           ;  →  8
"           :  →  9
"           !  →  0
"
" Edit:
" Maybe a submode is not the right concept, because of the timeout.
" Maybe you should take inspiration from `vim-capslock`.
" Create a mapping, which would toggle temporary mappings.
"
"     ino <expr><silent> <c-g>n  <sid>easy_number()
"
"     fu s:easy_number() abort
"         if !empty(maparg('!', 'i'))
"             for key in ['!', 'u', 'i', 'o', 'j', 'k', 'l', ',', ';', ':']
"                 exe 'iunmap <buffer> '.key
"             endfor
"         else
"             let i = 0
"             for key in ['!', 'u', 'i', 'o', 'j', 'k', 'l', ',', ';', ':']
"                 exe 'ino  <buffer>  '.key.'  '.i
"                 let i += 1
"             endfor
"             au InsertLeave <buffer> ++once call s:easy_number()
"         endif
"         return ''
"     endfu
"
" 49 -
"
"     :h quickref
"     :h index
"
" Document these help tags somewhere in your notes.
" Explain when it's useful to refer to them.
"
" 50 -
"
" Prevent vim-session from checking swap files.
" Annoying when a session crashed, and we can't restore a session.
" Or disable swap files entirely:
"
"     set noswapfile
"
" Update:
" I don't think you should disable swap files.
"
" 51 -
"
" In  neovim there's  a plugin  to open  a file  from a  terminal buffer  in the
" current neovim instance. But what about vim?
"
" https://www.reddit.com/r/vim/comments/83ve6g/how_to_open_file_in_current_vim_instance_from/
" https://gist.github.com/andymass/bcd0a4956ed1a873d41f7265be6c6979
"
" Update:
" You could just install `:tno` mappings which open the file under the cursor in
" the current Vim instance.
" If the path is relative, you could inspect the prompt to extract the cwd.
" https://www.reddit.com/r/vim/comments/feod1s/tips_for_avoiding_nested_vim_sessions_when/
"
" 52 -
"
" Read:
"
"     :h popup.txt
"     :h sign.txt
"     :h textprop.txt
"                        in Nvim see `:h nvim_buf_add_highlight()`
"
"     :h channel.txt
"
"     :h tagsrch.txt
"
"     :h syntax.txt
"                      only 2400 lines once you remove part 4, and part 5: `:h syn-file-remarks`
"                      you're not supposed to read part 5 entirely anyway, only the tags
"                      relevant to the types of files you use frequently;
"                      to get a list:    :h ft-*-syn c-d
"
"     :h recover.txt
"     :h diff.txt
"     :h tips.txt
"
"     :h pattern.txt
"     :h indent.txt
"
"     :h terminal.txt
"     :h vim9-script
"
"     :h vim-differences
"                           (Nvim only)
"                           and all the links from this page, in particular `:h API`
"                           as well as: https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua
"     :h lsp.txt
"                   (Nvim only)
"
"     :h if_lua.txt (the interface may be phased out in the future)
"     :h if_pyth.txt (" https://groups.google.com/forum/#!topic/vim_dev/__gARXMigYE)
"
" Note that LSP is not a replacement for tags:
" https://www.reddit.com/r/vim/comments/fj9tsz/do_lsps_make_tag_generating_tools_obsolete/fkmna6k/
" https://www.reddit.com/r/vim/comments/fj9tsz/do_lsps_make_tag_generating_tools_obsolete/fkmvji3/
"
" 53 -
"
" In `~/wiki/vim/funcref.md`, look for the pattern `funcref(`.
" There are 2 codes side-by-side.
" They are separated with `┊` characters.
" If you press `+sip` on the code, only the one on the left is sourced.
"
" This is neat.
" Try to develop this mechanism.
" For example, we could have a mapping which toggles which part is sourced,
" the one on the left or the one on the right.
"
" Also, when we  source the code on the  right, in a line ending with  `┊ "`, we
" could make `vim-source` replace the double quote  with the code on the left of
" `┊`. This would allow us to use `"` instead of repeating a whole command.
"
"
" 54 -
"
" To document.
" If neovim is unable to suggest suggestions to fix spelling errors,
" start it like this:
"
"     $ nvim -Nu NORC
"
" Write a word with a spelling error:
"
"     helzo
"
" Then execute `:set spell`.
" It should make neovim download some missing files (I don't know where).
" For more info:
"
" https://github.com/neovim/neovim/issues/7694
" https://github.com/neovim/neovim/issues/7189
"
" Also, for debugging purpose, try `:spellinfo`.
"
" 55 -
"
" How to filter  a custom text-object without the command-line not being redrawn?
" MWE:
"
"     !iE SPC
"     ![m SPC
"     ...
"
" We could try sth like this:
"
"     ono <silent> ie :<c-u>exe 'norm vie'..(v:operator is# '!' ? '<space>' : '')<cr>
"
" But, why does the issue occur with `![m`, but not with `![z`?
"
" Update:
" It probably has sth to do with these functions:
"
"    - `s:jump()`    (✔)   ~/.vim/plugged/vim-fold/autoload/fold/motion.vim:101
"    - `s:jump()`    (✘)   ~/.vim/plugged/vim-brackets/autoload/brackets/move.vim:178
"
" Update:
" It has to do with the `<silent>` argument in the mapping.
" We need it in all modes except in operator-pending mode.
" Alternatively, we could include at the end of `s:jump()`:
"
"     exe 'norm! '..line('.')..'g'
"
" It would not make the cursor move, but it would make the command-line redrawn.
" MWE:
"
"     map <silent> ]g :call search('pat')<cr>
"         !]g → command-line not redrawn
"
"     map <silent> ]g :call search('pat') <bar> exe 'norm! '..line('.')..'g'<cr>
"         !]g → command-line redrawn
"
" It seems `vim-textobj-user` doesn't suffer from this issue:
"
"     " unmap pre-existing `o_ie` mapping
"     call textobj#user#plugin('entire_buffer', {
"     \   'code': {
"     \     'pattern': ['\%^.', '.\%$'],
"     \     'select-a': 'ae',
"     \     'select-i': 'ie',
"     \   },
"     \ })
"
" You  should  try   to  better  understand  this  issue   when  you  assimilate
" `vim-textobj-user`, and  fix it every  time you defined  a text object  in the
" past.
"
" 56 -
"
" Document `paste(1)` as a filter:
" https://vi.stackexchange.com/a/16096/17270
"
" Also, make some cleaning in our mappings:
"
"    - x_mJ      join two blocks
"    - x_m C-j   join two blocks in reverse order
"
" Are they consistent with other similar default commands (like `v_J` and `v_gJ`)?
" Could we make them easier to remember?
"
" 57 -
"
" Implement a mapping/command to extract the lines which are present in a block,
" but not in the other.
" `:InAButNotInB` is too cumbersome.
"
" 58 -
"
"     $ shell_cmd | vim +'setf dirvish' -
"
" `q` doesn't work and there's no conceal.
"
" Solution:
"
"     $ shell_cmd | vim +'call dirvish#open("")' -
"
"
" There's no `b:undo_ftplugin`: there should be.
"
" Update: too hard; it breaks the code (some autoloaded function
" needs `b:dirvish` for example)
"
"
" Use `cmdlineleave` instead of remapping `/` and `?`.
" This way the anchor at the end is never visible (noise, distracting).
" Hide it behind an option for a pr.
"
" Update:
" Two issues:
"
"    1. you can't prevent the initial search (the one without `\ze`)
"
"    2. you can't make the autocmd local to a buffer;
"    you can only inspect `get(b:, 'current_syntax', '')` and compare it to 'dirvish'
"    but the autocmd will still be global.
"
" 59 -
"
" Try to remove as many `virtcol()` as possible everywhere.
" Same thing for `\%v`; they don't mean what we thought.
"
" `virtcol('.')` and `\%v` take into account cells between the last character on
" a screen line of a long wrapped text line, and the first character of the next
" screen line (this includes 1 cell for the "virtual" newline).
" And so,  `virtcol()` and  `\%v` are  influenced by  `'wrap'` (and  all options
" related to the latter like `'linebreak'` and `'showbreak'`)
"
" Although, I  guess it's ok  to use  them when you're  sure your lines  are not
" wrapped.
"
" Update: Actually, I think it depends on how you use the info.
" If you use it with `:norm! 123|`, it should be ok.
"
" ---
"
" The same is true for `:norm! 123|`.
" We had an issue because of this in `readline#undo()`:
"
"     ~/.vim/plugged/vim-readline/autoload/readline.vim
"
" Even if  `123` is  correct (not  obtained by `virtcol('.')`,  but by  sth like
" `strchars(matchstr(line, pat))`), `:norm! 123|` may  still position the cursor
" unexpectedly on a long wrapped line.
"
" Solution: temporarily disable 'wrap'.
"
" Try to find other locations where we  have made a similar mistake; if you find
" anything, fix it.
"
" ---
"
" I think you can reliably save the cursor position with `virtcol()` and restore
" it with `:norm`, because both take into consideration virtual characters which
" are added when a long line gets wrapped;  they agree on what the position of a
" character is on a long wrapped line.
"
" See our comment in `vim#util#put()`:
"
"     ~/.vim/plugged/vim-vim/autoload/vim/util.vim
"
" 60 -
"
" Every time we populate a qfl from a script, we should save the command we used
" with the 'context' qf property.
" We could use it  to refresh a qfl, using a custom  mapping which would inspect
" the value of 'context'.
" The mapping would re-execute the command and  replace the old qfl with the new
" one.
"
" 61 -
"
" gf, c-w f, c-w gf should also be able to parse a column number.
" It would be useful in the qf window.
" See here for inspiration:
"
" https://github.com/wsdjeg/vim-fetch
"
" We could write a wrapper around these normal commands which would return
" the keys pressed, and start a timer which would execute `:norm` to position
" the cursor on the right column, if a column has been detected after the path.
"
" See also this:
"
" https://github.com/kana/vim-gf-user/blob/master/doc/gf-user.txt
"
" Also, they should be able to parse a reference link in a markdown buffer:
"
"     [description][123]
"     ...
"     [123]: link
"
" 62 -
"
" Finish implementing `!t` (timer info)
"
" Add syntax highlighting, additional info, mappings, ...
" also, create a mapping to interactively (un)pause/stop a timer.
"
" Also, do the same for matches (`getmatches()` + `matcharg()`).
" Use `! c-m` for the lhs of the mapping?
"          ^
"          getmatches
"
" Or, supercharge `!s`, so that when there's no syntax item under the cursor, it
" falls back on the matches.
" Also, do the same for these functions:
"
"     getbufinfo()		get a list with buffer information
"     gettabinfo()		get a list with tab page information
"     getwininfo()		get a list with window information
"     ch_info()                 get channel information (find the equivalent in neovim)
"     job_info()                get information about a job (find the equivalent in neovim)
"
" Btw:
" The 'lnum'  and 'windows' key in  the output of getbufinfo(...)[...]  are very
" interesting.
"
" Update:
" Maybe we should use `!i` as a prefix (i for **i**nfo).
"
"  - `!it` = timer
"  - `!ic` = channel
"  - ...
"
" 63 -
"
" Check which mappings could be supercharged using `v:count`:
"
"     nno  <silent>  cd  :<c-u>call func(v:count)<cr>
"     fu func(cnt) abort
"         echo a:cnt ? 'hello' : 'world'
"     endfu
"
" And check which mappings could benefit from being passed a count.
" see what we did with `!w` (:wtf), and `spc t` (:tabnew).
" Basically,  any  mapping which  calls  an  ex  command accepting  a  numerical
" argument, or a bang, could be passed the latter via `v:count`.
"
" 64 -
"
" Currently, `:FreeKeys` ignores free sequences beginning with `m`, `'` and `@`.
" This is because it thinks it would introduce a timeout with some of our custom
" mappings.
" In reality, there would no timeout, because `m`, `'` and `@` mappings are special:
" they ask for an argument.
" Check whether we have other similar special mappings causing `:freekeys` to ignore
" whole families of mappings:
"
"     verb filter /^.$/ map
"     g/last set from/d_
"     g/^<plug>/d_
"
" How to handle the issue?
" Either  tweak the  code  of `vim-freekeys`,  or take  the  habit of  executing
" `:freekeys -nomapcheck` (we've added a `-k` mapping for that).
"
" 65 -
"
" https://github.com/ardagnir/athame
" https://github.com/ardagnir/athame/issues/52
"
" > full vim for your shell (bash, zsh, gdb, python, etc)
"
" Could be used to expand ultisnips snippets in the shell.
"
" 66 -
"
" Extract the code dedicated to templates from `vim-unix`.
" Make it able to evaluate viml (i.e. dynamic templates).
"
" See here for inspiration:
" https://github.com/aperezdc/vim-template
"
" 67 -
"
" Rethink the `gt`/`gT` mappings.
" They could be better  used to move the current tabpage, instead  of `>t`, `<t`.
" But what would we use to populate the location list with to_do's and fix_me's?
"
" 68 -
"
" In python files, we  can use multi-line comments with a  pair of triple double
" quotes.
" But they aren't properly concealed in a fold title, nor in the unfolded buffer.
"
" Also, should we use them more often?
" Review the comments in `~/.vim/plugged/vim-snippets/pythonx/snippet_helpers.py:442`.
"
" Also, finish restructuring our notes in `vim-snippets`. Too many scattered files.
"
" Read:
" https://google.github.io/styleguide/pyguide.html?showone=comments#comments
" https://jeffknupp.com/blog/2016/12/09/how-python-linters-will-save-your-large-python-project/
"
" https://pylint.readthedocs.io/en/latest/
" https://pycodestyle.readthedocs.io/en/latest/
" http://www.pydocstyle.org/en/latest/
"
" Learn how to configure, use, integrate the following linters:
"
"    - pylint
"    - pycodestyle
"    - pydocstyle
"
" This command populates a default config file for `pylint`:
"
"     $ pylint --generate-rcfile >>~/.pylintrc
"
" 69 -
"
" We should use more abbreviations.
" Review the triggers:
"
"    - are they well chosen?
"    - should you remove some of them?
"    - should you add more?
"
"         use `:wordfrequency`, but if you find a frequent word (like 'result'),
"         it doesn't necessarily mean you should create an abbreviation just for
"         it;
"
"         maybe it's frequently  used in a group of words  (like 'as a result');
"         look for it  in your file, and  see in which context  it's used before
"         creating the abbreviation
"
" Maybe eliminate french.
" Move the functions in a dedicated file.
" Implement  a   `-A`  mapping   showing  the   available  abbreviations   in  a
" sidebar/cheatsheet. Show only the less well known at any given time.
"
" 70 -
"
" Try to make some existing mappings  smarter by reacting differently when we're
" at the more prompt (see `:h mode()`, `rm` mode).
"
" 71 -
"
" Should we  remap '@' so that  when we replay a  macro, the `esc` key  is never
" interpreted as a part of a function-like (f1, arrow, ...) key?
"
"     set noesckeys
"     @macro
"     set esckeys
"
" Pro:
" It would fix this kind of issue:
"
" https://vi.stackexchange.com/a/17193/17449
"
" Con:
" We would need to be sure that 'esckeys' is re-enabled.
" Also,  it would prevent  to use function-like keys  during the recording  of a
" macro.
"
" 72 -
"
" I think there's  no need to escape (so that the visual  marks are set) to know
" where the visual selection begins/ends.
" You can use `getpos('v')`, and `line('.')`:
"
"     xno <silent><expr> <c-a> Func()
"     fu Func() abort
"         let lnums = [getpos('v')[1], line('.')]
"         echom 'the visual selection starts at line '.min(lnums).' and ends at line '.max(lnums)
"         return ''
"     endfu
"
" Try to use this technique in your plugin(s) instead of escaping.
" Unless they really need to update the visual marks.
"
" See `:h col()` and `:h virtcol()`:
"
" > v       In Visual mode: the start of the Visual area (the
" >         cursor is the end).  When not in Visual mode
" >         returns the cursor position.  Differs from |'<| in
" >         that it's updated right away.
"
"     :vim /\m\C\\e/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"     :Cfilter! -other_plugins
"
" Note that the start of the  selection does not necessarily match the character
" which will be marked with `'<`; if you're controlling `'<`, then `getpos('v')`
" gives  the position  of  `'>`, and  vice versa;  if  you're controlling  `'>`,
" `getpos('v')` gives the position of `'<`.
"
" If you want  an expression which tells you whether  you're controlling the end
" of the selection:
"
"     line('.') > getpos('v')[1] || line('.') == getpos('v')[1] && col('.') >= getpos('v')[2]
"
" 73 -
"
" Search for `[ SPC`, `SPc ]`, `{ SPC`, `SPC }`, `^\s*\\` everywhere.
" Refactor the style.
"     noa vim /\[ \| \]\|{ \| }\|^\s*\\/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/** | cw
"
" 74 -
"
" Search for `g@` everywhere.
"
" Should we use `:keepj` in all our operators?
" See `myfuncs#op_replace_without_yank()`.
"
" It doesn't seem useful for the  jumplist (update: now it seems useful...), but
" it is for the changelist.
" It seems that if you use `:keepj`  for every edition performed in your opfunc,
" then no entry is added in the changelist.
" OTOH, if  you omit `:keepj` for  *any* edition performed by  your opfunc, then
" *one* entry is added in the changelist.
"
" tommy uses it here: https://vi.stackexchange.com/a/8748/17449
"
" ---
"
" Dirvish uses `keepj` for `tabnext` and `wincmd w`:
" https://github.com/justinmk/vim-dirvish/blob/fa6197150dbffe0f93028c46cd229bcca83105a9/autoload/dirvish.vim#L4
"
" Why?
" Should we do the same?
" Are there other commands for which we should have used `keepj` in the past?
"
" ---
"
" For  an operator  which can  be prefixed  by a  register, should  we save  and
" restore the register?
" If so,  consider passing the optional  argument `1` to `getreg()`  to properly
" restore the expression register.
" See `myfuncs#op_replace_without_yank()`.
"
" ---
"
" Do you need to save and restore `v:register` every time?
" Do you need to save and restore `v:count` every time?
"
" ---
"
" If the  operator yanks the text  on which we  operate, should it be  done with
" `:noa` to minimize unexpected side effects?
" E.g., I  think  it would  prevent  our  visual  ring  from saving  a  possible
" selection.
"
" ---
"
" Have you used `:s`, while you should have used `setline()`?
"
" ---
"
" Make sure to always save and restore visual marks.
" See what we  did with the function  called by the `dr` operator,  and read the
" comments.
"
" ---
"
" You should simplify the mappings, so that we call only one function,
" before pressing `g@`.
" The latter should save some info if needed, and set 'opfunc'.
"
" ---
"
" The repetition of an operation in visual mode is not consistent
" with what Vim does:
"
"    - press `~` on a visual selection
"    - move the cursor on another line
"    - press .
"
" Vim has recomputed a new visual selection with the same geometry
" as the previous one.
" That's not what your operators do.
" Study how  `vim-operator-user` solves this  issue (I think it  presses `gvg@`;
" IOW, `g@`  should be pressed  from visual mode for  the repetition to  work as
" expected).
"
" ---
"
" Our snippet  implementing an operator  is too long;  move it inside  a library
" function.
" The latter would contain the boilerplate code:
"
"     fu lg#my_opfunc(myfunc, type, ...) abort
"         let cb_save  = &cb
"         ...
"     endfu
"
" and it would expect the name of a custom function:
"
"     fu lg#my_opfunc(myfunc, type, ...) abort
"                     ^^^^^^
"
" The latter would be defined in the plugin where you need to implement your operator.
" It would contain the logic specific to the operator (i.e. not the boilerplate code).
" The library function would use this name to call `myfunc` (with `call()`).
"
" 75 -
"
" Eliminate `lg#reg#save()`, `lg#reg#restore()` whenever possible.
" We don't need to save/restore @+ anymore.
"
" 76 -
"
" Be  consistent  in  how  you  chose  the  priority  of  matches  created  with
" `matchadd()`.
"
" 77 -
"
" We have 4 plugins which use `repeat#set()`:
"
"     vim-abolish
"
"     vim-easy-align
"
"     vim-sneak
"
"     vim-speeddating
"
" Try to get rid of the call to the function, either by:
"
"    - submitting a bug report/PR
"    - re-implementing the plugin
"
" 78 -
"
" Every  time you open a  window, be aware that  an error may be  raised because
" you're in the command-line window.
" You may want to catch that error to avoid a stack trace.
"
" 79 -
"
" - remove `&l:` when it's not necessary?  (or the opposite: add it everywhere?)
" - use full name of commands and options?
" - switch from 4 spaces to 2 spaces for indentation?
"
" These are complex refactorings, because there will probably be a lot of matches.
" Try to write a custom command, which would refactor a script on-demand.
" Use it from time to time on a plugin you want to improve.
"
" But don't fuck up the alignment of our diagrams.
" So, before using your custom refactoring command, look for all the diagrams:
"
"     Vim /[─│]/j $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"
" And manually refactor everything you can around them.
" Then, you  should be able to  use your refactoring command  wherever you want,
" without breaking our diagrams.
"
" 80 -
"
" We often have errors when we import the contents of a file with `:r`,
" because the current buffer is not modifiable.
" Maybe we should always bail out in those cases...
"
" 81 -
"
"     % hash | vipe
"
"     press `gf` on a path
"     it takes several seconds, and the cpu load increases     ✘~
"
" The issue comes from 'set path=.,**' and from our current directory,
" when the latter has many subdirectories like `~`.
"
" MWE:
"
"     $ cd
"
"     $ vim -Nu NONE \
"       +'set path=.,**' \
"       +"set inex=substitute(v:fname,'.*=','','')" \
"       <(hash)
"
"     press `gf` on a path: it's slow
"
"     $ vim -Nu NONE \
"       +'cd ~/.vim/plugged/vim-awk' \
"       +'set path=.,**' \
"       +"set inex=substitute(v:fname,'.*=','','')" \
"       <(hash)
"     press `gf` on a path: it's quick
"
" We need to make `gf` smarter.
" When it sees a directory such as `~`, it should not search in it.
" Or, we should stop using such a broad 'path'... (vim-apathy to the rescue?)
"
" Update:
" Now we use a different value for 'path':
"
"     path=.,**5
"              ^
" This numeric prefix limits the depth of subdirectories in which Vim searches.
" It seems to help a lot in our previous MWE.
" Do we still have an issue? Or does the numeric prefix fix everything?
"
" 82 -
"
" The  `C-n` and  `C-p`  buffer-local  mappings installed  by  fugitive in  some
" buffers, conflict with our global mappings to cycle through tabpages.
" We're often distracted, because we wonder why our mappings are not working.
"
" 83 -
"
" Read:
"
" https://gist.github.com/yegappan/3b50ec9ea86ad4511d3a213ee39f1ee0
" > Updating a quickfix/location list asynchronously without interfering with another plugin
"
" Also, study these plugins:
"
" https://github.com/yegappan/asyncmake (125 sloc)
" https://github.com/chrisbra/vim-autoread (145)
" https://github.com/foxik/vim-makejob (197)
" https://github.com/prabirshrestha/async.vim (243)
" https://github.com/metakirby5/codi.vim (747)
"
" 84 -
"
" Supercharge `]e` and `[e` to move a fold when the cursor is on a line inside a
" closed fold.  Maybe do the same with `J` and `K` in visual mode.
"
" 85 -
"
" We don't version control our pdfs in `~/wiki`.
" Suppose one of our  notes has a link to a local pdf,  and we restore our notes
" on a new machine; the link will be broken.
" Improve `gx` so  that if it doesn't find  a pdf, it looks for  a `.tex` source
" code, compile it into a pdf, and open it.
" Also, make sure we do version control  the tex source code of all pdfs used in
" links.
"
" 86 -
"
" Study this (Neovim):
"
"     :h nvim_buf_set_virtual_text()
"
" Usage example:
"
"     :call nvim_buf_set_virtual_text(bufnr('%'), 0, line('w0')-1, [[repeat(' ',max([4,80-strdisplaywidth(getline(line('w0')))])).'Fancy Status', 'Error']],{})
"
" Source: https://vi.stackexchange.com/a/18729/17449
"
" More generally, try to study everything related to virtual text.
"
" 87 -
"
" Review how we set folding ('fde', 'fdt') in all our plugins.
" If it makes sense, try to move as much code as possible in `vim-fold`.
"
" 88 -
"
" `[ SPC`  and `] SPC`  are not reliable  when we're on  a line inside  a closed
" fold.
" Maybe  you should  use other  keys to  handle folds,  so that  you can  decide
" yourself if you want Vim to add an empty line or an empty fold.
" Currently, I don't think we have an easy algo to teach Vim how to decide itself.
"
" 89 -
"
" Watch these videos about using Vim as a diff tool, and as a merge tool:
" https://www.youtube.com/watch?v=zEah_HDpHzc
" https://www.youtube.com/watch?v=VxpCgQyUXlI
"
" 90 -
"
" Document the fact that  you need to put `<esc>` at the start  of the rhs of an
" `:ono` mapping if it presses `v:operator`.
"
" Watch this:
"
"     :ono ii :<c-u>exe 'normal! T'..nr2char(getchar())..v:operator..'t'..nr2char(getchar())<cr>
"
" Move your cursor on `bar`, then press `ciixy`:
"
"     foo x_bar_y baz
"     foo baz~
"
" Here, `ciixy` is equivalent to `c:norm! Txcty`.
"
" Now try this mapping:
"
"             vvvvv
"     :ono ii <esc>:<c-u>exe 'normal! T'..nr2char(getchar())..v:operator..'t'..nr2char(getchar())<cr>
"     foo x_bar_y baz
"     foo xy baz~
"
" The result is different.
"
" If you omit `<esc>` the result can even be wrong.
" Watch this:
"
"     :ono <expr> ii 'T'.nr2char(getchar()).v:operator.'t'.nr2char(getchar())
"     foo x_bar_y baz
"     foo xctyar_y baz~
"
"                     vvvvv
"     :ono <expr> ii '<esc>T'.nr2char(getchar()).v:operator.'t'.nr2char(getchar())
"     foo x_bar_y baz
"     foo xy baz~
"
" https://www.reddit.com/r/vim/comments/bo2o0b/text_object_that_is_delimited_by_two_distinct/end5png/
"
" 91 -
"
" We have too many comments in this file about the bracketed paste mode.
" Move all of that in a dedicated file (vim notes, terminal notes, ...).
" Also, document somewhere `:h vim.paste` (Nvim only):
"
" >     Extensibility: users can control paste behavior by redefining vim.paste (Lua)
"
" https://github.com/neovim/neovim/pull/4448
"
" 92 -
"
" In the  past, we have  had too many  issues by trying  to parse the  output of
" `execute('syn list ...')`, `execute('hi ...')`.
" Maybe we should ask for  some built-in functions (`getsynlist()`?, `gethi()`?)
" which would give this info in a nice dictionary.
"
" Also, `:verbose syn list ...` doesn't print the script location from which the
" syntax group was installed. Maybe ask for an improvement of `:verb`.
"
" 93 -
"
" *Maybe*, our notes about plugins should be in help files.
" If so, *maybe* they should support folding.
"
" Also, document somewhere, that when you  try to assimilate a plugin, the first
" thing to do is to refactor its documentation.
" Remove  any documentation  about a  feature you find  useless (and  remove the
" associated code).
" Make  the explanations clearer,  and add explanations or  questions/answers if
" needed.
" Once you  fully understand the doc,  and it only contains  useful information,
" you know the plugin's interface.
" And  once  the  interface  has  entered your  muscle  memory,  you  can  start
" refactoring the code.
"
" 94 -
"
" We really need a library function to get a comment leader.
"
"     if &ft is# 'markdown'
"         return ''
"     else
"         let cml = matchstr(&l:cms, '\S*\ze\s*%s')
"         return '\V'..escape(cml, '\')..'\m'
"     endif
"
" Vimgrep everywhere for `cml`.
"
" Update:
" We should probably define functions in our library (lg-lib), to:
"
"    - extract the comment leader
"    - detect whether a given line is commented
"    - return the commented version of a line (before pasting it somewhere)
"
" Update:
"
" I think we should not look at the comment leader to detect whether a line is commented.
" Instead, maybe we should just look at the syntax item at the end of the line:
"
"     :echo synIDattr(synIDtrans(synID(line("."), col("$")-1, 1)), "name")
"
" Source: https://vi.stackexchange.com/a/18992/17449
"
" ---
"
" We  also need  a  library function  to  get  a commented  shell  command in  a
" codeblock (and maybe in a codespan).
"
" It should support continuation lines (see how we did it in vim-tmux for `|x`).
" I don't know how easy it will be  to write, but I think the integration *will*
" be easy. A plugin invoking this library function should just receive a string,
" with no newline inside.
" This way, the existing code in our plugins should not need any modification.
"
" Once you have the library function, use it in:
"
"     ~/.vim/plugged/vim-doc/autoload/doc/mapping.vim
"     ~/.vim/plugged/vim-tmux/autoload/tmux/run.vim:36
"
" Also, we need a library function to install this kind of `q` mapping:
"
"     nno <buffer><expr><nowait><silent> q reg_recording() isnot# '' ? 'q' : ':<c-u>q!<cr>'
"
" 95 -
"
" We often make this error:
"
"     " insert this
"     getline()
"     " press M-b instead of C-b to get inside the parentheses
"
" What could be done to reduce the frequency of such errors?
"
" Idea: Every time you make such a mistake, undo, and re-insert `getline()` 3 times;
" each time make sure to press C-b.
"
" Other Idea: Make `M-b` inspect the 2 previous characters.
" If they are a pair of brackets, make it move the cursor as if `C-b` had been pressed.
"
" 96 -
"
" In a markdown file, `gc` should behave slightly differently.
" It  should  make sure  there  are  4 spaces  between  `>`  and the  first  non
" whitespace on each line; and reformat the quote with `par(1)`.
" Because that's what we do all the time; so better automate it.
"
" 97 -
"
" In a fugitive buffer, when we need to  stage many files, I would like to press
" `-` very fast. We can't because – for  some reason – it would trigger our `--`
" mapping which opens a dirvish buffer.
"
" 98 -
"
" We've just had an issue in `vim-search` because we used `==` instead of `==#`.
" Maybe we should write `==#` and `!=#` instead of `==` and `!=`.
" Or maybe we should just do it for comparisons where no operand is a number:
"
"     vim /=\@1<![!=]=[#?=]\@!\%(\s*-\=\d\+\)\@!/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"
" 99 -
"
" The  interface of  your plugins  and custom  config should  be simplified  and
" exposed; review every custom mapping/command.
"
" **simplified** = for any mapping/command you never use, do any of these:
"
"    - remove it
"    - change its name to make it easier to remember/find
"    - merge the feature it provides with another mapping/command
"
" **exposed** =  for any feature  provided by  a mapping/command whose  name you
" keep forgetting, do any of these:
"
"    - include it in a cheatsheet
"    - include it in a help command (e.g. `g?`, `:MyCmd -help`)
"
"        If the help of a command gets too big, you could spread it across
"        several pages, using a `-help {keyword}` argument.
"
" 100 -
"
" Should we add the guard `if $MYVIMRC is# '' | finish | endif` in all the files
" under `~/.vim/{after/}plugin`?
"
" ---
"
" Should we add the guard `if  !exists('b:did_ftplugin')` in all the files under
" `*/after/ftplugin/{&ft}.vim`?
" https://github.com/andymass/vim-matchup/commit/0b780e9ae12ba913742356f4b7cedc52d3a15220
"
" 101 -
"
" Document a few things about debugging with breakpoints.
"
" No need to type the whole name of a variable, just run `:echo a:`, `:echo w:`, ...
"
" No need to compute the line number where to put a breakpoint; by default, line
" number 1  is used; from there,  just run `>next`  or `>step` to step  into the
" code which follows.
"
" Don't think that you enter debugging mode just at the breakpoint; you can stay
" in debugging mode  as long as Vim  has to process commands,  provided that you
" don't run `>cont` or `>quit`; those 2  only stop at the next breakpoint, while
" all the other ones come back to debug mode for some other command.
"
" `>next` and `>step` are similar (but not identical)
" `>interrupt` and `>quit` are similar (but not identical)
"
" `>finish`  lets  Vim  process  all  the  remaining  commands  in  the  current
" script/function;  after that  it makes  Vim come  back to  debug mode  for the
" command B which follows  the command A (A being the  command which had sourced
" the script/run the function in the first place).
" IOW,   `>finish`  is   useful  when   you've  stepped   into  a   long  called
" function/sourced script,  and you don't  want to  inspect it anymore,  but you
" still want to debug the outer function/script.
"
" Use `>s` only when necessary (i.e. only  when you need to step into a function
" or a sourced file).
" Right after executing `>s`, do *not* use any of your readline mappings.
" You would step into a readline function, which would create noise.
" The effect is  cumulative: for each of your custom  readline mapping you press
" right after  executing `>s`, you'll add  a new frame onto  the stacktrace (you
" can see it with `>bt`); you would then  need to run `>f` to quit each readline
" frame.
"
" Use `>f` as a shortcut to reach the line where the code breaks.
" Use it as many  times as possible; the more commands you have  run so far, the
" harder  it will  be to  reach the  vicinity of  your current  location in  the
" execution path (and you'll need to reach it yet another time because debugging
" is often an iterative process).
" In particular, if your buggy line is  run by a function, called by a function,
" called by a function... it may be tricky to find in which function you need to
" add a breakpoint.
" Don't  try  to find  the  right  function, just  add  your  breakpoint in  the
" interface function. From there, inspect the value of some expression which you
" know will have – at some point – an unexpected value.
" Run `>f`, and inspect the same expression again; if the value is still the one
" you  expect, run  `>f` again;  if it's  not, you'll  know that  the issue  was
" somewhere in the previous function call.
" Repeat the process until the value is unexpected.
" Note somewhere  how many times  you had to  run `>f` – let's  call it N  – and
" restart a debugging session.
" Next, run `>f` (N-1) times, then run  `>n` as many times as possible until the
" value is unexpected.
" If the value  gets unexpected once you  reach a function call,  you'll need to
" step into it by running `>s`, then immediately run `>n` again.
" If you notice  that you've run `>n`  throughout the whole code  of a function,
" next time replace all the corresponding `n` with a single `f`.
" Build progressively the  shortest sequence of debugging  commands (`>f`, `>n`,
" `>s`) to reach the buggy line. Update the sequence somewhere in a scratch buffer.
"
" You don't  need to make  a script-local function  temporarily public to  add a
" breakpoint into it.
" Just run `:fu *function_name`, then press Tab.
" The `*`  wildcard should be expanded  into sth like `<snr>123_`;  this assumes
" that the  function already exists,  which may  not be the  case if it's  in an
" autoloaded directory (in which case, run  the interface of the plugin to force
" the sourcing of the autoloaded directory).
" Now you can run `:breakadd func <snr>123_function_name`.
"
" 102 -
"
" In xterm, we may now be able to use the alt modifier in mappings without nasty
" side effects:
"
" `:h modifyOtherKeys`
" https://github.com/vim/vim/issues/4974#issuecomment-541431801
"
" 103 -
"
" Vim saves anything typed on the  command-line, regardless of how we've left it
" (including when we've pressed `C-c` or `Esc`).
"
" To prevent this, you could install these mappings:
"
"              necessary in Vim to not break readline mappings on the command-line
"              vvvvv
"     cno <esc><esc> <c-e><c-u><c-c>
"     cno <c-c> <c-e><c-u><c-c>
"
" The  reason why  we use  `C-c`  instead of  `Esc`,  is because  on the  search
" command-line, pressing `Esc` would search the pattern:
"
"     $ vim -Nu NONE +'cno <esc> <esc>' ~/.zshrc
"     /the
"     " press Escape: the cursor jumps to the next occurrence of `the`
"
" 104 -
"
" Press `é`: it capitalizes the next word.
" Also, I don't know how, but we often capitalize a word by accident (in a different way).
" Change `M-i`?
" Or use xterm, which now supports  meta sequences OOTB, and doesn't suffer from
" these kind of issues.
"
" 105 -
"
" Replace a long `b:undo_ftplugin` with a simple function call:
"
"     /usr/local/share/vim/vim81/ftplugin/vim.vim:38
"     let b:undo_ftplugin = "call VimFtpluginUndo()"
"
" Inside the function, the code will be easier to read/maintain.
"
" Update: Done.
" Now make sure everything works as expected:
"
"    - no error when we reload a buffer
"    - settings are properly reset when we change the filetype
"    - function implementing the undo is in the right file
"
" 106 -
"
" Look for `:windo` and `:wincmd` everywhere.
"
"     :vim /\m\C\<\%(windo\|wincmd\)\>/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"
" Replace these commands with `lg#win_execute()` whenever possible.
" Once Nvim  supports `win_execute()`, remove  the `lg#` prefix in  the function
" calls.
"
" 107 -
"
" Review all the custom motions you've installed.
" For each  of them, make  sure you can  jump back with  `C-o` (set mark  `'` on
" original position).
"
" Actually, maybe not for all of them.
" Think about which motions should add an entry in the jumplist.
"
" 108 -
"
" Install a `=rm`  mapping in Vim files to refactor  nested function calls using
" the method call operator (`->`).
"
" 109 -
"
"     $ cd ; vim
"     :echo getcwd() → /home/user
"     " press `--`
"     :echo getcwd() → /home/user/.vim (why did the cwd change?)
"     " press `q`
"     " press `--`
"     " press `q`: why isn't the dirvish buffer unloaded?
"
" 110 -
"
" Review all custom text-objects: make sure  they all position the cursor on the
" end of  the selection, to  be consistent  with what Vim  seems to do  with its
" builtin text-objects (e.g. try `vi{` in a shell function).
"
" ---
"
" Also,  make sure  that they  correctly  handle a  `v`, `V`,  `C-v` prefix,  by
" inspecting the output of `mode(1)`:
" https://github.com/vim/vim/releases/tag/v8.1.0648
"
" I guess  that it  means that  all our text-objects  should be  implemented via
" `<expr>` mappings... Otherwise, the output of `mode(1)` is unreliable.
"
" 111 -
"
" Every time you've used sth like `norm! %` in the past, it was probably wrong.
" You should have used sth like:
"
"     call searchpair('(', '', ')', 'W', 'synIDattr(synID(line("."),col("."),1),"name") =~? "comment\\|string"')
"
" This is what the matchit plugin does, and it's more reliable.
" For example, position your cursor on the first open parenthesis on the following line:
"
"     if match(s:FUNCTION_NAMES, '^\V'..funcname..'\m\%((\|()\)') == -1
"             ^
"
" And run `:norm! %`: the cursor doesn't jump on the closing parenthesis.
" Now run `:call searchpair('(', ...)`: the cursor does jump on the closing parenthesis.
" Wrap this in a `lg#` function, and use it whenever you used `norm[!] %` in the past.
"
" Update:
" Actually, this is only an issue when you're dealing with code, not prose.
" In code, you may have an unbalanced closing brace inside a regex for example;
" it should be ignored, but `:norm! %` won't ignore it.
" Right  now, the  only places  where  that is  a  real issue  are in  `vim-vim`
" (`:RefHeredoc`, `:RefLambda`, `:RefMethod`).
"
" ---
"
" More generally, we often have issues with text-objects/motions related to braces.
" And we often have to perform refactorings in `vim-matchit`, which is a broken plugin.
" Enough is enough; we've removed `vim-matchit`, and installed `vim-matchup`.
" Read the documentation of the latter.
"
" 112 -
"
" Every time  we've "changed"  a buffer  in a way  that the  line count  did not
" change (`y` operator, `:y`, `:w`, `:update`,  ...), make sure we have used the
" `:lockmarks` modifier.
"
" In particular, it is useful to preserve the marks `'[` and `']`.
" This works since 8.1.2302:
" https://github.com/vim/vim/releases/tag/v8.1.2302
"
"     :vim /'\[\|'\]/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"           ^^^^^^^^
"           the pattern should look for more things (`:w` command, `:up` command, ...)
"
" ---
"
" Also, whenever we've used `:!`, maybe we should have used the `:keepmarks` modifier...
"
" 113 -
"
" When using the `gc` operator to comment  a line starting with a backslash in a
" Vimscript file, maybe we  should not add a space between  `"` and `\`, because
" we sometimes want to temporarily comment a continuation line.
"
" 114 -
"
" Tweak our `= SPC` mapping so that it comments the added lines when we are on a
" commented line.
"
" Update:
"
" I'm not sure this is a good idea anymore.
" What's the use case?
" If you still think it's useful, then add this:
"
"     if getline('.') =~# '^\s*"'
"         for offset in range(1, v:count1)
"             call setline(line('.')-offset, '"')
"             call setline(line('.')+offset, '"')
"         endfor
"     endif
"
" at the end of `brackets#put_lines_around()`:
"
"     " ~/.vim/plugged/vim-brackets/autoload/brackets.vim
"
" 115 -
"
" I'm fed up with codespans being broken when formatting with `gq`.
"
" Find a way to prevent `par(1)` from breaking a codespan on multiple lines.
"
" Idea: If you can't,  then maybe you could temporarily replace  all spaces in a
" codespan with  C-b; this should prevent  `par(1)` from breaking a  codespan on
" multiple lines. Then after the formatting, you would replace C-b with spaces.
"
" Also: Same issue with italics / bold style.
" Tweak syntax regexes?
"
" 116 -
"
" Integrate `~/Desktop/cwd.md` in our wiki notes.
"
" 117 -
"
" Remove all custom mappings/Ex commands you never use.
" They create "noise" which makes it harder to assimilate useful mappings/commands.
"
" 118 -
"
" Read:
" https://vimways.org/2019/indentation-without-dents/ (see `~/.vim/indent/[my]matlab.vim`, `~/Desktop/m.m`)
" https://vimways.org/2019/a-test-to-attest-to/
"
" 119 -
"
" Should we have passed the `z` flag to `search()` and `searchpos()` all the time?
" (to improve performance...)
"
" 120 -
"
" Try to use `readdir()` whenever you've used `glob*()` + `filter()/match()` in the past.
" Example:
"
"     if !empty(readdir(expand('%:p:h'), {n -> n =~# 'some_name'})) | do sth | endif
"
" Note that `readdir()` has not been ported to Nvim yet.
"
" 121 -
"
" Try to use `matchlist()` more often.
" In particular, whenever you've  used `matchstr()` several times consecutively,
" it may be an indication that `matchlist()` was better:
"
"     let text = 'hello world some text'
"     let foo = matchstr(text, '^\S\+')
"     let bar = matchstr(text, '^\S\+\s\+\zs\S\+')
"     ⇔
"     let text = 'hello world some text'
"     let [foo, bar] = matchlist(text, '^\(\S\+\)\s\+\(\S\+\)')[1:2]
"
" 122 -
"
" Once Nvim supports `SafeState`, try to replace as many timers as possible:
"
"     call timer_start(0, {-> ...})
"     →
"     au SafeState * ++once ...
"
" Should we though?
"
" I mean, sometimes it helps:
" https://vi.stackexchange.com/a/22414/17449
" *prevents flickering*
"
" and sometimes, it doesn't work and you really need a timer:
" https://github.com/vim/vim/issues/5243#issuecomment-555250613
"
" In general, it seems that `SafeState` executes a command earlier compared to a
" timer (that would explain the behaviors observed in the previous 2 links).
"
" Do we want a delayed command to be executed earlier?
" Naively, I would say yes. The longer a  command is delayed, the longer we stay
" in an undesirable state...
"
" 123 -
"
" We refer to dirvish in several locations in `vim-fex`.
" I don't like that.
" dirvish and fex are two different plugins.
"
" 124 -
"
"     $ vim
"     :h
"     C-k
"     qq
"     ll
"     C-j
"     ll
"     q
"     :reg q
"     c  "q   ll^@llq~
"                   ^
"                   ✘
"
" I think the issue is due to the existence of a custom mapping on `q`.
" When you press `q`, Vim probably detects that it's not the default `q` command
" which terminates a recording; so it records the keypress.
" It turns out that the mapping will – in the end – press the default `q` command.
"
" Solution:
"
" In `window#quit#main()`, replace this line:
"
"     if reg_recording() isnot# '' | return feedkeys('q', 'in')[-1] | endif
"
" with this block:
"
"     let regname = reg_recording()
"     if regname isnot# ''
"         call feedkeys('q', 'in')[-1]
"         call timer_start(0, {-> setreg(regname, substitute(getreg(regname), 'q$', '', ''), 'c')})
"         return ''
"     endif
"
" Should we wrap that in a `lg#` function and use it wherever we've used a local `q` mapping?
" Note that I don't think that a trailing  `q` has any effect in a recording; at
" least, it doesn't start a new recording.
" I  think  that the  special  meaning  of `q`  is  disabled  while replaying  a
" recording; maybe  because it would  cause an infinite recursion  when pressing
" `q` during a recording.
"
" 125 -
"
" Remove all invocations of `setenv()` and `getenv()`.
" Use global variables  instead; don't write them in uppercase  though; we don't
" want them to be saved/restored via viminfo.
"
" Document somewhere how `[gs]etenv()` can be used.
"
" 126 -
"
" Replace 0 and 1 with v:false, v:true whenever possible.
"
"     vim /\%(\%(^\s*"\|{{{\|}}}\).*\)\@<!\<[01]\>/gj  $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
"     Cfilter! -other_plugins
"     Cfilter! -tmp
"
" 127 -
"
" Assimilate the `s:sendtoclipboard()` function, and the `~/bin/sendtoclipboard` script.
    fu s:sendtoclipboard(text) abort
        " What's this `sendtoclipboard` ?{{{
        "
        " A custom script: `~/bin/sendtoclipboard`.
        " It writes the text in:
        "
        "    - a tmux buffer
        "    - the clipboard via `xsel(1x)` or `xclip(1)`
        "    - the clipboard via OSC 52
        "}}}
        sil let seq = system('sendtoclipboard', a:text)
        " Why this guard?{{{
        "
        " gVim doesn't seem to support OSC 52.
        "}}}
        "   Why don't you move it at the top?{{{
        "
        " In addition to producing an  OSC 52 sequence, `sendtoclipboard` copies the
        " text  in the  clipboard via  `xsel(1x)`; this  last feature  may still  be
        " useful in gVim.
        "}}}
        if has('gui_running') | return | endif
        if v:shell_error
            return lg#catch()
        else
            " TODO: Document why this line is needed.{{{
            "
            " Hint: It's only needed when you're working on a remote machine.
            "
            " If   you're   not   convinced,   comment  the   line,   and   in   the
            " `sendtoclipboard` script, comment the line invoking `xsel(1x)`.
            " Then, try to use this function: it will fail.
            " It should work  thanks to the OSC 52 sequence,  but it doesn't without
            " this `writefile()` line.
            " I think  that's because the script  is called via `system()`  and thus
            " has no controlling terminal; so the sequence is written nowhere.
            "}}}
            call writefile([seq], '/dev/tty', 'b')
        endif
    endfu
    nno <silent> <space>y y:<c-u>call <sid>sendtoclipboard(@0)<cr>
"
" 128 -
"
" Write a refactoring command to convert a dictionary into its literal form:
"
"     {'a': 1, 'b': 'string'}
"     →
"     #{a: 1, b: 'string'}
"
" Idea:
" Inside the dictionary, iterate over all the colons which are outside a string.
" For each  of them, look  back for a string  (only whitespace can  separate the
" string from the colon); if you find such a string, press `sd'`.
"
" Warning: Read `:h literal-Dict`.
" The `#{}` notation limit the characters which can be used in a key name.
" Take that into consideration when writing your refactoring command.
" That is,  if some key contains  characters which are invalid  in `#{}`, cancel
" the whole refactoring.
"
" 129 -
"
" Create a command to cycle between different buffer states.
" E.g.:
"
"    1. press some custom mapping to remember the current state (`:echo undotree().seq_cur`)
"
"    2. edit the buffer
"
"    3. press some custom mapping to get back to the original remembered state;
"       before that, remember the new current state to be able to cycle between the 2 states
"
" This would  be useful when  we bisect the  code in some  file, and we  need to
" temporarily remove a lot of code.
"
" Update: A command would be better.
"
"     " add current undo seq to a dictionary (key = undo seq, value = description of the buffer state)
"     " save the info in a file
"     :UndoSeq -save 'some description'
"
"     " removes undo seq 123 from the dictionary
"     :UndoSeq -del 123
"
"     " removes the file where the info contained in the dictionary is saved
"     :UndoSeq -del
"
"     " load list of undo seq into location window
"     " pressing Enter on an entry runs `:undo 123` in the associated buffer
"     :UndoSeq




" sessions to finish:
"
"    1.  sandwich
"    2.  ultisnips
"    3.  markdown
"    4.  tag
"    5.  arglist (improve our arglist mappings)
"    6.  breakdown
"    7.  paragraph (master `par(1)`)
"    8.  tree
"    9.  keyboard
"    10. systemd
"    11. cron
"    12. swap
"    13. emmet
"    14. config
"    15. qf_issue (finish the last two questions)
"    16. completion
"    17. profiling
"    18. debug
"    19. try
"    20. async
"    21. unix
"    22. package
"
" Once finished, get back to studying the terminal and latex.

