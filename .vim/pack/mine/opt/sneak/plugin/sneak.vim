vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload 'repeat.vim'
import autoload '../autoload/sneak/label.vim'
import autoload '../autoload/sneak/util.vim'

# Persist state for repeat.
#     opfunc    : &operatorfunc at g@ invocation.
#     opfunc_st : State during last 'operatorfunc' (g@) invocation.
var st: dict<any> = {
  rst: true,
  input: '',
  inputlen: 0,
  reverse: false,
  bounds: [0, 0],
  inclusive: false,
  label: '',
  opfunc: '',
  opfunc_st: {}
}

if exists('##OptionSet')
  augroup sneak_optionset
    autocmd!
    autocmd OptionSet operatorfunc st.opfunc = &operatorfunc | st.opfunc_st = {}
  augroup END
endif

def Init()
  if exists('g:sneak#opt')
    unlockvar g:sneak#opt
  endif
  # option
  g:sneak#opt = {
    f_reset: get(g:, 'sneak#f_reset', true),
    t_reset: get(g:, 'sneak#t_reset', true),
    s_next: get(g:, 'sneak#s_next', false),
    absolute_dir: get(g:, 'sneak#absolute_dir', false),
    use_ic_scs: get(g:, 'sneak#use_ic_scs', false),
    map_netrw: get(g:, 'sneak#map_netrw', true),
    label: get(g:, 'sneak#label', get(g:, 'sneak#streak', false)),
    label_esc: get(g:, 'sneak#label_esc', get(g:, 'sneak#streak_esc', "\<space>")),
    prompt: get(g:, 'sneak#prompt', '>')
  }

  for k: string in ['f', 't'] # if user mapped f/t to Sneak, then disable f/t reset.
    if maparg(k, 'n') =~ 'Sneak'
      g:sneak#opt[k .. '_reset'] = 0
    endif
  endfor
  lockvar g:sneak#opt
enddef

Init()

def g:SneakState(): dict<any>
  return deepcopy(st)
enddef

def g:SneakIsSneaking(): bool
  return exists('#sneak#CursorMoved')
enddef

def g:SneakCancel(): string
  util.Removehl()
  augroup sneak
    autocmd!
  augroup END
  if maparg('<esc>', 'n') =~ "'S'\\.'neakCancel'"  # Remove temporary mapping.
    silent! unmap <esc>
  endif
  return ''
enddef

# Entrypoint for `s`.
def g:SneakWrap(
  op: string,
  inputlen: number,
  reverse: bool,
  inclusive: number,
  alabel: number
)

  # get count and register before doing *anything*, else they get overwritten.
  var cnt: number = op =~ "^[vV\<C-V>]$" ? v:prevcount : v:count1
  var reg: string = v:register
  var is_similar_invocation: bool = inputlen == st.inputlen && inclusive == st.inclusive

  if g:sneak#opt.s_next
  && is_similar_invocation
  && (util.IsVisualOp(op) || empty(op))
  && g:SneakIsSneaking()
    # Repeat motion (clever-s).
    Rpt(op, reverse)
  elseif op == 'g@'
  && !empty(st.opfunc_st)
  && !empty(st.opfunc)
  && st.opfunc == &operatorfunc
    # Replay state from the last 'operatorfunc'.
    g:SneakTo(
      op,
      st.opfunc_st.input,
      st.opfunc_st.inputlen,
      cnt,
      reg,
      1,
      st.opfunc_st.reverse,
      st.opfunc_st.inclusive,
      # TODO: Originally it was:
      #
      #     st.opfunc_st.label
      #
      # But this gave a type error  at runtime, when repeating `"adrt)` (replace
      # till next paren with "a register) with the dot command.
      # Adding `->str2nr()` to  cast the (empty) string into a  number (0) fixed
      # the issue, but caused the cursor to end in an unexpected position.
      # Using `2` seems to work OK.  Does it break sth?
      2
    )
  else
    if exists('#User#SneakEnter')
      doautocmd <nomodeline> User SneakEnter
      redraw
    endif
    # Prompt for input.
    g:SneakTo(
      op,
      Getnchars(inputlen, op),
      inputlen,
      cnt,
      reg,
      0,
      reverse,
      inclusive,
      alabel
    )
    if exists('#User#SneakLeave')
      doautocmd <nomodeline> User SneakLeave
    endif
  endif
