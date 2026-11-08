vim9script

var srcdir: string = expand('<sfile>:h:h:p')
var mods: string = 'silent noautocmd keepjumps'
var cb_map: dict<func(string): string>

export def ForceAutoload()
enddef

def MsgError(msg: string)
  redraw
  echohl ErrorMsg
  echomsg 'dirvish: ' .. msg
  echohl None
enddef

def Suf(): bool
  var m: any = get(g:, 'dirvish_mode', 1)
  return m->typename() == 'number' && m <= 1
enddef

def NormalizeDir(adir: string, silent: bool): string
  var dir: string = adir
  if !isdirectory(dir)
    if !silent
      MsgError('invalid directory: ' .. adir->string())
    endif
    return ''
  endif
  # Collapse slashes (except UNC-style \\foo\bar).
  dir = dir[0] .. substitute(dir[1 :], '/\+', '/', 'g')
  # Always end with separator.
  return (dir[-1 :] == '/') ? dir : dir .. '/'
enddef

def ParentDir(dir: string): string
  var mod: string = isdirectory(dir) ? ':p:h:h' : ':p:h'
  return fnamemodify(dir, mod)->NormalizeDir(false)
enddef

def Globlist(dir_esc: string, pat: string): list<string>
  return globpath(dir_esc, pat, !Suf(), true)
enddef

