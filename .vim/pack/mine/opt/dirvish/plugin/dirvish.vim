vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/dirvish.vim'

command -bar -nargs=? -complete=dir Dirvish dirvish.Open(<q-args>)
command -nargs=* -complete=file -range -bang Shdo dirvish.Shdo(<bang>0 ? argv() : getline(<line1>, <line2>), <q-args>)

augroup dirvish
  autocmd!
  # remove netrw directory handlers
  autocmd VimEnter * if exists('#FileExplorer') | execute 'autocmd! FileExplorer *' | endif
  autocmd BufEnter * {
    if !exists('b:dirvish') && expand('%:p')->isdirectory()
      execute 'Dirvish %:p'
    elseif exists('b:dirvish') && &buflisted && bufnr('$') > 1
      setlocal nobuflisted
    endif
  }

  # Might be useful to look for a pattern in all the files which we're currently
  # looking at in the file explorer.
  # TODO: Check whether it helps reducing our bad habit of pressing `got`.{{{
  #
  # I want to stop shelling out just to grep a pattern.
  # Instead, we should use a `:vimgrep` command right from the current Vim instance.
  # If  this autocmd  doesn't help,  what command/feature  are we  missing which
  # leads us to leave Vim?
  #}}}
  autocmd FileType dirvish lcd %

  autocmd ShellCmdPost * if exists('b:dirvish') | execute 'Dirvish %' | endif
augroup END

nnoremap <Plug>(dirvish_split_up) <ScriptCmd>execute 'split +Dirvish\ %:p' .. repeat(':h', v:count1)<CR>
nnoremap <Plug>(dirvish_vsplit_up) <ScriptCmd>execute 'vsplit +Dirvish\ %:p' .. repeat(':h', v:count1)<CR>

highlight default link DirvishSuffix   SpecialKey
highlight default link DirvishPathTail Directory
highlight default link DirvishArg      Todo
