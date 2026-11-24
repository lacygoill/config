vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

if !executable('fzf')
    # The timer makes sure that the  message does not cause a hit-enter prompt
    # before Vim has  drawn its UI.  A `VimEnter` autocmd  would work too, but
    # then  the  message  would  not  be visible  at  all  (until  we  execute
    # `:messages`).  If you  try to refactor this, test your  code when Vim is
    # used in a shell pipeline (e.g. `$ ls | vim -`).
    timer_start(0, (_) => {
        echohl ErrorMsg
        echomsg 'fz.vim: missing dependency: fzf(1)'
        echohl NONE
    })
    finish
endif

import autoload '../autoload/fz.vim'
import autoload '../autoload/fz/cheat.vim'
import autoload '../autoload/fz/config.vim'
import autoload '../autoload/fz/entries.vim'
import autoload '../autoload/fz/ex.vim'
import autoload '../autoload/fz/find.vim'
import autoload '../autoload/fz/help.vim'
import autoload '../autoload/fz/histget.vim'
import autoload '../autoload/fz/links.vim'
import autoload '../autoload/fz/locate.vim'
import autoload '../autoload/fz/mappings.vim'
import autoload '../autoload/fz/notes.vim'
import autoload '../autoload/fz/recent.vim'
import autoload '../autoload/fz/registers.vim'
import autoload '../autoload/fz/snippets.vim'

# TODO: Implement:
#
#    - `:FzBuffers`; open buffers
#    - `:FzWindows`; open windows
#
#    - `:FzTags`; tags in the project
#    - `:FzBTags`; tags in the current buffer
#
#    - `:FzCommits`; git commits
#    - `:FzBCommits`; git commits for the current buffer
#
#    - `:FzGGrep`; `$ git grep`
#    - `:FzGFiles?`; git files; `$ git status --short`
#    - `:FzGFiles`; git files; `$ git ls-files`

# TODO: Should we use `delta(1)`  for `:FzCommits`, `:FzBCommits`, `FzGFiles?`
# to format git's output?  If interested, see how `fzf.vim` does it.

# Autocmds {{{1

augroup FzfMappings
    autocmd!

    # We could have a mapping which creates a timeout when we press `C-s`, `C-v`, ...{{{
    #
    # For example:
    #
    #     tnoremap <C-S><C-W> <C-S><C-W>
    #}}}
    autocmd FileType fzf tnoremap <buffer><nowait> <C-S> <C-S>
    autocmd FileType fzf tnoremap <buffer><nowait> <C-V> <C-V>
    autocmd FileType fzf tnoremap <buffer><nowait> <C-T> <C-T>
    autocmd FileType fzf tnoremap <buffer><nowait> <C-Q> <C-Q>

    # We can't use `C-w` to delete the previous word because of `'termwinkey'`.
    # Let's fix that.
    autocmd FileType fzf &l:termwinkey = '<C-@>'
        | tnoremap <buffer><nowait> <C-W> <C-W>
augroup END

augroup FzfOpenFolds
    autocmd!
    autocmd FileType fzf autocmd BufWinEnter * ++once timer_start(0, (_) => execute('normal! zv'))
augroup END

# Problem: A  recently  read  file  is often  missing  from  `recent.Files()`,
# because it  doesn't contain any  mark saved  in `~/.viminfo`, and  thus it's
# missing from `v:oldfiles`.
#
# Solution: Save all read files in a dedicated file.
augroup SaveOldFiles
    autocmd!
    autocmd VimLeave * {
        # If we didn't call  `recent.Files()` during the session, `recent.vim`
        # has not been  sourced.  In that case,  calling `SaveOldFiles()` will
        # source  `recent.vim` which  increases Vim's  quitting time  by about
        # 50ms.   That's OK  for our  main Vim  instance, but  not if  Vim was
        # invoked  by another  process, or  used in  a pipeline,  or if  we're
        # measuring its startup time (with `--startuptime +'quitall!'`).
        if v:this_session != ''
            recent.SaveOldFiles()
        endif
    }
augroup END

# Commands {{{1
# Don't use `-bar` for commands whose argument might contain `"` or `|`.

command -nargs=* -complete=dir FZ find.Files(<f-args>)

# Tip: To list every file on the system, run `:FzLocate /`.
# How is `:FzLocate` useful compared to `FZ`?{{{
#
# `locate(1)` is much faster than `find(1)`.
# And it can find *all* the files, not just the ones in the CWD.
#}}}
command -nargs=1 FzLocate locate.Files(<q-args>)

# Mappings {{{1

nnoremap <unique> <Space>f/ <ScriptCmd>histget.Fz()<CR>
nnoremap <unique> <Space>fc <ScriptCmd>ex.Commands()<CR>
nnoremap <unique> <Space>fC <ScriptCmd>config.Files()<CR>
nnoremap <unique> <Space>fe <ScriptCmd>entries.Fz()<CR>
nnoremap <unique> <Space>ff <ScriptCmd>FZ<CR>
nnoremap <unique> <Space>fh <ScriptCmd>help.Tags()<CR>
nnoremap <unique> <Space>fk <ScriptCmd>cheat.Fz()<CR>
nnoremap <unique> <Space>fl <ScriptCmd>FzLocate /<CR>
nnoremap <unique> <Space>fN <ScriptCmd>notes.Fz(true)<CR>
nnoremap <unique> <Space>fn <ScriptCmd>notes.Fz()<CR>
nnoremap <unique> <Space>fr <ScriptCmd>recent.Files()<CR>

# Tip: If your query matches  on the far right, the LHS  might not be visible.
# In  that case,  press `M-p`  to  open the  preview window;  the latter  will
# display the mapping from its start.
nnoremap <unique> <Space>fmc <ScriptCmd>mappings.Fz('c')<CR>
nnoremap <unique> <Space>fmi <ScriptCmd>mappings.Fz('i')<CR>
nnoremap <unique> <Space>fmn <ScriptCmd>mappings.Fz('n')<CR>
nnoremap <unique> <Space>fmo <ScriptCmd>mappings.Fz('o')<CR>
nnoremap <unique> <Space>fmx <ScriptCmd>mappings.Fz('x')<CR>
# don't press `fm` (search for next `m` character) if we cancel `SPC fm`
nnoremap <Space>fm<Esc> <Nop>

inoremap <unique> <C-G><C-G> <ScriptCmd>snippets.Fz()<CR>
nnoremap <unique> <C-G><C-L> <ScriptCmd>links.Fz()<CR>

nnoremap <unique> "<C-F> <ScriptCmd>registers.Fz()<CR>
inoremap <unique> <C-R><C-F> <ScriptCmd>registers.Fz()<CR>