enddef

# Repeats the last motion.
def Rpt(op: string, reverse: bool)
  if st.rst # reset by f/F/t/T
    execute 'normal! '
      .. (util.IsVisualOp(op) ? 'gv' : '')
      .. v:count1 .. (reverse ? ',' : ';')
    return
  endif

  var relative_reverse: bool = (reverse && !st.reverse) || (!reverse && st.reverse)
  g:SneakTo(
    op,
    st.input,
    st.inputlen,
    v:count1,
    v:register,
    1,
    g:sneak#opt.absolute_dir ? reverse : relative_reverse,
    st.inclusive,
    0
  )
enddef

# input:      may be shorter than inputlen if the user pressed <enter> at the prompt.
# inclusive:  0: t-like, 1: f-like, 2: /-like
def g:SneakTo(
  op: string,
  input: string,
  inputlen: number,
  count: number,
  register: string,
  repeatmotion: number,
  reverse: bool,
  inclusive: number,
  alabel: number
)

  if empty(input) # user canceled
    if op == 'c' # user <esc> during change-operation should return to previous mode.
      feedkeys((col('.') > 1 && col('.') < col('$') ? "\<RIGHT>" : '') .. "\<C-\>\<C-G>", 'n')
    endif
    redraw
    echo ''
    return
  endif

  var is_v: bool = util.IsVisualOp(op)
  # initial position
  var curlin: number = line('.')
  var curcol: number = virtcol('.')
  var is_op: bool = !empty(op) && !is_v # operator-pending invocation
  var s: dict<any> = g:sneak#search#instance
  s.init(input, repeatmotion, reverse)

  if is_v && repeatmotion
    normal! gv
  endif

  # [count] means 'skip to this match' _only_ for operators/repeat-motion/1-char-search
  #   sanity check: max out at 999, to avoid searchpos() OOM.
  var skip: number = (is_op || repeatmotion || inputlen < 2) ? min([999, count]) : 0

  var gt_lt: string = reverse ? '<' : '>'
  var st_bounds: list<number> = st.bounds
  var bounds: list<number> = repeatmotion ? st_bounds : [0, 0] # [left_bound, right_bound]
  var scope_pattern: string # pattern used to highlight the vertical 'scope'
  var match_bounds: string

  # scope to a column of width `2 * (v:count1) + 1` *except* for operators/repeat-motion/1-char-search
  if ((!skip && count > 1) || max(bounds) != 0) && !is_op
    if !max(bounds) # derive bounds from count (_logical_ bounds highlighted in 'scope')
      bounds[0] = [0, (virtcol('.') - count - 1)]->max()
      bounds[1] = count + virtcol('.') + 1
    endif
    # Match *all* chars in scope. Use \%<42v (virtual column) instead of \%<42c (byte column).
    scope_pattern ..= '\%>' .. bounds[0] .. 'v\%<' .. bounds[1] .. 'v'
  endif

  if bounds->max() != 0
    # adjust logical left-bound for the _match_ pattern by -length(s) so that if _any_
    # char is within the logical bounds, it is considered a match.
    var leftbound: number = [0, (bounds[0] - inputlen) + 1]->max()
    match_bounds = '\%>' .. leftbound .. 'v\%<' .. bounds[1] .. 'v'
    s.match_pattern ..= match_bounds
  endif

  # TODO: refactor vertical scope calculation into search.vim,
  #       so this can be done in s.init() instead of here.
  s.initpattern()

  st.rptreverse = reverse
  if !repeatmotion # this is a new (not repeat) invocation
    # persist even if the search fails, because the *reverse* direction might have a match.
    st.rst = false
    st.input = input
    st.inputlen = inputlen
    st.reverse = reverse
    st.bounds = bounds
    st.inclusive = inclusive

    # Set temporary hooks on f/F/t/T so that we know when to reset Sneak.
    FtHook()
  endif

  var nextchar: list<number> = searchpos('\_.', 'n' .. (s.search_options_no_s))
  var nudge: bool = !inclusive && repeatmotion && nextchar == s.dosearch('n')
  if nudge
    nudge = util.Nudge(!reverse) # special case for t
  endif

  var matchpos: list<number>
  for _ in range(1, [1, skip]->max()) # jump to the [count]th match
    matchpos = s.dosearch()
    if 0 == matchpos->max()
      break
    else
      nudge = !inclusive
    endif
  endfor

  if 0 == max(matchpos)
    if nudge
      util.Nudge(reverse) # undo nudge for t
    endif

    var km: string = empty(&keymap) ? '' : ' (' .. &keymap .. ' keymap)'
    var what: string
    if max(bounds) != 0
      what = printf(km .. ' (in columns %d-%d): %s', bounds[0], bounds[1], input)
    else
      what = km .. ': ' .. input
    endif
    util.Echo('not found' .. what)
    return
  endif
  # search succeeded

  util.Removehl()

  if (!is_op || op == 'y') # position *after* search
    curlin = line('.')
    curcol = (virtcol('.') + (reverse ? -1 : 1))
  endif

  AttachAutocmds()

  # Might as well scope to window height (+/- 99).
  var top: number = [0, line('w0') - 99]->max()
  var bot: number = line('w$') + 99
  var restrict_top_bot: string = '\%' .. gt_lt .. curlin .. 'l\%>' .. top .. 'l\%<' .. bot .. 'l'
  scope_pattern ..= restrict_top_bot
  s.match_pattern ..= restrict_top_bot
  var curln_pattern: string  = match_bounds .. '\%' .. curlin .. 'l\%' .. gt_lt .. curcol .. 'v'

  # highlight the vertical 'tunnel' that the search is scoped-to
  if max(bounds) != 0 # perform the scoped highlight...
    w:sneak_sc_hl = matchadd('SneakScope', scope_pattern)
  endif

  # highlight actual matches at or beyond the cursor position
  #   - store in w: because matchadd() highlight is per-window.
  var pat: string = (s.prefix)
    .. (s.match_pattern) .. (s.search)
    .. '\|' .. curln_pattern .. (s.search)
  w:sneak_hl_id = matchadd('Sneak', pat)

  # Clear with <esc>.  Use a funny mapping to avoid false positives. #287
  if has('gui_running') && maparg('<esc>', 'n') == ''
    nnoremap <expr> <silent> <esc> call('S' .. 'neakCancel', []) .. "\<esc>"
  endif

  var target: string
  if alabel == 2
      || (
        alabel
        && g:sneak#opt.label
        && (is_op || s.hasmatches(1))
    )
    && !max(bounds)
    target = label.To(s, is_v)
  endif

  if nudge
    util.Nudge(reverse) # undo nudge for t
  endif

  if is_op && 2 != inclusive && !reverse
    # f/t operations do not apply to the current character; nudge the cursor.
    util.Nudge(true)
  endif

  if is_op || target != ''
    util.Removehl()
  endif

  if is_op && op != 'y'
    var change: string = op !=? 'c' ? '' : "\<c-r>.\<esc>"
    var seq: string = op
      .. "\<Plug>SneakRepeat" .. strwidth(input)
      .. (reverse ? 1 : 0) .. inclusive .. (2 * (!empty(target) ? 1 : 0)) .. input .. target .. change
    repeat.Setreg(seq, register)
    repeat.Set(seq, count)

    st.label = target
    if empty(st.opfunc_st)
      st.opfunc_st = st
        ->deepcopy()
        ->filter((i: string, _): bool => i != 'opfunc_st')
    endif
  endif