def ListDir(dir: string): list<string>
  # Escape for globpath().
  var dir_esc: string = dir
    ->substitute('\[', '[[]', 'g')
    ->escape(',;*?{}^$\')
  var paths: list<string> = dir_esc->Globlist('*')
    # Append dot-prefixed files. globpath() cannot do both in 1 pass.
    + Globlist(dir_esc, '.[^.]*')

  if get(g:, 'dirvish_relative_paths', false)
      && dir != getcwd()->ParentDir() # avoid blank CWD
    return paths->map((_, v: string) => fnamemodify(v, ':p:.'))
  endif
  return paths->map((_, v: string) => fnamemodify(v, ':p'))
enddef

def Info(paths: list<string>, dirsize: bool)
  for f: string in paths
    # Slash decides how getftype() classifies directory symlinks. #138
    var noslash: string = substitute(f, '/$', '', 'g')
    var fname: string = len(paths) < 2
      ? ''
      : substitute(f, '[\\/]\+$', '', '')->fnamemodify(':t')->printf('%12.12s ')
    silent var size = -1 != getfsize(f) && dirsize
      ? system('du -hs ' .. shellescape(f))->matchstr('\S\+')
      : printf('%.2f', getfsize(f) / 1000.0) .. 'K'
    echo -1 == getfsize(f)
      ? '?'
      : (fname .. (getftype(noslash)[0]) .. ' ' .. getfperm(f)
          .. ' ' .. strftime('%Y-%m-%d.%H:%M:%S', getftime(f))
          .. ' ' .. size)
          .. ('link' != getftype(noslash) ? '' : ' -> ' .. resolve(f)->fnamemodify(':~:.'))
  endfor
enddef

def SetArgs(args: list<string>)
  if arglistid() == 0
    arglocal
  endif
  var normalized_argv: list<string> = argv()->map((_, v: string) => fnamemodify(v, ':p'))
  for f: string in args
    var i: number = normalized_argv->index(f)
    if -1 == i
      execute ':$ argadd ' .. fnamemodify(f, ':p')->fnameescape()
    elseif 1 == len(args)
      execute ':' .. (i + 1) .. 'argdelete'
      syntax clear DirvishArg
    endif
  endfor
  echo 'arglist: ' .. argc() .. ' files'

  # Define (again) DirvishArg syntax group.
  execute 'source ' .. fnameescape(srcdir .. '/syntax/dirvish.vim')
enddef

export def Shdo(paths: list<string>, acmd: string)
  # Remove empty/duplicate lines.
  var lines: list<string> = paths
    ->copy()
    ->filter((_, v: string): bool => -1 != v->match('\S'))
    ->sort()
    ->uniq()
  var head: string = get(lines, 0, '')[: -2]->fnamemodify(':h')
  var jagged: bool = 0 != lines
    ->copy()
    ->filter((_, v: string): bool => head != v[: -2]->fnamemodify(':h'))
    ->len()
  if empty(lines)
    MsgError('Shdo: no files')
    return
  endif

  var dirvish_bufnr: number = bufnr('%')
  var cmd: string = acmd =~ '\V{}' ? acmd : (empty(acmd) ? '{}' : (acmd .. ' {}'))
  # Paths from argv() or non-dirvish buffers may be jagged; assume CWD then.
  var dir: string = !jagged && exists('b:dirvish') ? b:dirvish._dir : getcwd()
  var tmp_file: string = tempname() .. '.sh'

  for i: number in range(0, len(lines) - 1)
    var f: string = lines[i]->trim('/', 2)
    if !filereadable(f) && !isdirectory(f)
      lines[i] = '#invalid path: ' .. shellescape(f)
      continue
    endif
    f = !jagged ? fnamemodify(f, ':t') : lines[i]
    lines[i] = cmd->substitute('\V{}', shellescape(f)->escape('&\'), 'g')
  endfor
  execute 'silent split ' .. tmp_file .. ' | lcd ' .. dir->fnameescape()
  setlocal bufhidden=wipe
  silent keepmarks keepjumps setline(1, lines)
  silent write
  silent system('chmod u+x ' .. tmp_file)
  silent edit

  augroup dirvish_shcmd
    autocmd! * <buffer>
    # Refresh Dirvish after executing a shell command.
    execute 'autocmd ShellCmdPost <buffer> ++nested if !v:shell_error && bufexists(' .. dirvish_bufnr .. ')'
      .. ' | setlocal bufhidden=hide | buffer ' .. dirvish_bufnr .. ' | silent! Dirvish %'
      .. ' | buffer ' .. bufnr('%') .. ' | setlocal bufhidden=wipe | endif'
  augroup END

  nnoremap <buffer> Z! <ScriptCmd>silent write
    \ <Bar> execute '!' .. (split(&shell)->map((_, v) => shellescape(v, true))->join() .. ' %')
    \ <Bar> if !v:shell_error <Bar> close <Bar> endif<CR>
enddef

# Returns true if the buffer was modified by the user.
def BufModified(): bool
  return b:changedtick > get(b:dirvish, '_c', b:changedtick)
enddef

def BufInit()
  augroup dirvish_buflocal
    autocmd! * <buffer>
    autocmd BufEnter,WinEnter <buffer> OnBufenter()
    autocmd TextChanged,TextChangedI <buffer> {
      if BufModified()
        setlocal conceallevel=0
      endif
    }

    # BufUnload is fired for :bwipeout/:bdelete/:bunload, _even_ if
    # 'nobuflisted'. BufDelete is _not_ fired if 'nobuflisted'.
    # NOTE: For 'nohidden' we cannot reliably handle :bdelete like this.
    if &hidden
      autocmd BufUnload <buffer> OnBufunload()
    endif
  augroup END

  setlocal buftype=nofile noswapfile
enddef

def OnBufenter()
  if bufname('%') == ''  # Something is very wrong. #136
    return
  endif
  if !exists('b:dirvish') || (getline(1)->empty() && 1 == line('$'))
    Dirvish %
  elseif 3 != &l:conceallevel && !BufModified()
    WinInit()
  else
    # Ensure w:dirvish for window splits, `:b <nr>`, etc.
    w:dirvish = get(w:, 'dirvish', {})->extend(b:dirvish, 'keep')
  endif
enddef

def SaveState(d: dict<any>)
  # Remember previous ('original') buffer.
  d.prevbuf = BufIsvalid(bufnr('%')) || !exists('w:dirvish')
        ? bufnr('%') : w:dirvish.prevbuf
  if !BufIsvalid(d.prevbuf)
    # If reached via :edit/:buffer/etc. we cannot get the (former) altbuf.
    d.prevbuf = exists('b:dirvish') && BufIsvalid(b:dirvish.prevbuf)
        ? b:dirvish.prevbuf : bufnr('#')
  endif

  # Remember alternate buffer.
  d.altbuf = BufIsvalid(bufnr('#')) || !exists('w:dirvish')
        ? bufnr('#') : w:dirvish.altbuf
  if exists('b:dirvish') && (d.altbuf == d.prevbuf || !BufIsvalid(d.altbuf))
    d.altbuf = b:dirvish.altbuf
  endif

  # Save window-local settings.
  w:dirvish = extend(get(w:, 'dirvish', {}), d, 'force')
  [w:dirvish._w_wrap, w:dirvish._w_cul] = [&l:wrap, &l:cul]
  if !exists('b:dirvish')
    [w:dirvish._w_cocu, w:dirvish._w_cole] = [&l:concealcursor, &l:conceallevel]
  endif
enddef

def WinInit()
  w:dirvish = get(w:, 'dirvish', {})->extend(b:dirvish, 'keep')
  setlocal nowrap cursorline
  setlocal concealcursor=nvc conceallevel=2
enddef

def OnBufunload()
  RestoreWinlocalSettings()
enddef

def BufClose()
  var d: dict<any> = get(w:, 'dirvish', {})
  if empty(d)
    return
  endif

  var altbuf: number = get(d, 'altbuf', 0)
  var prevbuf: number = get(d, 'prevbuf', 0)
  var found_alt: bool = TryVisit(altbuf, true)
  if !TryVisit(prevbuf, false) && !found_alt
      && (1 == bufnr('%') || (prevbuf != bufnr('%') && altbuf != bufnr('%')))
    bdelete
  endif
enddef

def RestoreWinlocalSettings()
  if !exists('w:dirvish') # can happen during VimLeave, etc.
    return
  endif
  if has_key(w:dirvish, '_w_cocu')
    [&l:cocu, &l:cole] = [w:dirvish._w_cocu, w:dirvish._w_cole]
  endif
enddef

def OpenSelected(
  splitcmd: string,
  bg: bool,
  line1: number,
  line2: number
)

  var curbuf: number = bufnr('%')
  var curtab: number = tabpagenr()
  var curwin: number = winnr()
  var wincount: number = winnr('$')
  var p: bool = splitcmd == 'p'  # Preview-mode

  var paths: list<string> = getline(line1, line2)
  for path: string in paths
    if !isdirectory(path) && !filereadable(path)
      MsgError('invalid (access denied?): ' .. path)
      continue
    endif

    if p # Go to previous window.
      if winnr('$') > 1
        execute 'wincmd p | if winnr() == ' .. winnr() .. ' | wincmd w | endif'
      else
        vsplit
      endif
    endif

    if isdirectory(path)
      execute (p || splitcmd == 'edit' ? '' : splitcmd .. ' | ') .. 'Dirvish ' .. fnameescape(path)
    else
      execute (p ? 'edit' : splitcmd) .. ' ' .. fnameescape(path)
    endif

    # Return to previous window after _each_ split, else we get lost.
    if bg && (p || (splitcmd =~ 'sp' && winnr('$') > wincount))
      wincmd p
    endif
  endfor

  if bg # return to dirvish buffer
    if splitcmd == 'tabedit'
      execute 'tabnext ' .. curtab .. ' | :' .. curwin .. 'wincmd w'
    elseif splitcmd == 'edit'
      execute 'silent keepalt keepjumps buffer ' .. curbuf
    endif
  elseif !exists('b:dirvish') && exists('w:dirvish')
    SetAltbuf(w:dirvish.prevbuf)
  endif
enddef

def IsValidAltbuf(bnr: number): bool
  return bnr != bufnr('%') && bufexists(bnr) && getbufvar(bnr, 'dirvish')->empty()
enddef

def SetAltbuf(bnr: number)
  if !IsValidAltbuf(bnr)
    return
  endif
  @# = bnr
enddef

def TryVisit(bnr: number, bnoau: bool): bool
  if IsValidAltbuf(bnr)
    # If *previous* buffer is *not* loaded (because of 'nohidden'), we must
    # allow autocmds (else no syntax highlighting; #13).
    var noau: string = bnoau && bufloaded(bnr) ? 'noau' : ''
    execute 'silent keepjumps ' .. noau .. ' noswapfile buffer ' .. bnr
    return true
  endif
  return false
enddef

# Performs `cmd` in all windows showing `bname`.
def BufwinDo(cmd: string, bname: string)
  getwininfo()
    ->filter((_, v: dict<any>): bool => bname == bufname(v.bufnr))
    ->map((_, v: dict<any>) => win_execute(v.winid, mods .. ' ' .. cmd))
enddef

def BufRender(dir: string, lastpath: string)
  var bname: string = bufname('%')
  var isnew: bool = getline(1)->empty()

  if !isdirectory(bname)
    echoerr 'dirvish: fatal: buffer name is not a directory: ' .. bufname('%')
    return
  endif

  if !isnew
    BufwinDo('w:dirvish["_view"] = winsaveview()', bname)
  endif

  setlocal undolevels=-1
  silent keepmarks keepjumps :% delete _
  silent keepmarks keepjumps ListDir(dir)->setline(1)
  if get(g:, 'dirvish_mode')->typename() == 'string'  # Apply user's filter.
    execute get(g:, 'dirvish_mode')
  endif
  setlocal undolevels<

  if !isnew
    BufwinDo('w:dirvish["_view"]->winrestview()', bname)
  endif

  if !empty(lastpath)
    var pat: string = get(g:, 'dirvish_relative_paths', false)
      ? fnamemodify(lastpath, ':p:.')
      : lastpath
    pat = empty(pat) ? lastpath : pat # no longer in CWD
    search('\V\^' .. escape(pat, '\') .. '\$', 'cw')
  endif
  # Place cursor on the tail (last path segment).
  search('\/\zs[^\/]\+\/\?$', 'c', line('.'))
enddef

def ApplyIcons()
  if 0 == len(cb_map)
    return
  endif
  highlight clear Conceal
  for f: string in getline(1, '$')
    var icon: string
    for id: string in keys(cb_map)->sort()
      icon = cb_map[id](f)
      if -1 != icon->match('\S')
        break
      endif
    endfor
    var ff: string = f
    if icon != ''
      var isdir: bool = f[-1 :] == '/'
      ff = f
        ->fnamemodify(':p')
        ->substitute('/$', '', 'g')  # Full path, trim slash.
      var head_esc: string = escape(fnamemodify(ff, ':h') .. (fnamemodify(ff, ':h') == '/' ? '' : '/'), '[,*.^$~\')
      var tail_esc: string = escape(fnamemodify(ff, ':t') .. (isdir ? '/' : ''), '[,*.^$~\')
      execute 'syntax match DirvishColumnHead =^' .. head_esc .. '\ze' .. tail_esc .. '$= conceal cchar=' .. icon
    endif
  endfor
enddef

def OpenDir(d: dict<any>, reload: bool)
  var dirname_without_sep: string = d._dir->substitute('[\\/]\+$', '', 'g')

  # Vim tends to 'simplify' buffer names. Examples (gvim 7.4.618):
  #     ~\foo\, ~\foo, foo\, foo
  # Try to find an existing buffer before creating a new one.
  var bnr: number = -1
  for pat: string in ['', ':~:.', ':~']
    var dir: string = fnamemodify(d._dir, pat)
    if dir == ''
      continue
    endif
    try
      bnr = bufnr('^' .. dir .. '$')
    # an error is given if `'debug'` is set to 'throw'
    catch /^Vim\%((\a\+)\)\=:E94:/
    endtry
    if -1 != bnr
      break
    endif
  endfor

  if -1 == bnr
    execute 'silent noswapfile keepalt edit ' .. fnameescape(d._dir)
  else
    execute 'silent noswapfile buffer ' .. bnr
  endif

  # Use :file to force a normalized path.
  # - Avoids `.././..`, `.`, `./`, etc. (breaks %:p, not updated on :cd).
  # - Avoids [Scratch] in some cases (`:e ~/` on Windows).
  if bufname('%') != d._dir
    execute 'silent noswapfile file ' .. fnameescape(d._dir)
  endif

  if !bufname('%')->isdirectory()  # sanity check
    throw 'invalid directory: ' .. bufname('%')
  endif

  if &buflisted && bufnr('$') > 1
    setlocal nobuflisted
  endif

  SetAltbuf(d.prevbuf) # in case of :bd, :read#, etc.

  b:dirvish = exists('b:dirvish') ? extend(b:dirvish, d, 'force') : d

  BufInit()
  WinInit()
  if reload || ShouldReload()
    BufRender(b:dirvish._dir, get(b:dirvish, 'lastpath', ''))
    # Set up Dirvish before any other `FileType dirvish` handler.
    execute 'source ' .. fnameescape(srcdir .. '/ftplugin/dirvish.vim')
    var curwin: number = winnr()
    setlocal filetype=dirvish
    if curwin != winnr() | throw 'FileType autocmd changed the window' | endif
    b:dirvish._c = b:changedtick
    ApplyIcons()
  endif
enddef

def ShouldReload(): bool
  return !BufModified() || (getline(1)->empty() && 1 == line('$'))
enddef

def BufIsvalid(bnr: number): bool
  return bufexists(bnr) && !bufname(bnr)->isdirectory()
enddef

export def Open(splitcmd: string, bg: any = -1)
# when present, `bg` is a bool
  if &autochdir
    MsgError("'autochdir' is not supported")
    return
  endif
  if !&autowriteall && !&hidden && &modified
      && winbufnr(0)->win_findbuf()->len() == 1
    MsgError('E37: No write since last change')
    return
  endif

  if bg->typename() == 'bool'
    var firstline: number = line('.')
    var lastline: number = firstline
    if mode() =~ "^[vV\<C-V>]$"
      [firstline, lastline] = [line("'<"), line("'>")]
    endif
    OpenSelected(splitcmd, bg, firstline, lastline)
    return
  endif
  var path: string = splitcmd

  var d: dict<any>
  var is_uri: bool = -1 != splitcmd->match('^\w\+:[\/][\/]')
  var from_path: string = bufname('%')->fnamemodify(':p')
  var to_path: string = path->fnamemodify(':p')
  #                                        ^resolves to CWD if path is empty

  d._dir = filereadable(to_path) ? fnamemodify(to_path, ':p:h') : to_path
  d._dir = NormalizeDir(d._dir, is_uri)
  # Fallback to CWD for URIs. #127
  d._dir = empty(d._dir) && is_uri ? getcwd()->NormalizeDir(is_uri) : d._dir
  if empty(d._dir)  # NormalizeDir() already showed error.
    return
  endif

  var reloading: bool = exists('b:dirvish') && d._dir == b:dirvish._dir

  if reloading
    d.lastpath = ''         # Do not place cursor when reloading.
  elseif !is_uri && d._dir == ParentDir(from_path)
    d.lastpath = from_path  # Save lastpath when navigating _up_.
  endif

  SaveState(d)
  OpenDir(d, reloading)
enddef

export def AddIconFn(Fn: func(string): string): string
  if typename(Fn) !~ '^func'
    throw 'argument must be a Funcref'
  endif
  cb_map[string(Fn)] = Fn
  return string(Fn)
enddef

export def RemoveIconFn(fn_id: string): bool
  if cb_map->has_key(fn_id)
    cb_map->remove(fn_id)
    return true
  endif
  return false
enddef

nnoremap <Plug>(dirvish_quit) <ScriptCmd>BufClose()<CR>
nnoremap <Plug>(dirvish_arg) <ScriptCmd>SetArgs([getline('.')])<CR>
xnoremap <Plug>(dirvish_arg) <C-\><C-N><ScriptCmd>SetArgs(getline("'<", "'>"))<CR>
nnoremap <Plug>(dirvish_K) <ScriptCmd>Info([getline('.')], !!v:count)<CR>
xnoremap <Plug>(dirvish_K) <C-\><C-N><ScriptCmd>Info(getline("'<", "'>"), !!v:count)<CR>
