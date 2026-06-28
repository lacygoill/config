vim9script

export def IsVisualOp(op: string): bool
  return op =~ "^[vV\<C-v>]"
enddef

export def GetChar(): string
  var input: string = getcharstr()
  if 1 != &iminsert
    return input
  endif
  # a language keymap is activated, so input must be resolved to the mapped values.
  var partial_keymap_seq: string = mapcheck(input, 'l')
  while partial_keymap_seq != ''
    var full_keymap: string = maparg(input, "l")
    if full_keymap == '' && len(input) >= 3 # HACK: assume there are no keymaps longer than 3.
      return input
    endif
    if full_keymap == partial_keymap_seq
      return full_keymap
    endif
    var c: string = getcharstr()
    if c == "\<esc>" || c == "\<CR>"
      # if the short sequence has a valid mapping, return that.
      if !empty(full_keymap)
        return full_keymap
      endif
      return input
    endif
    input ..= c
    partial_keymap_seq = mapcheck(input, 'l')
  endwhile
  return input
enddef

# returns 1 if the string contains an uppercase char. [unicode-compatible]
export def HasUpper(s: string): bool
  return -1 != match(s, '\C[[:upper:]]')
enddef

# displays a message that will dissipate at the next opportunity.
export def Echo(msg: string)
  redraw
  echo msg
  augroup sneak_echo
    autocmd!
    autocmd CursorMoved,InsertEnter,WinLeave,BufLeave * redraw | echo '' | autocmd! sneak_echo
  augroup END
enddef

# returns the least possible 'wincol'
#   - if 'sign' column is displayed, the least 'wincol' is 3
#   - there is (apparently) no clean way to detect if 'sign' column is visible
export def Wincol1(): number
  var w: dict<number> = winsaveview()
  norm! 0
  var c: number = wincol()
  winrestview(w)
  return c
enddef

# Moves the cursor to the outmost position in the current folded area.
# Returns:
#      1  if the cursor was moved
#      0  if the cursor is not in a fold
#     -1  if the start/end of the fold is at/above/below the edge of the window
export def SkipFold(current_line: number, reverse: bool): number
  var foldedge: number = reverse ? foldclosed(current_line) : foldclosedend(current_line)
  if -1 != foldedge
    if (reverse && foldedge <= line('w0')) # fold starts at/above top of window.
                || foldedge >= line('w$')  # fold ends at/below bottom of window.
      return -1
    endif
    cursor(foldedge, 0)
    cursor(0, reverse ? 1 : col('$'))
    return 1
  endif
  return 0
enddef

# Moves the cursor 1 char to the left or right; wraps at EOL, but _not_ EOF.
export def Nudge(right: bool): bool
  var nextchar: list<number> = searchpos('\_.', 'nW' .. (right ? '' : 'b'))
  if [0, 0] == nextchar
    return false
  endif
  cursor(nextchar)
  return true
enddef

# Removes highlighting.
export def Removehl()
  silent! matchdelete(w:sneak_hl_id)
  silent! matchdelete(w:sneak_sc_hl)
enddef

# Gets the 'links to' value of the specified highlight group, if any.
export def LinksTo(hlgroup: string): string
  var hl: string = execute('highlight ' .. hlgroup)
  var s: string = hl
    ->matchstr('links to \zs.*')
    ->substitute('\s', '', 'g')
  return empty(s) ? 'NONE' : s
enddef

def DefaultColor(hlgroup: string, what: string, mode: string): string
  var c: string = hlID(hlgroup)
    ->synIDtrans()
    ->synIDattr(what, mode)
  return !empty(c) && c != '-1'
    ? c
    : (what == 'bg' ? 'magenta' : 'white')
enddef

def InitHl()
  execute 'highlight default Sneak guifg=white guibg=magenta ctermfg=white ctermbg='
    .. (&t_Co->str2nr() < 256 ? 'magenta' : '201')

  if &background == 'dark'
    highlight default SneakScope guifg=black guibg=white ctermfg=0 ctermbg=255
  else
    highlight default SneakScope guifg=white guibg=black ctermfg=255 ctermbg=0
  endif

  var guibg: string = DefaultColor('Sneak', 'bg', 'gui')
  var guifg: string = DefaultColor('Sneak', 'fg', 'gui')
  var ctermbg: string = DefaultColor('Sneak', 'bg', 'cterm')
  var ctermfg: string = DefaultColor('Sneak', 'fg', 'cterm')
  execute 'highlight default SneakLabel gui=bold cterm=bold guifg='
    .. guifg .. ' guibg=' .. guibg .. ' ctermfg=' .. ctermfg .. ' ctermbg=' .. ctermbg

  guibg = DefaultColor('SneakLabel', 'bg', 'gui')
  ctermbg = DefaultColor('SneakLabel', 'bg', 'cterm')
  # fg same as bg
  execute 'highlight default SneakLabelMask guifg='
    .. guibg .. ' guibg=' .. guibg .. ' ctermfg=' .. ctermbg .. ' ctermbg=' .. ctermbg
enddef

# Re-init on :colorscheme change at runtime. #108
augroup sneak_colorscheme
  autocmd!
  autocmd ColorScheme * InitHl()
augroup END

InitHl()