enddef

def AttachAutocmds()
  augroup sneak
    autocmd!
    autocmd InsertEnter,WinLeave,BufLeave * g:SneakCancel()
    # *nested* autocmd to skip the *first* CursorMoved event.
    # NOTE: CursorMoved is *not* triggered if there is typeahead during a macro/script...
    autocmd CursorMoved * autocmd sneak CursorMoved * g:SneakCancel()
  augroup END
enddef

def g:SneakReset(key: string): string
  var c: string = util.GetChar()

  st.rst = true
  st.reverse = false
  for k: string in ['f', 't'] # unmap the temp mappings
    if g:sneak#opt[k .. '_reset']
      silent! execute 'unmap ' .. k
      silent! execute 'unmap ' .. toupper(k)
    endif
  endfor

  # count is prepended implicitly by the <expr> mapping
  return key .. c
enddef

def MapResetKey(key: string, mode: string)
  execute printf("%snoremap <silent> <expr> %s g:SneakReset('%s')", mode, key, key)
enddef

# Sets temporary mappings to 'hook' into f/F/t/T.
def FtHook()
  for k: string in ['f', 't']
    for m: string in ['n', 'x']
      # if user mapped anything to f or t, do not map over it; unfortunately this
      # also means we cannot reset ; or , when f or t is invoked.
      if g:sneak#opt[k .. '_reset'] && maparg(k, m) == ''
        MapResetKey(k, m)
        MapResetKey(k->toupper(), m)
      endif
    endfor
  endfor
enddef

def Getnchars(n: number, mode: string): string
  var s: string
  echo g:sneak#opt.prompt
  for i: number in range(1, n)
    if util.IsVisualOp(mode) | execute 'normal! gv' | endif # preserve selection
    var c: string = util.GetChar()
    if -1 != ["\<esc>", "\<c-c>", "\<c-g>", "\<backspace>",  "\<del>"]->index(c)
      return ''
    endif
    if c == "\<CR>"
      if i > 1 # special case: accept the current input (#15)
        break
      else # special case: repeat the last search (useful for label-mode).
        return st.input
      endif
    else
      s ..= c
      if 1 == &iminsert && strwidth(s) >= n
        # HACK: this can happen if the user entered multiple characters while we
        # were waiting to resolve a multi-char keymap.
        # example for keymap 'bulgarian-phonetic':
        #     e:: => ё    | resolved, strwidth=1
        #     eo  => eo   | unresolved, strwidth=2
        break
      endif
    endif
    redraw | echo g:sneak#opt.prompt .. s
  endfor
  return s
enddef

# 2-char sneak
nnoremap <Plug>Sneak_s <ScriptCmd>g:SneakWrap('', 2, false, 2, 1)<CR>
nnoremap <Plug>Sneak_S <ScriptCmd>g:SneakWrap('', 2, true, 2, 1)<CR>
xnoremap <Plug>Sneak_s <C-\><C-N><ScriptCmd>g:SneakWrap(visualmode(), 2, false, 2, 1)<CR>
xnoremap <Plug>Sneak_S <C-\><C-N><ScriptCmd>g:SneakWrap(visualmode(), 2, true, 2, 1)<CR>
onoremap <Plug>Sneak_s <ScriptCmd>g:SneakWrap(v:operator, 2, false, 2, 1)<CR>
onoremap <Plug>Sneak_S <ScriptCmd>g:SneakWrap(v:operator, 2, true, 2, 1)<CR>

onoremap <Plug>SneakRepeat <ScriptCmd>g:SneakWrap(v:operator,
  \ getcharstr()->str2nr(),
  \ getcharstr()->str2nr(),
  \ getcharstr()->str2nr(),
  \ getcharstr()->str2nr()
  \ )<CR>

# repeat motion (explicit--as opposed to implicit 'clever-s')
nnoremap <Plug>Sneak_; <ScriptCmd>Rpt('', false)<CR>
nnoremap <Plug>Sneak_, <ScriptCmd>Rpt('', true)<CR>
xnoremap <Plug>Sneak_; <C-\><C-N><ScriptCmd>Rpt(visualmode(), false)<CR>
xnoremap <Plug>Sneak_, <C-\><C-N><ScriptCmd>Rpt(visualmode(), true)<CR>
onoremap <Plug>Sneak_; <ScriptCmd>Rpt(v:operator, false)<CR>
onoremap <Plug>Sneak_, <ScriptCmd>Rpt(v:operator, true)<CR>

# 1-char 'enhanced f' sneak
nnoremap <Plug>Sneak_f <ScriptCmd>g:SneakWrap('', 1, false, 1, 0)<CR>
nnoremap <Plug>Sneak_F <ScriptCmd>g:SneakWrap('', 1, true, 1, 0)<CR>
xnoremap <Plug>Sneak_f <C-\><C-N><ScriptCmd>g:SneakWrap(visualmode(), 1, false, 1, 0)<CR>
xnoremap <Plug>Sneak_F <C-\><C-N><ScriptCmd>g:SneakWrap(visualmode(), 1, true, 1, 0)<CR>
onoremap <Plug>Sneak_f <ScriptCmd>g:SneakWrap(v:operator, 1, false, 1, 0)<CR>
onoremap <Plug>Sneak_F <ScriptCmd>g:SneakWrap(v:operator, 1, true, 1, 0)<CR>

# 1-char 'enhanced t' sneak
nnoremap <Plug>Sneak_t <ScriptCmd>g:SneakWrap('', 1, false, 0, 0)<CR>
nnoremap <Plug>Sneak_T <ScriptCmd>g:SneakWrap('', 1, true, 0, 0)<CR>
xnoremap <Plug>Sneak_t <C-\><C-N><ScriptCmd>g:SneakWrap(visualmode(), 1, false, 0, 0)<CR>
xnoremap <Plug>Sneak_T <C-\><C-N><ScriptCmd>g:SneakWrap(visualmode(), 1, true, 0, 0)<CR>
onoremap <Plug>Sneak_t <ScriptCmd>g:SneakWrap(v:operator, 1, false, 0, 0)<CR>
onoremap <Plug>Sneak_T <ScriptCmd>g:SneakWrap(v:operator, 1, true, 0, 0)<CR>

nnoremap <Plug>SneakLabel_s <ScriptCmd>g:SneakWrap('', 2, false, 2, 2)<CR>
nnoremap <Plug>SneakLabel_S <ScriptCmd>g:SneakWrap('', 2, true, 2, 2)<CR>
xnoremap <Plug>SneakLabel_s <C-\><C-N><ScriptCmd>g:SneakWrap(visualmode(), 2, false, 2, 2)<CR>
xnoremap <Plug>SneakLabel_S <C-\><C-N><ScriptCmd>g:SneakWrap(visualmode(), 2, true, 2, 2)<CR>
onoremap <Plug>SneakLabel_s <ScriptCmd>g:SneakWrap(v:operator, 2, 0, 2, 2)<CR>
onoremap <Plug>SneakLabel_S <ScriptCmd>g:SneakWrap(v:operator, 2, 1, 2, 2)<CR>

# Sometimes, a `<Plug>...` LHS is wrongly written in the buffer.  For example,
# from insert mode, if  you press `<C-o>` to switch to  normal mode, then `f`,
# `<Plug>Sneak_f` is  written.  Similarly,  if you  press `<C-o>`  followed by
# `ss`, `<Plug>Sneak_s` is written.  Let's prevent that.
for key: string in [
        'Label_S',
        'Label_s',
        'Repeat',
        '_,',
        '_;',
        '_F',
        '_S',
        '_T',
        '_f',
        '_s',
        '_t'
        ]
    execute $'inoremap <Plug>Sneak{key} <Nop>'
endfor

if g:sneak#opt.map_netrw && -1 != stridx(maparg('s', 'n'), 'Sneak')
  def MapNetrwKey(key: string)
    var expanded_map: string = maparg(key, 'n')
    if !strlen(expanded_map) || expanded_map =~ '_Net\|FileBeagle'
      if strlen(expanded_map) > 0 # else, mapped to <nop>
        silent execute (expanded_map =~ '<Plug>' ? 'nmap' : 'nnoremap')
          .. ' <buffer> <silent> <leader>' .. key .. ' ' .. expanded_map
      endif
      # unmap the default buffer-local mapping to allow Sneak's global mapping.
      silent! execute 'nunmap <buffer> ' .. key
    endif
  enddef

  augroup sneak_netrw
    autocmd!
    autocmd FileType netrw,filebeagle {
      autocmd sneak_netrw CursorMoved <buffer> MapNetrwKey('s')
      | MapNetrwKey('S')
      | autocmd! sneak_netrw * <buffer>
    }
  augroup END
endif
